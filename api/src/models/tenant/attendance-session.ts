import { BeforeInsert, Column, Entity, ManyToOne, PrimaryColumn } from 'mirror-orm';
import { User } from './user';

@Entity('attendance_sessions')
export class AttendanceSession {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('opened_by')
    openedBy!: number;

    @Column({ name: 'opened_at', type: 'datetime' })
    openedAt!: Date;

    @Column('class_id')
    classId!: number;

    @Column({ name: 'closed_at', type: 'datetime', nullable: true })
    closedAt!: Date | null;

    @ManyToOne(() => User, 'opened_by')
    user!: User | null;

    @BeforeInsert()
    setOpenedAt() {
        this.openedAt = new Date();
    }
}
