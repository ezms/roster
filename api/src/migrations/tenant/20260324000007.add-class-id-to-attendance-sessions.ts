import type { Connection } from 'mysql2/promise';

export async function up(client: Connection) {
    await client.query(`
        ALTER TABLE attendance_sessions
        ADD COLUMN class_id INT UNSIGNED NOT NULL
    `);
    await client.query(`
        ALTER TABLE attendance_sessions
        ADD CONSTRAINT fk_sessions_class FOREIGN KEY (class_id) REFERENCES classes (id)
    `);
}

export async function down(client: Connection) {
    await client.query(`
        ALTER TABLE attendance_sessions
        DROP FOREIGN KEY fk_sessions_class
    `);

    await client.query(`
        ALTER TABLE attendance_sessions
        DROP COLUMN class_id
    `);
}
