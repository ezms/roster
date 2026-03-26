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
    'INSERT INTO accounts (email, password_hash) VALUES (?, ?)',
    ['admin@test.com', passwordHash],
);

console.log('[seed] Account created: admin@test.com / password123');

await conn.end();

execSync('pnpm tenant:create "Escola Teste"', {
    stdio: 'inherit',
    env: { ...process.env },
});
