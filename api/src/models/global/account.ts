import { Column, CreatedAt, Entity, IsNull, PrimaryColumn } from 'mirror-orm';

@Entity({
    tableName: 'accounts',
    filters: {
        active: { deletedAt: IsNull() },
    },
})
export class School {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('email')
    email!: string;

    @Column('password_hash')
    password!: string;

    @CreatedAt('created_at')
    createdAt!: Date;
}
