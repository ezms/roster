import type { Hono } from 'hono';
import { createYoga } from 'graphql-yoga';
import { schema } from '@/graphql/schema';
import { createContext } from '@/graphql/context';
import { loadAuthRoutes } from './auth';
import { loadCardRoutes } from './cards';
import { loadReportRoutes } from './reports';
import { loadSuperRoutes } from './super';

const yoga = createYoga({
    schema,
    context: ({ request }) => createContext(request),
});

export const loadRoutes = (app: Hono) => {
    loadAuthRoutes(app);
    loadCardRoutes(app);
    loadReportRoutes(app);
    loadSuperRoutes(app);
    app.use('/graphql', async (c) => await yoga.handle(c.req.raw));
};
