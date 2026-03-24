import { Column, CreatedAt, Entity, IsNull, PrimaryColumn } from 'mirror-orm';

@Entity({
    tableName: 'schools',
    filters: {
        active: { deletedAt: IsNull() },
    },
})
export class School {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('name')
    name!: string;

    @Column('db_hash')
    databaseHash!: string;

    @CreatedAt('created_at')
    createdAt!: Date;
}
