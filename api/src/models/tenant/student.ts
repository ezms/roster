import { Column, CreatedAt, DeletedAt, Entity, PrimaryColumn } from 'mirror-orm';

@Entity('students')
export class Student {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('name')
    name!: string;

    @Column('code')
    code!: string;

    @Column({ name: 'photo_url', nullable: true })
    photoUrl!: string | null;

    @CreatedAt('created_at')
    createdAt!: Date;

    @DeletedAt('deleted_at')
    deletedAt!: Date | null;
}
