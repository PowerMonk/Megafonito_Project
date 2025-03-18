import { RouterContext } from "@oak/oak";
import {
  createUser,
  getAllUsers,
  updateUser,
  deleteUser,
  getUserAndUpdateUser,
} from "../models/modelsMod.ts";
import { generateJWT, UserRole } from "../auth/authMod.ts";
import {
  checkUserExistsByUsername,
  checkUserExistsById,
} from "../utils/utilsMod.ts";

export async function loginHandler(ctx: RouterContext<string>) {
  const { username } = await ctx.request.body.json();

  const user = checkUserExistsByUsername(username);

  const token = await generateJWT({
    id: user!.id,
    username: user!.username,
    role: user!.role as UserRole,
  });
  ctx.response.status = 200;
  ctx.response.body = { token, role: user!.role, userId: user!.id };
}

export async function userCreatorHandler(ctx: RouterContext<string>) {
  // const {
  //   username,
  //   email,
  //   role = UserRole.USER,
  // } = await ctx.request.body.json();
  const { username, email, role } = await ctx.request.body.json();

  // If someone is trying to create an admin account AND they're either not logged in or not an admin themselves, return a 403 error
  if (
    role === UserRole.ADMIN &&
    (!ctx.state.user || ctx.state.user.role !== UserRole.ADMIN)
  ) {
    ctx.response.status = 403;
    ctx.response.body = {
      error: "Only admins can create admin users",
      details: ctx.state.user,
    };
    console.log(ctx.state.user);
    return;
  }

  createUser(username, email, role);

  const token = await generateJWT({ username, email, role });
  ctx.response.status = 201;
  ctx.response.body = {
    message: `User created successfully! at ${new Date()}`,
    token,
  };
}

export function getAllUsersHandler(ctx: RouterContext<string>) {
  const users = getAllUsers();
  ctx.response.body = users;
}

export function getSingleUserHandler(ctx: RouterContext<string>) {
  const username = ctx.params.username;

  const user = checkUserExistsByUsername(username);
  // console.log(user);

  ctx.response.body = { user };
}

export async function userUpdaterHandler(ctx: RouterContext<string>) {
  const userId = Number(ctx.params.userId);
  //   const { username, email, userId } = await ctx.request.body.json();
  const { username, email } = await ctx.request.body.json();

  checkUserExistsById(userId);

  updateUser(userId, username, email);
  ctx.response.status = 200;
  ctx.response.body = {
    message: `User updated successfully! at ${new Date()}`,
  };
}

export function userDeleterHandler(ctx: RouterContext<string>) {
  const userId = Number(ctx.params.userId);

  checkUserExistsById(userId);

  deleteUser(userId);
  ctx.response.status = 200;
  ctx.response.body = {
    message: `User deleted successfully! at ${new Date()}`,
  };
}

export async function getUserAndUpdateHandler(ctx: RouterContext<string>) {
  const userId = Number(ctx.params.userId);
  const { username, email } = await ctx.request.body.json();

  checkUserExistsById(userId);

  const updatedUser = getUserAndUpdateUser(userId, username, email);
  ctx.response.status = 200;
  ctx.response.body = {
    updatedUser,
    message: `Dual transaction for getting the user and updating done successfully! at ${new Date()}`,
  };
}
