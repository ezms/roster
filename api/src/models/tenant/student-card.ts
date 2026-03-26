import { Column, CreatedAt, Entity, PrimaryColumn } from 'mirror-orm';

@Entity('student_cards')
export class StudentCard {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('student_id')
    studentId!: number;

    @Column('version')
    version!: number;

    @CreatedAt('issued_at')
    issuedAt!: Date;
}
