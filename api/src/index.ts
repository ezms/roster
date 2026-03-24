import { serve } from '@hono/node-server';
import app from './app';

app.get('/', (c) => {
    return c.text('Hello Hono!');
});

serve(
    {
        fetch: app.fetch,
        port: 3000,
    },
    (info) => {
        console.log(`\u{1F680} Server is running on http://localhost:${info.port}`);
    },
);
