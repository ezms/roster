import mysql from 'mysql2/promise';
import { execSync } from 'node:child_process';
import { randomBytes } from 'node:crypto';
import { EnvSchema } from '@/types/env';

const schoolName = process.argv[2];

if (!schoolName) {
    console.error('Usage: pnpm tenant:create <school-name>');
    process.exit(1);
}

const env = EnvSchema.parse(process.env);

const hash = randomBytes(8).toString('hex');
const dbName = `roster_${hash}`;

const connection = await mysql.createConnection({
    host: env.DB_HOST,
    port: Number(env.DB_PORT),
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    ssl: env.NODE_ENV === 'production' ? { rejectUnauthorized: true } : undefined,
    database: env.DB_GLOBALDB_NAME,
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
