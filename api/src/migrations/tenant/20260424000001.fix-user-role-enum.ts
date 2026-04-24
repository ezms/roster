import type { Connection } from 'mysql2/promise';

export async function up(client: Connection) {
    await client.query(`
        ALTER TABLE users
        MODIFY COLUMN role ENUM('admin', 'teacher', 'secretary', 'teacher_admin') NOT NULL
    `);
}

export async function down(client: Connection) {
    await client.query(`
        ALTER TABLE users
        MODIFY COLUMN role ENUM('admin', 'teacher') NOT NULL
    `);
}
