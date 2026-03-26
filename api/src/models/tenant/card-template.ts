import { Column, CreatedAt, Entity, PrimaryColumn } from 'mirror-orm';

@Entity('card_templates')
export class CardTemplate {
    @PrimaryColumn({ strategy: 'identity' })
    id!: number;

    @Column('config')
    config!: Record<string, unknown>;

    @CreatedAt('created_at')
    createdAt!: Date;
}
