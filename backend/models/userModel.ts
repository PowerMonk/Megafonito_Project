import {
  execute,
  executeTransaction,
  queryAll,
  queryOne,
  safeQuery,
  safeQueryAll,
  safeExecute,
  safeExecuteTransaction,
  DatabaseRow,
} from "../db/dbMod.ts";

export function createUser(username: string, email: string, role: string) {
  const query = `
      INSERT INTO users (username, email, role) VALUES (?, ?, ?);
    `;
  return safeExecute(() => execute(query, username, email, role));
}

// Neccessary safe query function
export function getAllUsers() {
  const query = `
      SELECT * FROM users;
    `;
  return safeQueryAll(() => queryAll(query));
}

// export function getUserByUsername(username: string) {
//   const query = `
//       SELECT * FROM users WHERE username = ?;
//     `;
//   return queryOne(query, username);
// }
/**
 * Looks up a user by username
 * @param username The username to search for
 * @returns User record if found, null if no matching user exists
 * @throws Error if database query fails
 */
export function getUserByUsername(username: string): DatabaseRow | null {
  const query = `SELECT * FROM users WHERE username = ?;`;
  try {
    const result = safeQuery(() => queryOne(query, username));
    // Check if the result is an empty object (no user found)
    return Object.keys(result).length === 0 ? null : result;
  } catch (error) {
    // This catches actual DB errors
    throw new Error(`Database error looking up user: ${error}` + 500);
  }
}
export function getUserById(userId: number) {
  const query = `
      SELECT * FROM users WHERE id = ?;
    `;
  return safeQuery(() => queryOne(query, userId));
}

// Neccessary safe query function
export function updateUser(userId: number, username: string, email: string) {
  const query = `
  UPDATE users SET username = ?, email = ? WHERE id = ?;
  `;
  return safeExecute(() => execute(query, username, email, userId));
}

// Neccessary safe query function
export function deleteUser(userId: number) {
  const query = `
      DELETE FROM users WHERE id = ?;
      `;
  return safeExecute(() => execute(query, userId));
}

export function getUserAndUpdateUser(
  userId: number,
  username: string,
  email: string
) {
  const queries = [
    "SELECT * FROM users WHERE id = ?",
    "UPDATE users SET username = ?, email = ? WHERE id = ?",
  ];
  const params = [[userId], [username, email, userId]];
  return safeExecuteTransaction(() => executeTransaction(queries, params));
}
