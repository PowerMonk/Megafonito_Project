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

// Update user with support for role and group changes
export async function updateUserWithForeignKeys(
  userId: number,
  name: string,
  email: string,
  roleName?: string,
  groupName?: string,
  groupType: string = "department",
  schedule?: Record<string, unknown> | null
): Promise<boolean> {
  try {
    return await executeTransactionWithLogic(async (transaction) => {
      // Get current user data to check what needs updating
      const currentUserQuery = "SELECT * FROM users WHERE id = $1";
      const currentUser = await transaction.unsafe(currentUserQuery, [userId]);

      if (!currentUser || currentUser.length === 0) {
        throw new Error(`User with ID ${userId} not found`);
      }

      // Prepare for updates
      let roleId = currentUser[0].role_id;
      let groupId = currentUser[0].primary_group_id;
      const safeSchedule =
        schedule === undefined
          ? currentUser[0].schedule
          : schedule === null
          ? null
          : JSON.stringify(schedule);

      // Update role if provided
      if (roleName) {
        const roleQuery = "SELECT id FROM user_roles WHERE name = $1";
        const roleResult = await transaction.unsafe(roleQuery, [roleName]);

        if (!roleResult || roleResult.length === 0) {
          throw new Error(`Role "${roleName}" not found`);
        }

        roleId = roleResult[0].id;
      }

      // Update group if provided
      if (groupName) {
        const groupQuery =
          "SELECT id FROM groups WHERE name = $1 AND type = $2";
        const groupResult = await transaction.unsafe(groupQuery, [
          groupName,
          groupType,
        ]);

        if (groupResult && groupResult.length > 0) {
          groupId = groupResult[0].id;
        }
        // else {
        //   // Create group if it doesn't exist
        //   const createGroupQuery =
        //     "INSERT INTO groups (name, type) VALUES ($1, $2) RETURNING id";
        //   const newGroupResult = await transaction.unsafe(createGroupQuery, [
        //     groupName,
        //     groupType,
        //   ]);
        //   groupId = newGroupResult[0].id;
        // }
      }

      // Update user with all the data
      const updateQuery = `
        UPDATE users
        SET name = $1, 
            email = $2, 
            role_id = $3, 
            primary_group_id = $4,
            schedule = $5
        WHERE id = $6
        RETURNING *
      `;

      const updateResult = await transaction.unsafe(updateQuery, [
        name,
        email,
        roleId,
        groupId,
        safeSchedule,
        userId,
      ]);

      return updateResult && updateResult.length > 0;
    });
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
