import mysql from 'mysql2/promise';
import { execSync } from 'node:child_process';
import { randomBytes } from 'node:crypto';

const schoolName = process.argv[2];

if (!schoolName) {
    console.error('Usage: pnpm tenant:create <school-name>');
    process.exit(1);
}

const hash = randomBytes(8).toString('hex');
const dbName = `roster_${hash}`;

const connection = await mysql.createConnection({
    host: process.env.DB_HOST || '127.0.0.1',
    port: Number(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'root',
    database: process.env.DB_GLOBALDB_NAME || 'roster',
});

try {
    await connection.query(`CREATE DATABASE \`${dbName}\``);
    await connection.query(
        'INSERT INTO schools (name, db_hash) VALUES (?, ?)',
        [schoolName, hash]
    );

    console.log(`[roster] Database created: ${dbName}`);

    execSync(`DB_TENANT_NAME=${dbName} pnpm migrate:tenant`, {
        stdio: 'inherit',
        env: { ...process.env, DB_TENANT_NAME: dbName },
    });

    console.log(`[roster] Tenant ready: "${schoolName}" -> ${dbName}`);
} catch (err) {
    await connection.query(`DROP DATABASE IF EXISTS \`${dbName}\``).catch(() => {});
    throw err;
} finally {
    await connection.end();
}
