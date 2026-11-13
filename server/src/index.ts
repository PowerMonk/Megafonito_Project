import { createApp } from './app';
import { DEFAULT_DB_PATH, DEFAULT_PORT } from './config';
import { buildLanUrls, printStartupBanner } from './network';

const dbPath = process.env.DB_PATH?.trim() || DEFAULT_DB_PATH;
const port = Number(process.env.PORT) || DEFAULT_PORT;

const app = await createApp({ dbPath, port });
const urls = await buildLanUrls(app.server.port);
await printStartupBanner(urls, dbPath);

console.log(`  Landing local:  http://localhost:${app.server.port}`);
console.log('  Detén el servidor con Ctrl+C.');
console.log('');

const shutdown = () => {
  console.log('\n  Cerrando Megafonito…');
  app.stop();
  process.exit(0);
};

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
