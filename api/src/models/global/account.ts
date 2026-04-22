import { Column, CreatedAt, Entity, PrimaryColumn } from 'mirror-orm';

@Entity('accounts')
export class Account {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('email')
    email!: string;

    @Column('password_hash')
    password!: string;

    @Column('platform_role')
    platformRole!: 'user' | 'super';

    @CreatedAt('created_at')
    createdAt!: Date;
}
