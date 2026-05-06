import type { Hono } from 'hono';
import { createYoga } from 'graphql-yoga';
import { schema } from '@/graphql/schema';
import { createContext } from '@/graphql/context';
import { loadAuthRoutes } from './auth';
import { loadSuperRoutes } from './super';
import type { Env } from '@/types/env';

type ServerContext = { env: Env };

const yoga = createYoga<ServerContext>({
    schema,
    context: ({ request, env }) => createContext(request, env),
});

export const loadRoutes = (app: Hono<{ Bindings: Env }>) => {
    loadAuthRoutes(app);
    loadSuperRoutes(app);
    app.use('/graphql', async (c) => yoga.handle(c.req.raw, { env: c.env }));
};
