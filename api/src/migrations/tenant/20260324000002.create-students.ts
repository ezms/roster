import type { Connection } from 'mysql2/promise';

export async function up(client: Connection) {
    await client.query(`
        CREATE TABLE students (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            code VARCHAR(64) NOT NULL UNIQUE,
            photo_url VARCHAR(500) NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    `);
}

export async function down(client: Connection) {
    await client.query('DROP TABLE IF EXISTS students');
}
