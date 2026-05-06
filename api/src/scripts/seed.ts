import mysql from 'mysql2/promise';
import { hash } from 'bcryptjs';
import { execSync } from 'node:child_process';
import { EnvSchema } from '@/types/env';

const env = EnvSchema.parse(process.env);

const conn = await mysql.createConnection({
    host: env.DB_HOST,
    port: Number(env.DB_PORT),
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    ssl: env.NODE_ENV === 'production' ? { rejectUnauthorized: true } : undefined,
    database: env.DB_GLOBALDB_NAME,
});

const passwordHash = await hash('password123', 10);

await conn.query(
    'INSERT IGNORE INTO accounts (email, password_hash) VALUES (?, ?)',
    ['admin@test.com', passwordHash],
);

const [[account]] = await conn.query<mysql.RowDataPacket[]>(
    'SELECT id FROM accounts WHERE email = ?',
    ['admin@test.com'],
);

console.log('[seed] Account ready: admin@test.com / password123');

execSync('pnpm tenant:create "Escola Teste"', {
    stdio: 'inherit',
    env: { ...process.env },
});

const [[school]] = await conn.query<mysql.RowDataPacket[]>(
    'SELECT id FROM schools WHERE name = ?',
    ['Escola Teste'],
);

await conn.query(
    'INSERT IGNORE INTO account_schools (account_id, school_id) VALUES (?, ?)',
    [account.id, school.id],
);

console.log('[seed] Account linked to school');

await conn.end();
