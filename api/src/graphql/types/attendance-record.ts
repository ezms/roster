import { In, IsNull } from 'mirror-orm';
import { builder } from '../builder';
import { AttendanceRecord } from '@/models/tenant/attendance-record';
import { AttendanceSession } from '@/models/tenant/attendance-session';
import { Student } from '@/models/tenant/student';
import { ClassStudent } from '@/models/tenant/class-student';
import { StudentRef } from './student';

const AttendanceRecordRef = builder.objectRef<AttendanceRecord>('AttendanceRecord');

AttendanceRecordRef.implement({
    fields: (t) => ({
        id: t.exposeInt('id'),
        sessionId: t.exposeInt('sessionId'),
        studentId: t.exposeInt('studentId'),
        registeredAt: t.field({
            type: 'String',
            resolve: (record) => record.registeredAt.toISOString(),
        }),
    }),
});

builder.queryFields((t) => ({
    absentStudents: t.field({
        type: [StudentRef],
        args: { sessionId: t.arg.int({ required: true }) },
        resolve: async (_root, args, ctx) => {
            const session = await ctx.tenantConnection
                .getRepository(AttendanceSession)
                .findOneOrFail({ where: { id: args.sessionId } });

            const enrolled = await ctx.tenantConnection
                .getRepository(ClassStudent)
                .find({ where: { classId: session.classId } });

            const presentIds = await ctx.tenantConnection
                .getRepository(AttendanceRecord)
                .find({ where: { sessionId: args.sessionId } })
                .then((records) => records.map((r) => r.studentId));

            const absentIds = enrolled
                .map((cs) => cs.studentId)
                .filter((id) => !presentIds.includes(id));

            if (absentIds.length === 0) return [];

            return ctx.tenantConnection
                .getRepository(Student)
                .find({ where: { id: In(absentIds) } });
        },
    }),
    attendanceRecords: t.field({
        type: [AttendanceRecordRef],
        args: { sessionId: t.arg.int({ required: true }) },
        resolve: (_root, args, ctx) => {
            return ctx.tenantConnection.getRepository(AttendanceRecord).find({
                where: { sessionId: args.sessionId },
            });
        },
    }),
}));

builder.mutationFields((t) => ({
    registerAttendance: t.field({
        type: AttendanceRecordRef,
        args: {
            studentCode: t.arg.string({ required: true }),
        },
        resolve: async (_root, args, ctx) => {
            const repo = ctx.tenantConnection.getRepository(AttendanceRecord);

            const session = await ctx.tenantConnection
                .getRepository(AttendanceSession)
                .findOneOrFail({ where: { closedAt: IsNull() } });

            const student = await ctx.tenantConnection
                .getRepository(Student)
                .findOneOrFail({ where: { code: args.studentCode } });

            const alreadyRegistered = await repo.exists({ sessionId: session.id, studentId: student.id });
            if (alreadyRegistered) throw new Error('Attendance already registered for this student in the current session');

            const record = new AttendanceRecord();
            record.sessionId = session.id;
            record.studentId = student.id;
            return repo.save(record);
        },
    }),
}));
