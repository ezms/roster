import { serve } from '@hono/node-server';
import app from './app';
import { loadRoutes } from './routes';

const PORT = Number(process.env.PORT) || 3001;
const HOST = process.env.HOST || 'localhost';
const PROTOCOL = process.env.PROTOCOL || 'http';

const HONO_SERVER_OPTIONS = {
    fetch: app.fetch,
    port: PORT,
    hostname: HOST,
};

loadRoutes(app);

serve(HONO_SERVER_OPTIONS, (info) => {
    console.log(`\u{1F680} Server is running on ${PROTOCOL}://${info.address}:${info.port}`);
});
