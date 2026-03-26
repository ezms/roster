import type { Hono } from 'hono';
import { sign, verify } from 'hono/jwt';
import { compare, hash } from 'bcryptjs';
import { getGlobalConnection, getTenantConnection } from '@/database/connections/mirror-orm';
import { In } from 'mirror-orm';
import { Account } from '@/models/global/account';
import { AccountSchool } from '@/models/global/account-school';
import { School } from '@/models/global/school';
import { User } from '@/models/tenant/user';

const DUMMY_HASH = await hash('__dummy__', 10);

export function loadAuthRoutes(app: Hono) {
    app.post('/auth/register', async (c) => {
        const authorization = c.req.header('Authorization');
        const tenantId = c.req.header('X-Tenant-ID');

        if (!authorization || !tenantId) {
            return c.json({ error: 'Unauthorized' }, 401);
        }

        const token = authorization.replace('Bearer ', '');
        const payload = await verify(token, process.env.JWT_SECRET || 'secret', 'HS256') as { accountId: number };

        const tenantConn = await getTenantConnection(`roster_${tenantId}`);
        const caller = await tenantConn.getRepository(User).findOne({
            where: { accountId: payload.accountId },
        });

        if (!caller || caller.role !== 'admin') {
            return c.json({ error: 'Forbidden' }, 403);
        }

        const { email, password } = await c.req.json<{ email: string; password: string }>();

        const conn = await getGlobalConnection();

        const exists = await conn.getRepository(Account).exists({ email });
        if (exists) {
            return c.json({ error: 'Email already in use' }, 409);
        }

        const account = new Account();
        account.email = email;
        account.password = await hash(password, 10);
        const saved = await conn.getRepository(Account).save(account);

        return c.json({ id: saved.id, email: saved.email }, 201);
    });

    app.post('/auth/login', async (c) => {
        const { email, password } = await c.req.json<{ email: string; password: string }>();

        const conn = await getGlobalConnection();
        const account = await conn.getRepository(Account).findOne({
            where: { email },
        });

        const valid = await compare(password, account?.password ?? DUMMY_HASH);

        if (!account || !valid) {
            return c.json({ error: 'Invalid credentials' }, 401);
        }

        const links = await conn.getRepository(AccountSchool).find({
            where: { accountId: account.id },
        });

        const schools = await conn.getRepository(School).find({
            where: { id: In(links.map((l) => l.schoolId)) },
        });

        const token = await sign(
            { accountId: account.id, exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 },
            process.env.JWT_SECRET || 'secret',
            'HS256',
        );

        return c.json({ token, schools });
    });
}
