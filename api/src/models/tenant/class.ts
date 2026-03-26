import { Column, CreatedAt, Entity, PrimaryColumn } from 'mirror-orm';

@Entity('classes')
export class Class {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('name')
    name!: string;

    @Column('user_id')
    userId!: number;

    @CreatedAt('created_at')
    createdAt!: Date;
}
