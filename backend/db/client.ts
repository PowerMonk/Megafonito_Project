import { execute } from "./dbMod.ts";

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

  const createNoticesTable = `
    CREATE TABLE IF NOT EXISTS notices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      user_id INTEGER,
      category TEXT DEFAULT 'Clases',
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
  execute(createNoticesTable);
  execute(createIndexes);

  // // Only add the role column if it doesn't exist
  // const result = execute(checkRoleColumn);
  // if (result === 0) {
  //   execute(addRoleColumn);
  // }

  // execute(updateAdminUsers);

  console.log("Database initialized successfully!");
}
