import { Column, CreatedAt, Entity, PrimaryColumn } from 'mirror-orm';

@Entity('users')
export class User {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('account_id')
    accountId!: number;

    @Column('name')
    name!: string;

    @Column('role')
    role!: 'admin' | 'teacher';

    @CreatedAt('created_at')
    createdAt!: Date;
}
