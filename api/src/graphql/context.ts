import type { Connection } from 'mirror-orm';
import { verify } from 'hono/jwt';
import { getGlobalConnection, getTenantConnection } from '@/database/connections/mirror-orm';

export interface Context {
    globalConnection: Connection;
    tenantConnection: Connection;
    tenantDbName: string;
    accountId: number;
}

export async function createContext(request: Request): Promise<Context> {
    const tenantId = request.headers.get('X-Tenant-ID');
    if (!tenantId) throw new Error('Missing X-Tenant-ID header');

    const authorization = request.headers.get('Authorization');
    if (!authorization) throw new Error('Missing Authorization header');

    const token = authorization.replace('Bearer ', '');
    const payload = await verify(token, process.env.JWT_SECRET || 'secret', 'HS256') as { accountId: number };

    const tenantDbName = `roster_${tenantId}`;

    const [globalConnection, tenantConnection] = await Promise.all([
        getGlobalConnection(),
        getTenantConnection(tenantDbName),
    ]);

    return { globalConnection, tenantConnection, tenantDbName, accountId: payload.accountId };
}
