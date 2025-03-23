import {
  execute,
  // executeTransaction,
  // queryOne
} from "../dbMod.ts";

export function initializeDatabase() {
  const createUsersTable = `
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      email TEXT UNIQUE NOT NULL,
      role TEXT NOT NULL DEFAULT 'user',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  // Eliminar la tabla de notices si ya existe
  // const dropNoticesTable = `
  //   DROP TABLE IF EXISTS notices;
  // `;

  const createNoticesTable = `
    CREATE TABLE IF NOT EXISTS notices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      user_id INTEGER,
      category TEXT DEFAULT 'Materias',
      has_file BOOLEAN DEFAULT 0,
      file_url TEXT,
      file_key TEXT,  
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id)
    );
  `;

  const createIndexes = `
    CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
    CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
    CREATE INDEX IF NOT EXISTS idx_notices_user_id ON notices(user_id);
    CREATE INDEX IF NOT EXISTS idx_notices_category ON notices(category);
  `;

  //   // First check if the role column exists
  //   const checkRoleColumn = `
  // SELECT COUNT(*) as count
  // FROM pragma_table_info('users')
  // WHERE name='role';
  // `;

  //   const addRoleColumn = `
  // ALTER TABLE users
  // ADD COLUMN role TEXT NOT NULL DEFAULT 'user';
  // `;

  //   const updateAdminUsers = `
  // UPDATE users
  // SET role = 'admin'
  // WHERE username IN ('Alexandra', 'Corinaa', 'Murci', 'Corina', 'Heloisa', 'Karol');
  // `;

  execute(createUsersTable);
  // execute(dropNoticesTable); // Eliminar tabla antes de crear una nueva
  execute(createNoticesTable);
  execute(createIndexes);

  // // Only add the role column if it doesn't exist
  // const result = execute(checkRoleColumn);
  // if (result === 0) {
  //   execute(addRoleColumn);
  // }

  // execute(updateAdminUsers);

  // Function to check if a column exists in a table
  // Function to check if a column exists in a table
  // function columnExists(table: string, column: string): boolean {
  //   const checkColumn = `
  //   SELECT COUNT(*) as count
  //   FROM pragma_table_info('${table}')
  //   WHERE name='${column}';
  // `;
  //   const result = queryOne<{ count: number }>(checkColumn);
  //   return result.count > 0;
  // }

  // // Prepare queries and parameters for adding columns if they don't exist
  // const queries: string[] = [];
  // const params: (string | number | null | Uint8Array | boolean)[][] = [];

  // if (!columnExists("notices", "category")) {
  //   queries.push(`
  //   ALTER TABLE notices
  //   ADD COLUMN category TEXT DEFAULT 'Materias';
  // `);
  //   params.push([]);
  // }

  // if (!columnExists("notices", "has_file")) {
  //   queries.push(`
  //   ALTER TABLE notices
  //   ADD COLUMN has_file BOOLEAN DEFAULT 0;
  // `);
  //   params.push([]);
  // }

  // if (!columnExists("notices", "file_url")) {
  //   queries.push(`
  //   ALTER TABLE notices
  //   ADD COLUMN file_url TEXT;
  // `);
  //   params.push([]);
  // }

  // if (!columnExists("notices", "file_key")) {
  //   queries.push(`
  //   ALTER TABLE notices
  //   ADD COLUMN file_key TEXT;
  // `);
  //   params.push([]);
  // }

  // // Execute all column addition queries in a single transaction
  // if (queries.length > 0) {
  //   executeTransaction(queries, params);
  // }

  console.log("Database initialized successfully!");
}
