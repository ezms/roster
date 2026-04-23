import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { readdir } from 'node:fs/promises';
import type { Hono } from 'hono';
import mysql from 'mysql2/promise';
import { verify } from 'hono/jwt';
import { randomBytes } from 'node:crypto';
import { hash } from 'bcryptjs';
import { In } from 'mirror-orm';
import { getGlobalConnection, getTenantConnection } from '@/database/connections/mirror-orm';
import { Account } from '@/models/global/account';
import { AccountSchool } from '@/models/global/account-school';
import { School } from '@/models/global/school';
import { User } from '@/models/tenant/user';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

async function requireSuper(c: { req: { header: (k: string) => string | undefined } }) {
    const authorization = c.req.header('Authorization');
    if (!authorization) return null;
    try {
        const token = authorization.replace('Bearer ', '');
        const payload = (await verify(token, process.env.JWT_SECRET || 'secret', 'HS256')) as {
            accountId: number;
        };
        const globalConn = await getGlobalConnection();
        const account = await globalConn
            .getRepository(Account)
            .findOne({ where: { id: payload.accountId } });
        if (!account || account.platformRole !== 'super') return null;
        return { accountId: payload.accountId, globalConn };
    } catch {
        return null;
    }
}

async function runTenantMigrations(dbName: string) {
    const conn = await mysql.createConnection({
        host: process.env.DB_HOST || '127.0.0.1',
        port: Number(process.env.DB_PORT) || 3306,
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || 'root',
        database: dbName,
        multipleStatements: true,
    });

    const migrationsDir = path.join(__dirname, '../../migrations/tenant');
    const files = (await readdir(migrationsDir))
        .filter((f) => f.endsWith('.ts') || f.endsWith('.js'))
        .sort();

    for (const file of files) {
        const migration = await import(path.join(migrationsDir, file));
        await migration.up(conn);
    }

    await conn.end();
}

export function loadSuperRoutes(app: Hono) {
    app.get('/super/schools', async (c) => {
        const ctx = await requireSuper(c);
        if (!ctx) return c.json({ error: 'Forbidden' }, 403);

        const schools = await ctx.globalConn.getRepository(School).findAll();
        return c.json(schools);
    });

    app.post('/super/schools', async (c) => {
        const ctx = await requireSuper(c);
        if (!ctx) return c.json({ error: 'Forbidden' }, 403);

        const { name } = await c.req.json<{ name: string }>();
        if (!name?.trim()) return c.json({ error: 'Name is required' }, 400);

        const dbHash = randomBytes(8).toString('hex');
        const dbName = `roster_${dbHash}`;

        const rawConn = await mysql.createConnection({
            host: process.env.DB_HOST || '127.0.0.1',
            port: Number(process.env.DB_PORT) || 3306,
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || 'root',
        });

        try {
            await rawConn.query(`CREATE DATABASE \`${dbName}\``);
            await rawConn.end();

            await runTenantMigrations(dbName);

            const school = new School();
            school.name = name.trim();
            school.databaseHash = dbHash;
            const saved = await ctx.globalConn.getRepository(School).save(school);

            return c.json(saved, 201);
        } catch (err) {
            const rollback = await mysql.createConnection({
                host: process.env.DB_HOST || '127.0.0.1',
                port: Number(process.env.DB_PORT) || 3306,
                user: process.env.DB_USER || 'root',
                password: process.env.DB_PASSWORD || 'root',
            });
            await rollback.query(`DROP DATABASE IF EXISTS \`${dbName}\``).catch(() => {});
            await rollback.end();
            throw err;
        }
    });

    app.delete('/super/schools/:id', async (c) => {
        const ctx = await requireSuper(c);
        if (!ctx) return c.json({ error: 'Forbidden' }, 403);

        const id = Number(c.req.param('id'));
        const school = await ctx.globalConn
            .getRepository(School)
            .findOne({ where: { id } });
        if (!school) return c.json({ error: 'Not found' }, 404);

        const links = await ctx.globalConn
            .getRepository(AccountSchool)
            .find({ where: { schoolId: id } });
        for (const link of links) {
            await ctx.globalConn.getRepository(AccountSchool).remove(link);
        }

        await ctx.globalConn.getRepository(School).remove(school);
        return c.json({ ok: true });
    });

    app.get('/super/schools/:id/users', async (c) => {
        const ctx = await requireSuper(c);
        if (!ctx) return c.json({ error: 'Forbidden' }, 403);

        const id = Number(c.req.param('id'));
        const school = await ctx.globalConn
            .getRepository(School)
            .findOne({ where: { id } });
        if (!school) return c.json({ error: 'Not found' }, 404);

        const tenantConn = await getTenantConnection(`roster_${school.databaseHash}`);
        const users = await tenantConn.getRepository(User).findAll();

        if (users.length === 0) return c.json([]);

        const accounts = await ctx.globalConn
            .getRepository(Account)
            .find({ where: { id: In(users.map((u) => u.accountId)) } });

        const emailMap = new Map(accounts.map((a) => [a.id, a.email]));

        return c.json(
            users.map((u) => ({
                id: u.id,
                name: u.name,
                role: u.role,
                email: emailMap.get(u.accountId) ?? '',
            })),
        );
    });

    app.post('/super/schools/:id/users', async (c) => {
        const ctx = await requireSuper(c);
        if (!ctx) return c.json({ error: 'Forbidden' }, 403);

        const schoolId = Number(c.req.param('id'));
        const school = await ctx.globalConn
            .getRepository(School)
            .findOne({ where: { id: schoolId } });
        if (!school) return c.json({ error: 'Not found' }, 404);

        const { email, password, name, role } = await c.req.json<{
            email: string;
            password: string;
            name: string;
            role: string;
        }>();

        const exists = await ctx.globalConn.getRepository(Account).exists({ email });
        if (exists) return c.json({ error: 'Email already in use' }, 409);

        const account = new Account();
        account.email = email.trim();
        account.password = await hash(password, 10);
        account.platformRole = 'user';
        const savedAccount = await ctx.globalConn.getRepository(Account).save(account);

        const link = new AccountSchool();
        link.accountId = savedAccount.id;
        link.schoolId = schoolId;
        await ctx.globalConn.getRepository(AccountSchool).save(link);

        const tenantConn = await getTenantConnection(`roster_${school.databaseHash}`);
        const user = new User();
        user.accountId = savedAccount.id;
        user.name = name.trim();
        user.role = role as User['role'];
        const savedUser = await tenantConn.getRepository(User).save(user);

        return c.json({ id: savedUser.id, name: savedUser.name, role: savedUser.role, email }, 201);
    });

    app.delete('/super/schools/:schoolId/users/:userId', async (c) => {
        const ctx = await requireSuper(c);
        if (!ctx) return c.json({ error: 'Forbidden' }, 403);

        const schoolId = Number(c.req.param('schoolId'));
        const userId = Number(c.req.param('userId'));

        const school = await ctx.globalConn
            .getRepository(School)
            .findOne({ where: { id: schoolId } });
        if (!school) return c.json({ error: 'Not found' }, 404);

        const tenantConn = await getTenantConnection(`roster_${school.databaseHash}`);
        const user = await tenantConn.getRepository(User).findOneOrFail({ where: { id: userId } });

        const link = await ctx.globalConn
            .getRepository(AccountSchool)
            .findOne({ where: { accountId: user.accountId, schoolId } });
        if (link) await ctx.globalConn.getRepository(AccountSchool).remove(link);

        await tenantConn.getRepository(User).remove(user);
        return c.json({ ok: true });
    });
}
