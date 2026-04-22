import { builder } from '../builder';
import { User } from '@/models/tenant/user';
import { AccountSchool } from '@/models/global/account-school';
import { School } from '@/models/global/school';
import { requireRole } from '../permissions';

const UserRef = builder.objectRef<User>('User');

UserRef.implement({
    fields: (t) => ({
        id: t.exposeInt('id'),
        accountId: t.exposeInt('accountId'),
        name: t.exposeString('name'),
        role: t.exposeString('role'),
        createdAt: t.field({
            type: 'String',
            resolve: (user) => user.createdAt.toISOString(),
        }),
    }),
});

const CreateUserInput = builder.inputType('CreateUserInput', {
    fields: (t) => ({
        accountId: t.int({ required: true }),
        name: t.string({ required: true }),
        role: t.string({ required: true }),
    }),
});

const UpdateUserInput = builder.inputType('UpdateUserInput', {
    fields: (t) => ({
        name: t.string({ required: false }),
        role: t.string({ required: false }),
    }),
});

builder.queryFields((t) => ({
    me: t.field({
        type: UserRef,
        nullable: true,
        resolve: (_root, _args, ctx) => {
            if (!ctx.tenantUserId) return null;
            return ctx.tenantConnection.getRepository(User).findById(ctx.tenantUserId);
        },
    }),
    users: t.field({
        type: [UserRef],
        resolve: (_root, _args, ctx) => {
            requireRole(ctx, 'admin', 'teacher_admin', 'secretary');
            return ctx.tenantConnection.getRepository(User).findAll();
        },
    }),
    user: t.field({
        type: UserRef,
        nullable: true,
        args: { id: t.arg.int({ required: true }) },
        resolve: (_root, args, ctx) => {
            requireRole(ctx, 'admin', 'teacher_admin', 'secretary');
            return ctx.tenantConnection.getRepository(User).findById(args.id);
        },
    }),
}));

builder.mutationFields((t) => ({
    createUser: t.field({
        type: UserRef,
        args: { input: t.arg({ type: CreateUserInput, required: true }) },
        resolve: async (_root, args, ctx) => {
            requireRole(ctx, 'admin', 'teacher_admin');
            const repo = ctx.tenantConnection.getRepository(User);
            const user = new User();
            user.accountId = args.input.accountId;
            user.name = args.input.name;
            user.role = args.input.role as User['role'];
            const saved = await repo.save(user);

            const school = await ctx.globalConnection
                .getRepository(School)
                .findOneOrFail({ where: { databaseHash: ctx.tenantDbName.replace('roster_', '') } });

            const alreadyLinked = await ctx.globalConnection
                .getRepository(AccountSchool)
                .exists({ accountId: args.input.accountId, schoolId: school.id });

            if (!alreadyLinked) {
                const link = new AccountSchool();
                link.accountId = args.input.accountId;
                link.schoolId = school.id;
                await ctx.globalConnection.getRepository(AccountSchool).save(link);
            }

            return saved;
        },
    }),
    updateUser: t.field({
        type: UserRef,
        args: {
            id: t.arg.int({ required: true }),
            input: t.arg({ type: UpdateUserInput, required: true }),
        },
        resolve: async (_root, args, ctx) => {
            requireRole(ctx, 'admin', 'teacher_admin');
            const repo = ctx.tenantConnection.getRepository(User);
            const user = await repo.findOneOrFail({ where: { id: args.id } });
            if (args.input.name != null) user.name = args.input.name;
            if (args.input.role != null) user.role = args.input.role as User['role'];
            return repo.save(user);
        },
    }),
    deleteUser: t.field({
        type: 'Boolean',
        args: { id: t.arg.int({ required: true }) },
        resolve: async (_root, args, ctx) => {
            requireRole(ctx, 'admin', 'teacher_admin');
            const repo = ctx.tenantConnection.getRepository(User);
            const user = await repo.findOneOrFail({ where: { id: args.id } });
            await repo.remove(user);
            return true;
        },
    }),
    restoreUser: t.field({
        type: UserRef,
        args: { id: t.arg.int({ required: true }) },
        resolve: async (_root, args, ctx) => {
            requireRole(ctx, 'admin', 'teacher_admin');
            const repo = ctx.tenantConnection.getRepository(User);
            const user = await repo.findOneOrFail({ where: { id: args.id }, withDeleted: true });
            user.deletedAt = null;
            return repo.save(user);
        },
    }),
}));
