import type { Context } from './context';

type TenantRole = NonNullable<Context['tenantUserRole']>;

export function requireRole(context: Context, ...roles: Array<TenantRole>): void {
    if (context.isSuperUser) return;
    if (!context.tenantUserRole || !roles.includes(context.tenantUserRole)) {
        throw new Error('Forbidden');
    }
}

export function isRole(context: Context, ...roles: Array<TenantRole>): boolean {
    if (context.isSuperUser) return true;
    return context.tenantUserRole != null && roles.includes(context.tenantUserRole);
}
