import { Column, CreatedAt, Entity, ManyToOne, PrimaryColumn } from 'mirror-orm';
import { AttendanceSession } from './attendance-session';
import { Student } from './student';

@Entity('attendance_records')
export class AttendanceRecord {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('session_id')
    sessionId!: number;

    @Column('student_id')
    studentId!: number;

    @CreatedAt('registered_at')
    registeredAt!: Date;

    @ManyToOne(() => AttendanceSession, 'session_id')
    session!: AttendanceSession | null;

    @ManyToOne(() => Student, 'student_id')
    student!: Student | null;
}
