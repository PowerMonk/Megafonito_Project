import { join } from 'node:path';

export const SERVER_ROOT = join(import.meta.dir, '..');
export const DEFAULT_PORT = 8787;
export const DEFAULT_DB_PATH = join(SERVER_ROOT, 'data', 'megafonito.db');
export const WEB_DIST = join(SERVER_ROOT, 'web', 'dist');
export const APP_NAME = 'megafonito';
