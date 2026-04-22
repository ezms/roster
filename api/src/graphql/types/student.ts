import { builder } from '../builder';
import { Student } from '@/models/tenant/student';
import { StudentCard } from '@/models/tenant/student-card';
import { ClassStudent } from '@/models/tenant/class-student';

const StudentCardRef = builder.objectRef<StudentCard>('StudentCard');
StudentCardRef.implement({
    fields: (t) => ({
        id: t.exposeInt('id'),
        version: t.exposeInt('version'),
        issuedAt: t.field({
            type: 'String',
            resolve: (card) => card.issuedAt.toISOString(),
        }),
    }),
});

export const StudentRef = builder.objectRef<Student>('Student');

StudentRef.implement({
    fields: (t) => ({
        id: t.exposeInt('id'),
        name: t.exposeString('name'),
        code: t.exposeString('code'),
        photoUrl: t.exposeString('photoUrl', { nullable: true }),
        createdAt: t.field({
            type: 'String',
            resolve: (student) => student.createdAt.toISOString(),
        }),
        card: t.field({
            type: StudentCardRef,
            nullable: true,
            resolve: async (student, _, ctx) => {
                const cards = await ctx.tenantConnection
                    .getRepository(StudentCard)
                    .find({ where: { studentId: student.id } });
                if (cards.length === 0) return null;
                return cards.reduce((latest, c) => c.version > latest.version ? c : latest);
            },
        }),
    }),
});

const CreateStudentInput = builder.inputType('CreateStudentInput', {
    fields: (t) => ({
        name: t.string({ required: true }),
        code: t.string({ required: true }),
        photoUrl: t.string({ required: false }),
    }),
});

const UpdateStudentInput = builder.inputType('UpdateStudentInput', {
    fields: (t) => ({
        name: t.string({ required: false }),
        code: t.string({ required: false }),
        photoUrl: t.string({ required: false }),
    }),
});

const StudentPageMetaRef = builder.objectRef<{ total: number; page: number; lastPage: number; limit: number }>('StudentPageMeta');
StudentPageMetaRef.implement({
    fields: (t) => ({
        total: t.int({ resolve: (m) => m.total }),
        page: t.int({ resolve: (m) => m.page }),
        lastPage: t.int({ resolve: (m) => m.lastPage }),
        limit: t.int({ resolve: (m) => m.limit }),
    }),
});

const StudentPageRef = builder.objectRef<{ students: Student[]; meta: { total: number; page: number; lastPage: number; limit: number } }>('StudentPage');
StudentPageRef.implement({
    fields: (t) => ({
        students: t.field({ type: [StudentRef], resolve: (p) => p.students }),
        meta: t.field({ type: StudentPageMetaRef, resolve: (p) => p.meta }),
    }),
});

builder.queryFields((t) => ({
    students: t.field({
        type: [StudentRef],
        resolve: (_root, _args, ctx) => {
            return ctx.tenantConnection.getRepository(Student).findAll();
        },
    }),
    studentsByClass: t.field({
        type: StudentPageRef,
        args: {
            classId: t.arg.int({ required: true }),
            page: t.arg.int({ required: true }),
            limit: t.arg.int({ required: true }),
        },
        resolve: async (_root, args, ctx) => {
            const result = await ctx.tenantConnection
                .getRepository(ClassStudent)
                .findPaginated({ page: args.page, limit: args.limit, where: { classId: args.classId } });

            const studentRepo = ctx.tenantConnection.getRepository(Student);
            const students = await Promise.all(result.data.map((l) => studentRepo.findById(l.studentId)));

            return {
                students: students.filter((s) => s != null) as Student[],
                meta: result.meta,
            };
        },
    }),
    student: t.field({
        type: StudentRef,
        nullable: true,
        args: { id: t.arg.int({ required: true }) },
        resolve: (_root, args, ctx) => {
            return ctx.tenantConnection.getRepository(Student).findById(args.id);
        },
    }),
}));

builder.mutationFields((t) => ({
    createStudent: t.field({
        type: StudentRef,
        args: { input: t.arg({ type: CreateStudentInput, required: true }) },
        resolve: async (_root, args, ctx) => {
            const repo = ctx.tenantConnection.getRepository(Student);
            const student = new Student();
            student.name = args.input.name;
            student.code = args.input.code;
            student.photoUrl = args.input.photoUrl ?? null;
            return repo.save(student);
        },
    }),
    updateStudent: t.field({
        type: StudentRef,
        args: {
            id: t.arg.int({ required: true }),
            input: t.arg({ type: UpdateStudentInput, required: true }),
        },
        resolve: async (_root, args, ctx) => {
            const repo = ctx.tenantConnection.getRepository(Student);
            const student = await repo.findOneOrFail({ where: { id: args.id } });
            if (args.input.name != null) student.name = args.input.name;
            if (args.input.code != null) student.code = args.input.code;
            if (args.input.photoUrl !== undefined) student.photoUrl = args.input.photoUrl ?? null;
            return repo.save(student);
        },
    }),
    deleteStudent: t.field({
        type: 'Boolean',
        args: { id: t.arg.int({ required: true }) },
        resolve: async (_root, args, ctx) => {
            const repo = ctx.tenantConnection.getRepository(Student);
            const student = await repo.findOneOrFail({ where: { id: args.id } });
            await repo.remove(student);
            return true;
        },
    }),
}));
