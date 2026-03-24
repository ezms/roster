import type { Hono } from 'hono';

export const loadRoutes = (app: Hono) => {
    app.get('/', (c) => {
        return c.text('Hello Hono!');
    });
};
