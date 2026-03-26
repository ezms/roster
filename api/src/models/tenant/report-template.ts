import { Column, CreatedAt, Entity, PrimaryColumn } from 'mirror-orm';

@Entity('report_templates')
export class ReportTemplate {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('config')
    config!: Record<string, unknown>;

    @CreatedAt('created_at')
    createdAt!: Date;
}
