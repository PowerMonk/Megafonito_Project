import { RouterContext } from "jsr:@oak/oak";
import {
  createUser,
  getUserByControlNumber,
  getAllUsers,
  getUserById,
  updateUser,
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
function getRoleLevelFromName(roleName: string): number {
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

// User creation handler
export async function userCreatorHandler(ctx: RouterContext<string>) {
  try {
    const { control_number, email, name, role, primary_group_id, schedule } =
      await ctx.request.body.json();

    // Validate required fields
    if (!control_number || !email || !name) {
      ctx.response.status = 400;
      ctx.response.body = {
        error: "Control number, email, and name are required",
      };
      return;
    }

    // If someone is trying to create an admin account, check permissions
    const roleId = getRoleIdFromName(role || "Student");

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

    // Create user
    const newUser = await createUser(
      control_number,
      email,
      name,
      roleId,
      primary_group_id,
      schedule
    );

    const token = await generateJWT({
      id: newUser.id,
      name: newUser.name,
      role: role || "Student",
      roleLevel: getRoleLevelFromName(role || "Student"),
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
    ctx.response.body = { error: "Failed to create user" };
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

    const { name, email, primary_group_id } = await ctx.request.body.json();

    if (!name || !email) {
      ctx.response.status = 400;
      ctx.response.body = { error: "Name and email are required" };
      return;
    }

    const success = await updateUser(userId, name, email, primary_group_id);

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
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to update user" };
  }
}
