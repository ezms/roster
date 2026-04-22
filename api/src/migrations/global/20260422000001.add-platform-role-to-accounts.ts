import type { Connection } from 'mysql2/promise';

export async function up(client: Connection) {
    await client.query(`
        ALTER TABLE accounts
        ADD COLUMN platform_role VARCHAR(20) NOT NULL DEFAULT 'user'
    `);
}

export async function down(client: Connection) {
    await client.query(`
        ALTER TABLE accounts
        DROP COLUMN platform_role
    `);
}
