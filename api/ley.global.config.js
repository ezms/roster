import { EnvSchema } from './src/types/env.ts';

const env = EnvSchema.parse(process.env);

export default {
    host: env.DB_HOST,
    port: Number(env.DB_PORT),
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    ssl: env.NODE_ENV === 'production' ? { rejectUnauthorized: true } : undefined,
    database: env.DB_GLOBALDB_NAME,
    multipleStatements: true,
};
