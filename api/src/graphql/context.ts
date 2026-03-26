import type { Connection } from 'mirror-orm';
import { getGlobalConnection, getTenantConnection } from '@/database/connections/mirror-orm';

export interface Context {
    globalConnection: Connection;
    tenantConnection: Connection;
    tenantDbName: string;
}

export async function createContext(request: Request): Promise<Context> {
    const tenantId = request.headers.get('X-Tenant-ID');

    if (!tenantId) {
        throw new Error('Missing X-Tenant-ID header');
    }

    const tenantDbName = `roster_${tenantId}`;

    const [globalConnection, tenantConnection] = await Promise.all([
        getGlobalConnection(),
        getTenantConnection(tenantDbName),
    ]);

    return { globalConnection, tenantConnection, tenantDbName };
}
