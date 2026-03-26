import { builder } from '../builder';
import { User } from '@/models/tenant/user';
import { AccountSchool } from '@/models/global/account-school';
import { School } from '@/models/global/school';

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

builder.queryFields((t) => ({
    users: t.field({
        type: [UserRef],
        resolve: (_root, _args, ctx) => {
            return ctx.tenantConnection.getRepository(User).findAll();
        },
    }),
    user: t.field({
        type: UserRef,
        nullable: true,
        args: { id: t.arg.int({ required: true }) },
        resolve: (_root, args, ctx) => {
            return ctx.tenantConnection.getRepository(User).findById(args.id);
        },
    }),
}));

builder.mutationFields((t) => ({
    createUser: t.field({
        type: UserRef,
        args: { input: t.arg({ type: CreateUserInput, required: true }) },
        resolve: async (_root, args, ctx) => {
            const repo = ctx.tenantConnection.getRepository(User);
            const user = new User();
            user.accountId = args.input.accountId;
            user.name = args.input.name;
            user.role = args.input.role as 'admin' | 'teacher';
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
}));
