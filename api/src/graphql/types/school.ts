import { builder } from '../builder';
import { School } from '@/models/global/school';

const SchoolRef = builder.objectRef<School>('School');

SchoolRef.implement({
    fields: (t) => ({
        id: t.exposeInt('id'),
        name: t.exposeString('name'),
        dbHash: t.field({
            type: 'String',
            resolve: (school) => school.databaseHash,
        }),
        createdAt: t.field({
            type: 'String',
            resolve: (school) => school.createdAt.toISOString(),
        }),
    }),
});

builder.queryFields((t) => ({
    schools: t.field({
        type: [SchoolRef],
        resolve: (_root, _args, ctx) => {
            return ctx.globalConnection.getRepository(School).findAll();
        },
    }),
}));
