import type { Connection } from 'mysql2/promise';

export async function up(client: Connection) {
    await client.query(`
        CREATE TABLE classes (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            user_id INT UNSIGNED NOT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT fk_classes_user FOREIGN KEY (user_id) REFERENCES users (id)
        )
    `);
}

export async function down(client: Connection) {
    await client.query('DROP TABLE IF EXISTS classes');
}
