import { IsNull } from 'mirror-orm';
import { builder } from '../builder';
import { AttendanceRecord } from '@/models/tenant/attendance-record';
import { AttendanceSession } from '@/models/tenant/attendance-session';
import { Student } from '@/models/tenant/student';

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

            const record = new AttendanceRecord();
            record.sessionId = session.id;
            record.studentId = student.id;
            return repo.save(record);
        },
    }),
}));
