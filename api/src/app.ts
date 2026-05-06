import { Hono } from 'hono';
import type { Env } from '@/types/env';

const app = new Hono<{ Bindings: Env }>();

export default app;
