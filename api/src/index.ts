import { serve } from '@hono/node-server';
import app from './app';
import { loadRoutes } from './routes';
import { EnvSchema } from './types/env';

const HOST = '0.0.0.0'; 
const PORT = Number(process.env.PORT) || 7860;

process.on('unhandledRejection', (reason, promise) => {
    console.error('❌ Rejeição não tratada em:', promise, 'razão:', reason);
});

process.on('uncaughtException', (err) => {
    console.error('❌ Exceção não capturada:', err);
    process.exit(1);
});


try {
    const env = EnvSchema.parse(process.env);
    
    const PROTOCOL = process.env.PROTOCOL || 'http';
    
    loadRoutes(app);
    
    serve(
        { fetch: (req) => app.fetch(req, env), port: PORT, hostname: HOST },
        (info) => {
            console.log(`\u{1F680} Server is running on ${PROTOCOL}://${info.address}:${info.port}`);
        },
    );
} catch (error) {
    console.error('❌ Erro no Boot (Zod ou Config):', error);
    process.exit(1);
}
