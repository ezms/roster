import { Column, Entity } from 'mirror-orm';

@Entity('account_schools')
export class AccountSchool {
    @Column('account_id')
    accountId!: number;

    @Column('school_id')
    schoolId!: number;
}
