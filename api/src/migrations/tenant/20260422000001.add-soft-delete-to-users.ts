import type { Connection } from 'mysql2/promise';

export async function up(client: Connection) {
    await client.query(`
        ALTER TABLE users
        ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL
    `);
}

export async function down(client: Connection) {
    await client.query(`
        ALTER TABLE users
        DROP COLUMN deleted_at
    `);
}
