import type { Connection } from 'mysql2/promise';

export async function up(client: Connection) {
    await client.query(`
        CREATE TABLE report_templates (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            config JSON NOT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    `);
}

export async function down(client: Connection) {
    await client.query('DROP TABLE IF EXISTS report_templates');
}
