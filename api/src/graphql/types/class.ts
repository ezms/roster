import { builder } from '../builder';
import { Class } from '@/models/tenant/class';
import { ClassStudent } from '@/models/tenant/class-student';
import { isRole, requireRole } from '../permissions';

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
            if (isRole(ctx, 'admin', 'secretary', 'teacher_admin')) {
                return ctx.tenantConnection.getRepository(Class).findAll();
            }
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
            if (isRole(ctx, 'admin', 'secretary', 'teacher_admin')) {
                return ctx.tenantConnection.getRepository(Class).findOne({
                    where: { id: args.id },
                });
            }
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
            requireRole(ctx, 'teacher', 'teacher_admin', 'admin');
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
            requireRole(ctx, 'teacher', 'teacher_admin', 'admin', 'secretary');
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
            requireRole(ctx, 'teacher', 'teacher_admin', 'admin');
            if (!ctx.tenantUserId) throw new Error('User not found in tenant');
            const repo = ctx.tenantConnection.getRepository(Class);
            const where = isRole(ctx, 'admin', 'teacher_admin')
                ? { id: args.id }
                : { id: args.id, userId: ctx.tenantUserId };
            const c = await repo.findOneOrFail({ where });
            c.name = args.input.name;
            return repo.save(c);
        },
    }),
    deleteClass: t.field({
        type: 'Boolean',
        args: { id: t.arg.int({ required: true }) },
        resolve: async (_root, args, ctx) => {
            requireRole(ctx, 'teacher', 'teacher_admin', 'admin');
            if (!ctx.tenantUserId) throw new Error('User not found in tenant');
            const repo = ctx.tenantConnection.getRepository(Class);
            const where = isRole(ctx, 'admin', 'teacher_admin')
                ? { id: args.id }
                : { id: args.id, userId: ctx.tenantUserId };
            const c = await repo.findOneOrFail({ where });
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
            requireRole(ctx, 'teacher', 'teacher_admin', 'admin', 'secretary');
            const repo = ctx.tenantConnection.getRepository(ClassStudent);
            const link = await repo.findOneOrFail({ where: { classId: args.classId, studentId: args.studentId } });
            await repo.remove(link);
            return true;
        },
    }),
    transferStudentToClass: t.field({
        type: 'Boolean',
        args: {
            studentId: t.arg.int({ required: true }),
            fromClassId: t.arg.int({ required: true }),
            toClassId: t.arg.int({ required: true }),
        },
        resolve: async (_root, args, ctx) => {
            requireRole(ctx, 'admin', 'secretary', 'teacher_admin');
            const repo = ctx.tenantConnection.getRepository(ClassStudent);
            const link = await repo.findOneOrFail({
                where: { classId: args.fromClassId, studentId: args.studentId },
            });
            await repo.remove(link);
            const newLink = new ClassStudent();
            newLink.classId = args.toClassId;
            newLink.studentId = args.studentId;
            await repo.save(newLink);
            return true;
        },
    }),
}));
