import { compare, hash } from 'bcryptjs';
import { builder } from '../builder';
import { Account } from '@/models/global/account';

builder.mutationFields((t) => ({
    changePassword: t.field({
        type: 'Boolean',
        args: {
            currentPassword: t.arg.string({ required: true }),
            newPassword: t.arg.string({ required: true }),
        },
        resolve: async (_root, args, ctx) => {
            const repo = ctx.globalConnection.getRepository(Account);
            const account = await repo.findOneOrFail({ where: { id: ctx.accountId } });

            const valid = await compare(args.currentPassword, account.password);
            if (!valid) throw new Error('Senha atual incorreta');

            account.password = await hash(args.newPassword, 10);
            await repo.save(account);
            return true;
        },
    }),
}));
