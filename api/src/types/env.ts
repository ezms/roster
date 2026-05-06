import { z } from 'zod';

export const EnvSchema = z.object({
    DB_HOST: z.string().default('localhost'),
    DB_PORT: z.string().default('3306'),
    DB_USER: z.string().default('root'),
    DB_PASSWORD: z.string().min(1),
    DB_GLOBALDB_NAME: z.string().default('roster'),
    NODE_ENV: z.string().default('dev'),
    JWT_SECRET: z.string().min(1),
});

export type Env = z.infer<typeof EnvSchema>;
