import type { Connection } from 'mysql2/promise';

export async function up(client: Connection) {
    await client.query(`
        CREATE TABLE users (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            account_id INT UNSIGNED NOT NULL,
            name VARCHAR(255) NOT NULL,
            role ENUM('admin', 'teacher') NOT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    `);
}

export async function down(client: Connection) {
    await client.query('DROP TABLE IF EXISTS users');
}
