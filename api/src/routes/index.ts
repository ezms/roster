import type { Hono } from 'hono';
import { createYoga } from 'graphql-yoga';
import { schema } from '@/graphql/schema';
import { createContext } from '@/graphql/context';

const yoga = createYoga({
    schema,
    context: ({ request }) => createContext(request),
});

export const loadRoutes = (app: Hono) => {
    app.use('/graphql', async (c) => await yoga.handle(c.req.raw));
};
