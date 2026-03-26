import { Column, Entity, PrimaryColumn } from 'mirror-orm';

@Entity('account_schools')
export class AccountSchool {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('account_id')
    accountId!: number;

    @Column('school_id')
    schoolId!: number;
}
