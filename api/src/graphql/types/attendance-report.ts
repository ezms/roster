import { In } from 'mirror-orm';
import { builder } from '../builder';
import { AttendanceSession } from '@/models/tenant/attendance-session';
import { AttendanceRecord } from '@/models/tenant/attendance-record';
import { ClassStudent } from '@/models/tenant/class-student';
import { Student } from '@/models/tenant/student';
import { User } from '@/models/tenant/user';
import { Class } from '@/models/tenant/class';

type ReportSummaryData = {
    totalSessions: number;
    totalPresences: number;
    totalAbsences: number;
    attendanceRate: number;
};

type ReportSessionData = {
    id: number;
    openedAt: Date;
    className: string;
    teacherName: string;
    presentCount: number;
    absentCount: number;
};

type ReportStudentAbsenceData = {
    studentId: number;
    studentName: string;
    absenceCount: number;
};

type AttendanceReportData = {
    summary: ReportSummaryData;
    sessions: ReportSessionData[];
    topAbsentStudents: ReportStudentAbsenceData[];
};

const ReportSummaryRef = builder.objectRef<ReportSummaryData>('ReportSummary');
ReportSummaryRef.implement({
    fields: (t) => ({
        totalSessions: t.exposeInt('totalSessions'),
        totalPresences: t.exposeInt('totalPresences'),
        totalAbsences: t.exposeInt('totalAbsences'),
        attendanceRate: t.exposeFloat('attendanceRate'),
    }),
});

const ReportSessionRef = builder.objectRef<ReportSessionData>('ReportSession');
ReportSessionRef.implement({
    fields: (t) => ({
        id: t.exposeInt('id'),
        openedAt: t.field({
            type: 'String',
            resolve: (s) => s.openedAt.toISOString(),
        }),
        className: t.exposeString('className'),
        teacherName: t.exposeString('teacherName'),
        presentCount: t.exposeInt('presentCount'),
        absentCount: t.exposeInt('absentCount'),
    }),
});

const ReportStudentAbsenceRef = builder.objectRef<ReportStudentAbsenceData>('ReportStudentAbsence');
ReportStudentAbsenceRef.implement({
    fields: (t) => ({
        studentId: t.exposeInt('studentId'),
        studentName: t.exposeString('studentName'),
        absenceCount: t.exposeInt('absenceCount'),
    }),
});

const AttendanceReportRef = builder.objectRef<AttendanceReportData>('AttendanceReport');
AttendanceReportRef.implement({
    fields: (t) => ({
        summary: t.field({ type: ReportSummaryRef, resolve: (r) => r.summary }),
        sessions: t.field({ type: [ReportSessionRef], resolve: (r) => r.sessions }),
        topAbsentStudents: t.field({ type: [ReportStudentAbsenceRef], resolve: (r) => r.topAbsentStudents }),
    }),
});

const emptyReport: AttendanceReportData = {
    summary: { totalSessions: 0, totalPresences: 0, totalAbsences: 0, attendanceRate: 0 },
    sessions: [],
    topAbsentStudents: [],
};

