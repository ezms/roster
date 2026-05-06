import { Connection } from 'mirror-orm';
import type { Env } from '@/types/env';

const pool = new Map<string, Promise<Connection>>();

function getConnection(database: string, env: Env): Promise<Connection> {
    if (!pool.has(database)) {
        const promise = Connection.mysql({
            host: env.DB_HOST,
            port: Number(env.DB_PORT),
            user: env.DB_USER,
            password: env.DB_PASSWORD,
            database,
        }).catch((error) => {
            pool.delete(database);
            throw error;
        });
        pool.set(database, promise);
    }
    return pool.get(database)!;
}

export function getGlobalConnection(env: Env): Promise<Connection> {
    return getConnection(env.DB_GLOBALDB_NAME, env);
}

export function getTenantConnection(dbName: string, env: Env): Promise<Connection> {
    return getConnection(dbName, env);
}
