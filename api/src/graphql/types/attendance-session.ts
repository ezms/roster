import { IsNull } from 'mirror-orm';
import { builder } from '../builder';
import { AttendanceSession } from '@/models/tenant/attendance-session';

const AttendanceSessionRef = builder.objectRef<AttendanceSession>('AttendanceSession');

AttendanceSessionRef.implement({
    fields: (t) => ({
        id: t.exposeInt('id'),
        openedBy: t.exposeInt('openedBy'),
        classId: t.exposeInt('classId'),
        openedAt: t.field({
            type: 'String',
            resolve: (session) => session.openedAt.toISOString(),
        }),
        closedAt: t.field({
            type: 'String',
            nullable: true,
            resolve: (session) => session.closedAt?.toISOString() ?? null,
        }),
    }),
});

builder.queryFields((t) => ({
    attendanceSessions: t.field({
        type: [AttendanceSessionRef],
        resolve: (_root, _args, ctx) => {
            return ctx.tenantConnection.getRepository(AttendanceSession).findAll();
        },
    }),
    currentSession: t.field({
        type: AttendanceSessionRef,
        nullable: true,
        resolve: (_root, _args, ctx) => {
            return ctx.tenantConnection.getRepository(AttendanceSession).findOne({
                where: { closedAt: IsNull() },
            });
        },
    }),
}));

builder.mutationFields((t) => ({
    openSession: t.field({
        type: AttendanceSessionRef,
        args: { classId: t.arg.int({ required: true }) },
        resolve: async (_root, args, ctx) => {
            const { tenantUserId } = ctx;
            if (!tenantUserId) throw new Error('User not found in tenant');
            const repo = ctx.tenantConnection.getRepository(AttendanceSession);
            const session = new AttendanceSession();
            session.openedBy = tenantUserId;
            session.classId = args.classId;
            return repo.save(session);
        },
    }),
    closeSession: t.field({
        type: AttendanceSessionRef,
        args: { id: t.arg.int({ required: true }) },
        resolve: async (_root, args, ctx) => {
            const repo = ctx.tenantConnection.getRepository(AttendanceSession);
            const session = await repo.findOneOrFail({ where: { id: args.id, closedAt: IsNull() } });
            session.closedAt = new Date();
            return repo.save(session);
        },
    }),
}));
