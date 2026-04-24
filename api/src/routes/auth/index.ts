import type { Hono } from 'hono';
import { sign } from 'hono/jwt';
import { compare, hash } from 'bcryptjs';
import { getGlobalConnection } from '@/database/connections/mirror-orm';
import { In } from 'mirror-orm';
import { Account } from '@/models/global/account';
import { AccountSchool } from '@/models/global/account-school';
import { School } from '@/models/global/school';

const DUMMY_HASH = await hash('__dummy__', 10);

export function loadAuthRoutes(app: Hono) {
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

        const isSuperUser = account.platformRole === 'super';

        let schools: School[];
        if (isSuperUser) {
            schools = await conn.getRepository(School).findAll();
        } else {
            const links = await conn.getRepository(AccountSchool).find({
                where: { accountId: account.id },
            });
            schools = links.length > 0
                ? await conn.getRepository(School).find({
                      where: { id: In(links.map((l) => l.schoolId)) },
                  })
                : [];
        }

        const token = await sign(
            { accountId: account.id, exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 },
            process.env.JWT_SECRET || 'secret',
            'HS256',
        );

        return c.json({ token, schools, platformRole: account.platformRole });
    });
}
