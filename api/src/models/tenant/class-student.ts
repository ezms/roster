import { Column, Entity, PrimaryColumn } from 'mirror-orm';

@Entity('class_students')
export class ClassStudent {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('class_id')
    classId!: number;

    @Column('student_id')
    studentId!: number;
}
