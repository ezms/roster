import type { Context, Hono } from 'hono';
import { verify } from 'hono/jwt';
import QRCode from 'qrcode';
import { getGlobalConnection, getTenantConnection } from '@/database/connections/mirror-orm';
import { School } from '@/models/global/school';
import { Student } from '@/models/tenant/student';
import { StudentCard } from '@/models/tenant/student-card';

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

function renderCard(student: Student, card: StudentCard, schoolName: string, qrSvg: string) {
    const photo = student.photoUrl
        ? `<img src="${student.photoUrl}" alt="foto" />`
        : `<div class="photo-placeholder"></div>`;

    return `<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <style>
        @page {
            size: 80mm 50mm;
            margin: 0;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background: #f0f0f0; display: flex; align-items: center; justify-content: center; min-height: 100vh; font-family: sans-serif; }
        .card {
            width: 80mm;
            height: 50mm;
            display: flex;
            flex-direction: row;
            background: #fff;
            border-radius: 2mm;
            overflow: hidden;
            box-shadow: 0 1mm 4mm rgba(0,0,0,0.15);
        }
        @page { size: 80mm 50mm; margin: 0; }
        @media print { body { background: none; min-height: unset; } .card { box-shadow: none; border-radius: 0; } }
        .left {
            width: 30mm;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 3mm;
            background: #f8f8f8;
        }
        .left img, .photo-placeholder {
            width: 24mm;
            height: 30mm;
            object-fit: cover;
            border-radius: 1mm;
            background: #ddd;
        }
        .right {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            padding: 2.5mm 2mm;
            gap: 0.8mm;
        }
        .school { font-size: 5pt; color: #aaa; text-transform: uppercase; letter-spacing: 0.4mm; }
        .id { font-size: 6pt; color: #888; font-family: monospace; }
        .name { font-size: 9.5pt; font-weight: bold; line-height: 1.2; }
        .qr { display: flex; flex-direction: column; align-items: center; gap: 0.8mm; margin-top: 1.5mm; }
        .qr svg { width: 19mm; height: 19mm; }
        .code { font-size: 6pt; color: #555; font-family: monospace; }
        .version { font-size: 5pt; color: #ccc; margin-top: auto; align-self: flex-end; }
    </style>
</head>
<body>
<div class="card">
    <div class="left">${photo}</div>
    <div class="right">
        <span class="school">${schoolName}</span>
        <span class="id">${student.code}</span>
        <span class="name">${student.name}</span>
        <div class="qr">
            ${qrSvg}
            <span class="code">${student.code}</span>
        </div>
        <span class="version">v${card.version} · ${card.issuedAt.toLocaleDateString('pt-BR')}</span>
    </div>
</div>
</body>
</html>`;
}

export function loadCardRoutes(app: Hono) {
    app.post('/cards/:studentId/issue', async (c) => {
        const ctx = await getContext(c);
        if (!ctx) return c.json({ error: 'Unauthorized' }, 401);

        const studentId = Number(c.req.param('studentId'));
        const student = await ctx.tenantConn.getRepository(Student).findOne({ where: { id: studentId } });
        if (!student) return c.json({ error: 'Student not found' }, 404);

        const repo = ctx.tenantConn.getRepository(StudentCard);
        const latest = await repo.find({ where: { studentId } });
        const nextVersion = latest.length > 0 ? Math.max(...latest.map((c) => c.version)) + 1 : 1;

        const card = new StudentCard();
        card.studentId = studentId;
        card.version = nextVersion;
        const saved = await repo.save(card);

        const qrSvg = await QRCode.toString(student.code, { type: 'svg', margin: 0 });
        return c.html(renderCard(student, saved, ctx.schoolName, qrSvg));
    });

    app.get('/cards/:studentId', async (c) => {
        const ctx = await getContext(c);
        if (!ctx) return c.json({ error: 'Unauthorized' }, 401);

        const studentId = Number(c.req.param('studentId'));
        const student = await ctx.tenantConn.getRepository(Student).findOne({ where: { id: studentId } });
        if (!student) return c.json({ error: 'Student not found' }, 404);

        const cards = await ctx.tenantConn.getRepository(StudentCard).find({ where: { studentId } });
        if (cards.length === 0) return c.json({ error: 'No card issued yet' }, 404);

        const latest = cards.reduce((a, b) => (a.version > b.version ? a : b));
        const qrSvg = await QRCode.toString(student.code, { type: 'svg', margin: 0 });
        return c.html(renderCard(student, latest, ctx.schoolName, qrSvg));
    });
}
