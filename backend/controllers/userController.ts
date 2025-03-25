import { RouterContext } from "jsr:@oak/oak";
import {
  getUserByControlNumber,
  getAllUsers,
  getUserById,
  updateUserWithForeignKeys,
  createUserWithForeignKeys,
  deleteUser,
} from "../models/modelsMod.ts";
import { generateJWT } from "../auth/authMod.ts";

// Define user roles
export enum UserRole {
  ADMIN = "Admin",
  TEACHER = "Teacher",
  STUDENT = "Student",
}

// Login handler
export async function loginHandler(ctx: RouterContext<string>) {
  const { control_number } = await ctx.request.body.json();

  if (!control_number) {
    ctx.response.status = 400;
    ctx.response.body = { error: "Control number is required" };
    return;
  }

  // Get user with role data
  const user = await getUserByControlNumber(control_number);

  console.log(user);

  if (!user) {
    ctx.response.status = 404;
    ctx.response.body = { error: "User not found" };
    return;
  }

  const token = await generateJWT({
    id: user.id,
    name: user.name,
    role: user.role_name as UserRole,
    roleLevel: getRoleLevelFromName(user.role_name as UserRole),
  });

  ctx.response.status = 200;
  ctx.response.body = {
    token,
    role: user.role_name,
    userId: user.id,
    name: user.name,
  };
}

// Helper function to get role level
export function getRoleLevelFromName(roleName: string): number {
  switch (roleName) {
    case "Admin":
      return 10;
    case "Teacher":
      return 5;
    case "Student":
    default:
      return 1;
  }
}

// In userController.ts
export async function userCreatorHandler(ctx: RouterContext<string>) {
  try {
    const {
      control_number,
      email,
      name,
      role, // Role name, not ID
      group, // Group name, not ID
      group_type, // Optional group type
      schedule,
    } = await ctx.request.body.json();

    // Validate required fields
    if (!control_number || !email || !name || !role) {
      ctx.response.status = 400;
      ctx.response.body = {
        error: "Control number, email, name, and role are required",
      };
      return;
    }

    // Admin permission check
    if (
      role === UserRole.ADMIN &&
      (!ctx.state.user || ctx.state.user.role !== UserRole.ADMIN)
    ) {
      ctx.response.status = 403;
      ctx.response.body = {
        error: "Only admins can create admin users",
        details: ctx.state.user,
      };
      return;
    }

    // Create user with role and group names
    const newUser = await createUserWithForeignKeys(
      control_number,
      email,
      name,
      role,
      group || "General", // Default group if not specified
      group_type || "department",
      schedule
    );

    const token = await generateJWT({
      id: newUser.id,
      name: newUser.name,
      role: newUser.role_name,
      roleLevel: getRoleLevelFromName(newUser.role_name as UserRole),
      // role: newUser.role_name || "Student",
      // roleLevel: getRoleLevelFromName(newUser.role_name || "Student"),
    });

    ctx.response.status = 201;
    ctx.response.body = {
      message: `User created successfully! at ${new Date()}`,
      token,
      user: newUser,
    };
  } catch (error) {
    console.error("Error creating user:", error);
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to create user: " + error };
  }
}

// Helper function to get role ID from name
function getRoleIdFromName(roleName: string): number {
  switch (roleName) {
    case "Admin":
      return 1;
    case "Teacher":
      return 2;
    case "Student":
    default:
      return 3;
  }
}

// Get all users handler
export async function getAllUsersHandler(ctx: RouterContext<string>) {
  try {
    const users = await getAllUsers();

    ctx.response.status = 200;
    ctx.response.body = users;
  } catch (error) {
    console.error("Error getting users:", error);
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to retrieve users" };
  }
}

// Get single user handler
export async function getSingleUserHandler(ctx: RouterContext<string>) {
  try {
    const control_number = ctx.params.control_number;

    if (control_number === null || control_number.length <= 0) {
      ctx.response.status = 400;
      ctx.response.body = { error: "Invalid user control number" };
      return;
    }

    const user = await getUserByControlNumber(control_number);

    if (!user) {
      ctx.response.status = 404;
      ctx.response.body = { error: "User not found" };
      return;
    }

    ctx.response.status = 200;
    ctx.response.body = user;
  } catch (error) {
    console.error("Error getting user:", error);
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to retrieve user" };
  }
}

// Update user handler
export async function userUpdaterHandler(ctx: RouterContext<string>) {
  try {
    const userId = parseInt(ctx.params.id || "0");

    if (isNaN(userId) || userId <= 0) {
      ctx.response.status = 400;
      ctx.response.body = { error: "Invalid user ID" };
      return;
    }

    const user = await getUserById(userId);

    if (!user) {
      ctx.response.status = 404;
      ctx.response.body = { error: "User not found" };
      return;
    }

    // Check permissions - only self or admin can update
    if (
      ctx.state.user.id !== userId &&
      ctx.state.user.role !== UserRole.ADMIN
    ) {
      ctx.response.status = 403;
      ctx.response.body = { error: "Permission denied" };
      return;
    }

    const {
      name,
      email,
      role, // New: role name
      group, // New: group name
      group_type, // New: group type
      schedule, // New: schedule
    } = await ctx.request.body.json();

    if (!name || !email || !role) {
      ctx.response.status = 400;
      ctx.response.body = { error: "Name, email and role are required" };
      return;
    }

    // Special permission check for role changes
    if (
      role &&
      role === UserRole.ADMIN &&
      ctx.state.user.role !== UserRole.ADMIN
    ) {
      ctx.response.status = 403;
      ctx.response.body = { error: "Only admins can assign admin role" };
      return;
    }

    // Use the enhanced update function
    const success = await updateUserWithForeignKeys(
      userId,
      name,
      email,
      role, // Role name (optional)
      group, // Group name (optional)
      group_type,
      schedule
    );

    if (success) {
      const updatedUser = await getUserById(userId);
      ctx.response.status = 200;
      ctx.response.body = updatedUser;
    } else {
      ctx.response.status = 500;
      ctx.response.body = { error: "Failed to update user" };
    }
  } catch (error) {
    console.error("Error updating user:", error);

    // Provide more specific error message if available
    if (error instanceof Error) {
      ctx.response.status = 400;
      ctx.response.body = { error: error.message };
    } else {
      ctx.response.status = 500;
      ctx.response.body = { error: "Failed to update user" };
    }
  }
}

export async function userDeleterHandler(ctx: RouterContext<string>) {
  try {
    const control_number = ctx.params.control_number;

    if (control_number === null || control_number.length <= 0) {
      ctx.response.status = 400;
      ctx.response.body = { error: "Invalid user control number" };
      return;
    }

    const user = await getUserByControlNumber(control_number);

    if (!user) {
      ctx.response.status = 404;
      ctx.response.body = { error: "User not found" };
      return;
    }

    // Check permissions - only self or admin can delete
    if (
      ctx.state.user.id !== user.id &&
      ctx.state.user.role !== UserRole.ADMIN
    ) {
      ctx.response.status = 403;
      ctx.response.body = { error: "Permission denied" };
      return;
    }

    const success = await deleteUser(user.id);

    if (success) {
      ctx.response.status = 200;
      ctx.response.body = { message: "User deleted successfully" };
    } else {
      ctx.response.status = 500;
      ctx.response.body = { error: "Failed to delete user" };
    }
  } catch (error) {
    console.error("Error deleting user:", error);
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to delete user" };
  }
}
