import { DEFAULT_DB_PATH } from './config';
import { initDb, resetDemo } from './db';

const dbPath = process.env.DB_PATH?.trim() || DEFAULT_DB_PATH;
const db = await initDb(dbPath);

resetDemo(db);
db.close();

console.log('');
console.log('  Datos de demostración reiniciados.');
console.log('  Los usuarios demo se conservaron; los anuncios fueron eliminados.');
console.log(`  Base de datos: ${dbPath}`);
console.log('');
