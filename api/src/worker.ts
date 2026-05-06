import app from './app';
import { loadRoutes } from './routes';
import { EnvSchema } from './types/env';
import type { Env } from './types/env';

loadRoutes(app);

export default {
    fetch(request: Request, env: Env) {
        return app.fetch(request, EnvSchema.parse(env));
    },
};
