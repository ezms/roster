import { builder } from '../builder';
import { Class } from '@/models/tenant/class';
import { ClassStudent } from '@/models/tenant/class-student';

const ClassRef = builder.objectRef<Class>('Class');

ClassRef.implement({
    fields: (t) => ({
        id: t.exposeInt('id'),
        name: t.exposeString('name'),
        userId: t.exposeInt('userId'),
        createdAt: t.field({
            type: 'String',
            resolve: (c) => c.createdAt.toISOString(),
        }),
    }),
});

const CreateClassInput = builder.inputType('CreateClassInput', {
    fields: (t) => ({
        name: t.string({ required: true }),
    }),
});

const UpdateClassInput = builder.inputType('UpdateClassInput', {
    fields: (t) => ({
        name: t.string({ required: true }),
    }),
});

builder.queryFields((t) => ({
    classes: t.field({
        type: [ClassRef],
        resolve: (_root, _args, ctx) => {
            if (!ctx.tenantUserId) throw new Error('User not found in tenant');
            return ctx.tenantConnection.getRepository(Class).find({
                where: { userId: ctx.tenantUserId },
            });
        },
    }),
    class: t.field({
        type: ClassRef,
        nullable: true,
        args: { id: t.arg.int({ required: true }) },
        resolve: (_root, args, ctx) => {
            if (!ctx.tenantUserId) throw new Error('User not found in tenant');
            return ctx.tenantConnection.getRepository(Class).findOne({
                where: { id: args.id, userId: ctx.tenantUserId },
            });
        },
    }),
}));

builder.mutationFields((t) => ({
    createClass: t.field({
        type: ClassRef,
        args: { input: t.arg({ type: CreateClassInput, required: true }) },
        resolve: async (_root, args, ctx) => {
            if (!ctx.tenantUserId) throw new Error('User not found in tenant');
            const repo = ctx.tenantConnection.getRepository(Class);
            const c = new Class();
            c.name = args.input.name;
            c.userId = ctx.tenantUserId;
            return repo.save(c);
        },
    }),
    addStudentToClass: t.field({
        type: 'Boolean',
        args: {
            classId: t.arg.int({ required: true }),
            studentId: t.arg.int({ required: true }),
        },
        resolve: async (_root, args, ctx) => {
            const repo = ctx.tenantConnection.getRepository(ClassStudent);
            const already = await repo.exists({ classId: args.classId, studentId: args.studentId });
            if (already) return true;
            const link = new ClassStudent();
            link.classId = args.classId;
            link.studentId = args.studentId;
            await repo.save(link);
            return true;
        },
    }),
    updateClass: t.field({
        type: ClassRef,
        args: {
            id: t.arg.int({ required: true }),
            input: t.arg({ type: UpdateClassInput, required: true }),
        },
        resolve: async (_root, args, ctx) => {
            if (!ctx.tenantUserId) throw new Error('User not found in tenant');
            const repo = ctx.tenantConnection.getRepository(Class);
            const c = await repo.findOneOrFail({ where: { id: args.id, userId: ctx.tenantUserId } });
            c.name = args.input.name;
            return repo.save(c);
        },
    }),
    deleteClass: t.field({
        type: 'Boolean',
        args: { id: t.arg.int({ required: true }) },
        resolve: async (_root, args, ctx) => {
            if (!ctx.tenantUserId) throw new Error('User not found in tenant');
            const repo = ctx.tenantConnection.getRepository(Class);
            const c = await repo.findOneOrFail({ where: { id: args.id, userId: ctx.tenantUserId } });
            await repo.remove(c);
            return true;
        },
    }),
    removeStudentFromClass: t.field({
        type: 'Boolean',
        args: {
            classId: t.arg.int({ required: true }),
            studentId: t.arg.int({ required: true }),
        },
        resolve: async (_root, args, ctx) => {
            const repo = ctx.tenantConnection.getRepository(ClassStudent);
            const link = await repo.findOneOrFail({ where: { classId: args.classId, studentId: args.studentId } });
            await repo.remove(link);
            return true;
        },
    }),
}));
