import type { Connection } from 'mysql2/promise';

export async function up(client: Connection) {
    await client.query(`
        CREATE TABLE attendance_sessions (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            opened_by INT UNSIGNED NOT NULL,
            opened_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            closed_at DATETIME NULL,
            CONSTRAINT fk_sessions_user FOREIGN KEY (opened_by) REFERENCES users (id)
        )
    `);
}

export async function down(client: Connection) {
    await client.query('DROP TABLE IF EXISTS attendance_sessions');
}
