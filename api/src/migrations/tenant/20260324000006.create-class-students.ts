import type { Connection } from 'mysql2/promise';

export async function up(client: Connection) {
    await client.query(`
        CREATE TABLE class_students (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            class_id INT UNSIGNED NOT NULL,
            student_id INT UNSIGNED NOT NULL,
            UNIQUE KEY uq_class_student (class_id, student_id),
            CONSTRAINT fk_class_students_class FOREIGN KEY (class_id) REFERENCES classes (id),
            CONSTRAINT fk_class_students_student FOREIGN KEY (student_id) REFERENCES students (id)
        )
    `);
}

export async function down(client: Connection) {
    await client.query('DROP TABLE IF EXISTS class_students');
}
