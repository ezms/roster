import { serve } from '@hono/node-server';
import app from './app';
import { loadRoutes } from './routes';

const HONO_SERVER_OPTIONS = {
    fetch: app.fetch,
    port: 3000,
};

loadRoutes(app);

serve(HONO_SERVER_OPTIONS, (info) => {
    console.log(`\u{1F680} Server is running on http://localhost:${info.port}`);
});
