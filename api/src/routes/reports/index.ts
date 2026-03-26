import type { Context, Hono } from 'hono';
import { verify } from 'hono/jwt';
import { getGlobalConnection, getTenantConnection } from '@/database/connections/mirror-orm';
import { School } from '@/models/global/school';
import { Class } from '@/models/tenant/class';
import { ClassStudent } from '@/models/tenant/class-student';
import { Student } from '@/models/tenant/student';
import { User } from '@/models/tenant/user';
import { AttendanceSession } from '@/models/tenant/attendance-session';
import { AttendanceRecord } from '@/models/tenant/attendance-record';

async function getContext(c: Context) {
    const authorization = c.req.header('Authorization');
    const tenantId = c.req.header('X-Tenant-ID');
    if (!authorization || !tenantId) return null;

    const token = authorization.replace('Bearer ', '');
    await verify(token, process.env.JWT_SECRET || 'secret', 'HS256');

    const globalConn = await getGlobalConnection();
    const school = await globalConn.getRepository(School).findOne({ where: { databaseHash: tenantId } });
    if (!school) return null;

    const tenantConn = await getTenantConnection(`roster_${tenantId}`);
    return { tenantConn, schoolName: school.name };
}

function renderReport(
    schoolName: string,
    className: string,
    instructorName: string,
    month: number,
    year: number,
    students: Student[],
    sessions: AttendanceSession[],
    records: AttendanceRecord[],
) {
    const presentSet = new Set(records.map((r) => `${r.sessionId}-${r.studentId}`));

    const monthLabel = new Date(year, month - 1).toLocaleString('pt-BR', { month: 'long', year: 'numeric' });

    const sessionHeaders = sessions
        .map((s) => {
            const d = s.openedAt;
            return `<th>${d.getDate().toString().padStart(2, '0')}/${(d.getMonth() + 1).toString().padStart(2, '0')}<br><small>${d.getHours().toString().padStart(2, '0')}h${d.getMinutes().toString().padStart(2, '0')}</small></th>`;
        })
        .join('');

    const rows = students
        .map((student) => {
            const cells = sessions
                .map((s) => {
                    const present = presentSet.has(`${s.id}-${student.id}`);
                    return `<td class="${present ? 'present' : 'absent'}">${present ? '✓' : '—'}</td>`;
                })
                .join('');
            const total = sessions.filter((s) => presentSet.has(`${s.id}-${student.id}`)).length;
            return `<tr><td class="student-name">${student.name}</td>${cells}<td class="total">${total}/${sessions.length}</td></tr>`;
        })
        .join('');

    return `<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <style>
        @page { size: A4; margin: 15mm; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: sans-serif; font-size: 9pt; color: #222; }
        .header {
            display: flex;
            align-items: center;
            gap: 4mm;
            padding-bottom: 4mm;
            border-bottom: 0.5mm solid #222;
            margin-bottom: 5mm;
        }
        .logo-slot {
            width: 18mm;
            height: 18mm;
            border: 0.3mm dashed #ccc;
            border-radius: 1mm;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ccc;
            font-size: 6pt;
            text-align: center;
            flex-shrink: 0;
        }
        .header-center { flex: 1; text-align: center; }
        .header-center .entity { font-size: 7pt; color: #666; text-transform: uppercase; letter-spacing: 0.4mm; }
        .header-center .school-name { font-size: 12pt; font-weight: bold; margin: 1mm 0 0.5mm; }
        .header-center .doc-title { font-size: 8pt; color: #444; text-transform: uppercase; letter-spacing: 0.3mm; }
        .header-center .doc-meta { font-size: 7.5pt; color: #666; margin-top: 1mm; }
        table { width: 100%; border-collapse: collapse; margin-top: 4mm; }
        th { background: #f0f0f0; font-size: 7.5pt; font-weight: 600; padding: 2mm; text-align: center; border: 0.3mm solid #ccc; }
        th.name-col { text-align: left; min-width: 40mm; }
        td { padding: 1.5mm 2mm; border: 0.3mm solid #e0e0e0; text-align: center; font-size: 8pt; }
        td.student-name { text-align: left; }
        td.present { color: #2a7a2a; font-weight: bold; }
        td.absent { color: #bbb; }
        td.total { font-weight: bold; color: #444; }
        tr:nth-child(even) td { background: #fafafa; }
        .footer { margin-top: 6mm; font-size: 7pt; color: #aaa; text-align: right; }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo-slot">Logo<br>Município</div>
        <div class="header-center">
            <div class="entity">Sistema de Registro de Presença</div>
            <div class="school-name">${schoolName}</div>
            <div class="doc-title">Relatório de Frequência</div>
            <div class="doc-meta">${className} &nbsp;·&nbsp; Instrutor: ${instructorName} &nbsp;·&nbsp; ${monthLabel}</div>
        </div>
        <div class="logo-slot">Logo<br>Escola</div>
    </div>
    <table>
        <thead>
            <tr>
                <th class="name-col">Aluno</th>
                ${sessionHeaders}
                <th>Total</th>
            </tr>
        </thead>
        <tbody>${rows}</tbody>
    </table>
    <div class="footer">Gerado em ${new Date().toLocaleDateString('pt-BR')}</div>
</body>
</html>`;
}

export function loadReportRoutes(app: Hono) {
    app.get('/reports/classes/:classId', async (c) => {
        const ctx = await getContext(c);
        if (!ctx) return c.json({ error: 'Unauthorized' }, 401);

        const classId = Number(c.req.param('classId'));
        const month = Number(c.req.query('month') ?? new Date().getMonth() + 1);
        const year = Number(c.req.query('year') ?? new Date().getFullYear());

        const cls = await ctx.tenantConn.getRepository(Class).findOne({ where: { id: classId } });
        if (!cls) return c.json({ error: 'Class not found' }, 404);

        const instructor = await ctx.tenantConn.getRepository(User).findOne({ where: { id: cls.userId } });

        const classStudents = await ctx.tenantConn.getRepository(ClassStudent).find({ where: { classId } });
        const studentIds = classStudents.map((cs) => cs.studentId);
        const students = studentIds.length > 0
            ? await ctx.tenantConn.getRepository(Student).find({ where: { id: studentIds } })
            : [];

        const from = new Date(year, month - 1, 1).getTime();
        const to = new Date(year, month, 0, 23, 59, 59).getTime();
        const allSessions = await ctx.tenantConn.getRepository(AttendanceSession).find({ where: { classId } });
        const sessions = allSessions.filter((s) => {
            const t = s.openedAt.getTime();
            return t >= from && t <= to;
        });

        const sessionIds = sessions.map((s) => s.id);
        const records = sessionIds.length > 0
            ? await ctx.tenantConn.getRepository(AttendanceRecord).find({ where: { sessionId: sessionIds } })
            : [];

        return c.html(renderReport(
            ctx.schoolName,
            cls.name,
            instructor?.name ?? '—',
            month,
            year,
            students,
            sessions,
            records,
        ));
    });
}
