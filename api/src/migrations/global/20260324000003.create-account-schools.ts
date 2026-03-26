import type { Connection } from 'mysql2/promise';

export async function up(client: Connection) {
    await client.query(`
        CREATE TABLE account_schools (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            account_id INT UNSIGNED NOT NULL,
            school_id INT UNSIGNED NOT NULL,
            UNIQUE KEY uq_account_school (account_id, school_id),
            CONSTRAINT fk_account_schools_account FOREIGN KEY (account_id) REFERENCES accounts (id),
            CONSTRAINT fk_account_schools_school FOREIGN KEY (school_id) REFERENCES schools (id)
        )
    `);
}

export async function down(client: Connection) {
    await client.query('DROP TABLE IF EXISTS account_schools');
}
