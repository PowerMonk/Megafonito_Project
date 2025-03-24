import {
  queryAll,
  queryOne,
  execute,
  executeTransactionWithLogic,
} from "../db/dbMod.ts";

// Update user model interface to match new schema
export interface User {
  id: number;
  control_number: string;
  email: string;
  name: string;
  role_id: number;
  role_name?: string; // For joining with roles table
  primary_group_id?: number;
  schedule?: JSON; // JSON object for user schedule
  created_at?: Date;
}

// In userModel.ts
export async function createUserWithForeignKeys(
  control_number: string,
  email: string,
  name: string,
  roleName: string,
  groupName: string,
  groupType: string = "department",
  schedule?: Record<string, unknown> | null
): Promise<User> {
  const safeSchedule = schedule === undefined ? null : schedule;

  try {
    const user = await executeTransactionWithLogic(async (transaction) => {
      // 1. Get role ID
      const roleQuery = "SELECT id FROM user_roles WHERE name = $1";
      const roleResult = await transaction.unsafe(roleQuery, [roleName]);

      if (!roleResult || roleResult.length === 0) {
        throw new Error(`Role "${roleName}" not found`);
      }

      const roleId = roleResult[0].id;

      // 2. Get or create group
      let groupId: number | null = null;
      const groupQuery = "SELECT id FROM groups WHERE name = $1 AND type = $2";
      const groupResult = await transaction.unsafe(groupQuery, [
        groupName,
        groupType,
      ]);

      if (groupResult && groupResult.length > 0) {
        groupId = groupResult[0].id;
      } else {
        const createGroupQuery =
          "INSERT INTO groups (name, type) VALUES ($1, $2) RETURNING id";
        const newGroupResult = await transaction.unsafe(createGroupQuery, [
          groupName,
          groupType,
        ]);
        groupId = newGroupResult[0].id;
      }

      // 3. Insert user
      const createUserQuery = `
        INSERT INTO users (control_number, email, name, role_id, primary_group_id, schedule) 
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING *
      `;

      const userResult = await transaction.unsafe(createUserQuery, [
        control_number,
        email,
        name,
        roleId,
        groupId,
        safeSchedule ? JSON.stringify(safeSchedule) : null,
      ]);

      return userResult[0];
    });

    if (!user) {
      throw new Error("Failed to create user");
    }

    return (await getUserById(user.id)) as User;
  } catch (error) {
    console.error("Error creating user with relationships:", error);
    throw error;
  }
}

// Create user function
export async function createUser(
  control_number: string,
  email: string,
  name: string,
  role_id: number,
  primary_group_id?: number | null,
  schedule?: Record<string, unknown> | null
): Promise<User> {
  // Convert undefined to null for PostgreSQL
  const safeGroupId = primary_group_id === undefined ? null : primary_group_id;
  const safeSchedule = schedule === undefined ? null : schedule;

  // Debug the values being sent to the database
  console.log("Creating user with params:", {
    control_number,
    email,
    name,
    role_id,
    primary_group_id: safeGroupId,
    schedule: safeSchedule ? JSON.stringify(safeSchedule) : null,
  });

  const query = `
    INSERT INTO users (control_number, email, name, role_id, primary_group_id, schedule) 
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING *
  `;

  const result = await queryOne(query, [
    control_number,
    email,
    name,
    role_id,
    primary_group_id,
    schedule,
  ]);

  return result as User;
}

// Get all users with role names
export async function getAllUsers(): Promise<User[]> {
  const query = `
    SELECT u.*, r.name as role_name
    FROM users u
    JOIN user_roles r ON u.role_id = r.id
    ORDER BY u.id
  `;

  return (await queryAll(query)) as User[];
}

// Get user by control number (username)
export async function getUserByControlNumber(
  control_number: string
): Promise<User | null> {
  try {
    const query = `
      SELECT u.*, r.name as role_name
      FROM users u
      JOIN user_roles r ON u.role_id = r.id
      WHERE u.control_number = $1
    `;

    return (await queryOne(query, [control_number])) as User;
  } catch (error) {
    console.error(
      `Error getting user by control number ${control_number}:`,
      error
    );
    return null;
  }
}

// Get user by ID
export async function getUserById(userId: number): Promise<User | null> {
  try {
    const query = `
      SELECT u.*, r.name as role_name
      FROM users u
      JOIN user_roles r ON u.role_id = r.id
      WHERE u.id = $1
    `;

    return (await queryOne(query, [userId])) as User;
  } catch (error) {
    console.error(`Error getting user by ID ${userId}:`, error);
    return null;
  }
}

// Update user
export async function updateUser(
  userId: number,
  name: string,
  email: string,
  primary_group_id?: number
): Promise<boolean> {
  try {
    const query = `
      UPDATE users
      SET name = $1, email = $2, primary_group_id = $3
      WHERE id = $4
    `;

    await execute(query, [name, email, primary_group_id, userId]);
    return true;
  } catch (error) {
    console.error(`Error updating user ${userId}:`, error);
    return false;
  }
}

// Delete user
export async function deleteUser(userId: number): Promise<boolean> {
  try {
    const query = `
      DELETE FROM users WHERE id = $1
    `;

    await execute(query, [userId]);
    return true;
  } catch (error) {
    console.error(`Error deleting user ${userId}:`, error);
    return false;
  }
}

// In userModel.ts
async function getRoleIdByName(roleName: string): Promise<number | null> {
  try {
    const query = "SELECT id FROM user_roles WHERE name = $1";
    const result = await queryOne(query, [roleName]);
    return result?.id || null;
  } catch (error) {
    console.error(`Error getting role ID for ${roleName}:`, error);
    return null;
  }
}

async function getGroupIdByNameAndType(
  name: string,
  type: string = "department" // default type
): Promise<number | null> {
  try {
    const query = "SELECT id FROM groups WHERE name = $1 AND type = $2";
    const result = await queryOne(query, [name, type]);
    return result?.id || null;
  } catch (error) {
    console.error(`Error getting group ID for ${name}:`, error);
    return null;
  }
}
