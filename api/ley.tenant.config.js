import { EnvSchema } from './src/types/env.ts';
import { z } from 'zod';

const env = EnvSchema.extend({ DB_TENANT_NAME: z.string().min(1) }).parse(process.env);

export default {
    host: env.DB_HOST,
    port: Number(env.DB_PORT),
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    ssl: env.NODE_ENV === 'production' ? { rejectUnauthorized: true } : undefined,
    database: env.DB_TENANT_NAME,
    multipleStatements: true,
};
