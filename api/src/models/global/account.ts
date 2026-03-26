import { Column, CreatedAt, Entity, PrimaryColumn } from 'mirror-orm';

@Entity('accounts')
export class Account {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('email')
    email!: string;

    @Column('password_hash')
    password!: string;

    @CreatedAt('created_at')
    createdAt!: Date;
}
