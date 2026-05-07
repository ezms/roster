import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import type { Hono } from 'hono';
import { createYoga } from 'graphql-yoga';
import { schema } from '@/graphql/schema';
import { createContext } from '@/graphql/context';
import { loadAuthRoutes } from './auth';
import { loadSuperRoutes } from './super';
import type { Env } from '@/types/env';

type ServerContext = { env: Env };

const isProd = process.env.NODE_ENV === 'production';

const yoga = createYoga<ServerContext>({
    schema,
    graphiql: !isProd,
    context: ({ request, env }) => createContext(request, env),
});

const __dirname = fileURLToPath(new URL('.', import.meta.url));
const templatePath = join(__dirname, 'resources/templates/landing.html');
const graphqlLink = `<a class="graphql-link" href="/graphql">GraphQL Playground</a>`;

const landingPage = readFileSync(templatePath, 'utf-8')
    .replace('{{ENV}}', isProd ? 'PRODUCTION' : 'DEVELOPMENT')
    .replace('{{GRAPHQL_LINK}}', isProd ? '' : graphqlLink);

export const loadRoutes = (app: Hono<{ Bindings: Env }>) => {
    app.get('/', (c) => c.html(landingPage));
    loadAuthRoutes(app);
    loadSuperRoutes(app);
    app.use('/graphql', async (c) => yoga.handle(c.req.raw, { env: c.env }));
};
