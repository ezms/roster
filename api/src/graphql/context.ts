import type { Connection } from 'mirror-orm';
import { verify } from 'hono/jwt';
import { getGlobalConnection, getTenantConnection } from '@/database/connections/mirror-orm';
import { Account } from '@/models/global/account';
import { AccountSchool } from '@/models/global/account-school';
import { School } from '@/models/global/school';
import { User } from '@/models/tenant/user';

export interface Context {
    globalConnection: Connection;
    tenantConnection: Connection;
    tenantDbName: string;
    accountId: number;
    isSuperUser: boolean;
    tenantUserId: number | null;
    tenantUserRole: User['role'] | null;
}

export async function createContext(request: Request): Promise<Context> {
    const tenantId = request.headers.get('X-Tenant-ID');
    if (!tenantId) throw new Error('Missing X-Tenant-ID header');

    const authorization = request.headers.get('Authorization');
    if (!authorization) throw new Error('Missing Authorization header');

    const token = authorization.replace('Bearer ', '');
    const payload = await verify(token, process.env.JWT_SECRET || 'secret', 'HS256') as { accountId: number };

    const globalConnection = await getGlobalConnection();

    const school = await globalConnection.getRepository(School).findOne({
        where: { databaseHash: tenantId },
    });

    if (!school) throw new Error('Tenant not found');

    const hasAccess = await globalConnection.getRepository(AccountSchool).exists({
        accountId: payload.accountId,
        schoolId: school.id,
    });

    if (!hasAccess) throw new Error('Forbidden');

    const tenantDbName = `roster_${tenantId}`;
    const tenantConnection = await getTenantConnection(tenantDbName);

    const account = await globalConnection.getRepository(Account).findOne({
        where: { id: payload.accountId },
    });

    if (!account) throw new Error('Account not found');

    const tenantUser = await tenantConnection.getRepository(User).findOne({
        where: { accountId: payload.accountId },
    });

    return {
        globalConnection,
        tenantConnection,
        tenantDbName,
        accountId: payload.accountId,
        isSuperUser: account.platformRole === 'super',
        tenantUserId: tenantUser?.id ?? null,
        tenantUserRole: tenantUser?.role ?? null,
    };
}
