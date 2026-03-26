import type { Hono } from 'hono';
import { sign } from 'hono/jwt';
import { compare } from 'bcryptjs';
import { getGlobalConnection } from '@/database/connections/mirror-orm';
import { Account } from '@/models/global/account';

export function loadAuthRoutes(app: Hono) {
    app.post('/auth/login', async (c) => {
        const { email, password } = await c.req.json<{ email: string; password: string }>();

        const conn = await getGlobalConnection();
        const account = await conn.getRepository(Account).findOne({
            where: { email },
        });

        if (!account) {
            return c.json({ error: 'Invalid credentials' }, 401);
        }

        const valid = await compare(password, account.password);
        if (!valid) {
            return c.json({ error: 'Invalid credentials' }, 401);
        }

        const token = await sign(
            { accountId: account.id, exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 },
            process.env.JWT_SECRET || 'secret',
            'HS256',
        );

        return c.json({ token });
    });
}
