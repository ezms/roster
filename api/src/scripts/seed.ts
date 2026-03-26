import mysql from 'mysql2/promise';
import { hash } from 'bcryptjs';
import { execSync } from 'node:child_process';

const conn = await mysql.createConnection({
    host: process.env.DB_HOST || '127.0.0.1',
    port: Number(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'root',
    database: process.env.DB_GLOBALDB_NAME || 'roster',
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
    'INSERT INTO account_schools (account_id, school_id) VALUES (?, ?)',
    [account.id, school.id],
);

console.log('[seed] Account linked to school');

await conn.end();
