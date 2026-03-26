import { Connection } from 'mirror-orm';

const pool = new Map<string, Promise<Connection>>();

function getConnection(database: string): Promise<Connection> {
    if (!pool.has(database)) {
        const promise = Connection.mysql({
            host: process.env.DB_HOST || 'localhost',
            port: Number(process.env.DB_PORT) || 3306,
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || 'root',
            database,
        }).catch((error) => {
            pool.delete(database);
            throw error;
        });
        pool.set(database, promise);
    }
    return pool.get(database)!;
}

export function getGlobalConnection(): Promise<Connection> {
    return getConnection(process.env.DB_GLOBALDB_NAME || 'roster');
}

export function getTenantConnection(dbName: string): Promise<Connection> {
    return getConnection(dbName);
}
