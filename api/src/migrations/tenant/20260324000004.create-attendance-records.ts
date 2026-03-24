import type { Connection } from 'mysql2/promise';

export async function up(client: Connection) {
    await client.query(`
        CREATE TABLE attendance_records (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            session_id INT UNSIGNED NOT NULL,
            student_id INT UNSIGNED NOT NULL,
            registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT fk_records_session FOREIGN KEY (session_id) REFERENCES attendance_sessions (id),
            CONSTRAINT fk_records_student FOREIGN KEY (student_id) REFERENCES students (id),
            UNIQUE KEY uq_session_student (session_id, student_id)
        )
    `);
}

export async function down(client: Connection) {
    await client.query('DROP TABLE IF EXISTS attendance_records');
}