builder.queryFields((t) => ({
    attendanceReport: t.field({
        type: AttendanceReportRef,
        args: {
            month: t.arg.int({ required: true }),
            year: t.arg.int({ required: true }),
            classId: t.arg.int({ required: false }),
            teacherId: t.arg.int({ required: false }),
        },
        resolve: async (_root, args, ctx) => {
            const { month, year } = args;

            const from = new Date(year, month - 1, 1).getTime();
            const to = new Date(year, month, 0, 23, 59, 59).getTime();

            const allSessions = await ctx.tenantConnection
                .getRepository(AttendanceSession)
                .findAll();

            let sessions = allSessions.filter((s) => {
                const t = s.openedAt.getTime();
                return t >= from && t <= to && s.closedAt != null;
            });

            if (args.classId) sessions = sessions.filter((s) => s.classId === args.classId);
            if (args.teacherId) sessions = sessions.filter((s) => s.openedBy === args.teacherId);

            if (sessions.length === 0) return emptyReport;

            const sessionIds = sessions.map((s) => s.id);
            const classIds = [...new Set(sessions.map((s) => s.classId))];
            const teacherIds = [...new Set(sessions.map((s) => s.openedBy))];

            const [records, classStudents, classes, teachers] = await Promise.all([
                ctx.tenantConnection
                    .getRepository(AttendanceRecord)
                    .find({ where: { sessionId: In(sessionIds) } }),
                ctx.tenantConnection
                    .getRepository(ClassStudent)
                    .find({ where: { classId: In(classIds) } }),
                ctx.tenantConnection
                    .getRepository(Class)
                    .find({ where: { id: In(classIds) } }),
                ctx.tenantConnection
                    .getRepository(User)
                    .find({ where: { id: In(teacherIds) } }),
            ]);

            const classMap = new Map(classes.map((c) => [c.id, c.name]));
            const teacherMap = new Map(teachers.map((u) => [u.id, u.name]));

            const recordsBySession = new Map<number, Set<number>>();
            for (const r of records) {
                if (!recordsBySession.has(r.sessionId)) recordsBySession.set(r.sessionId, new Set());
                recordsBySession.get(r.sessionId)!.add(r.studentId);
            }

            const enrolledByClass = new Map<number, number[]>();
            for (const cs of classStudents) {
                if (!enrolledByClass.has(cs.classId)) enrolledByClass.set(cs.classId, []);
                enrolledByClass.get(cs.classId)!.push(cs.studentId);
            }

            const sessionSummaries: ReportSessionData[] = sessions
                .map((s) => {
                    const present = recordsBySession.get(s.id) ?? new Set<number>();
                    const enrolled = enrolledByClass.get(s.classId) ?? [];
                    return {
                        id: s.id,
                        openedAt: s.openedAt,
                        className: classMap.get(s.classId) ?? '—',
                        teacherName: teacherMap.get(s.openedBy) ?? '—',
                        presentCount: present.size,
                        absentCount: Math.max(0, enrolled.length - present.size),
                    };
                })
                .sort((a, b) => b.openedAt.getTime() - a.openedAt.getTime());

            const totalPresences = records.length;
            const totalAbsences = sessionSummaries.reduce((sum, s) => sum + s.absentCount, 0);
            const totalSlots = totalPresences + totalAbsences;
            const attendanceRate = totalSlots > 0 ? Math.round((totalPresences / totalSlots) * 100) : 0;

            const absenceByStudent = new Map<number, number>();
            for (const s of sessions) {
                const present = recordsBySession.get(s.id) ?? new Set<number>();
                for (const studentId of enrolledByClass.get(s.classId) ?? []) {
                    if (!present.has(studentId)) {
                        absenceByStudent.set(studentId, (absenceByStudent.get(studentId) ?? 0) + 1);
                    }
                }
            }

            const studentIdsWithAbsences = [...absenceByStudent.keys()];
            const studentsWithAbsences =
                studentIdsWithAbsences.length > 0
                    ? await ctx.tenantConnection
                          .getRepository(Student)
                          .find({ where: { id: In(studentIdsWithAbsences) } })
                    : [];

            const studentNameMap = new Map(studentsWithAbsences.map((s) => [s.id, s.name]));

            const topAbsentStudents: ReportStudentAbsenceData[] = [...absenceByStudent.entries()]
                .map(([studentId, absenceCount]) => ({
                    studentId,
                    studentName: studentNameMap.get(studentId) ?? '—',
                    absenceCount,
                }))
                .sort((a, b) => b.absenceCount - a.absenceCount)
                .slice(0, 5);

            return {
                summary: { totalSessions: sessions.length, totalPresences, totalAbsences, attendanceRate },
                sessions: sessionSummaries,
                topAbsentStudents,
            };
        },
    }),
}));
