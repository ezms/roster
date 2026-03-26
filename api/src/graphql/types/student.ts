import { builder } from '../builder';
import { Student } from '@/models/tenant/student';

const StudentRef = builder.objectRef<Student>('Student');

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
    }),
});

const CreateStudentInput = builder.inputType('CreateStudentInput', {
    fields: (t) => ({
        name: t.string({ required: true }),
        code: t.string({ required: true }),
        photoUrl: t.string({ required: false }),
    }),
});

builder.queryFields((t) => ({
    students: t.field({
        type: [StudentRef],
        resolve: (_root, _args, ctx) => {
            return ctx.tenantConnection.getRepository(Student).findAll();
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
}));
