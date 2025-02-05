import { Middleware } from "@oak/oak";
import { verifyJWT, UserRole } from "./authMod.ts";

export const authMiddleware: Middleware = async (ctx, next) => {
  // Get the Authorization header from the request
  const authorization = ctx.request.headers.get("Authorization");

  // If the Authorization header is missing, return a 401 Unauthorized error
  if (!authorization) {
    ctx.response.status = 401;
    ctx.response.body = { error: "Authorization header is missing" };
    return;
  }

  // Extract the JWT token from the Authorization header by removing the "Bearer " prefix
  const token = authorization.replace("Bearer ", "");

  // Verify the JWT token using the verifyJWT function
  const payload = await verifyJWT(token);

  // If the token is invalid or expired, return a 401 Unauthorized error
  if (!payload) {
    ctx.response.status = 401;
    ctx.response.body = { error: "Invalid or expired token" };
    return;
  }

  // If the token is valid, attach the payload (user data) to the context state
  ctx.state.user = payload; // payload includes {id, username, role}
  await next();
};

export const requireRole = (roles: UserRole[]): Middleware => {
  return async (ctx, next) => {
    const user = ctx.state.user; // Gets user from context state and checks if user exists and has required role

    if (!user || !roles.includes(user.role)) {
      ctx.response.status = 403;
      ctx.response.body = { error: "Insufficient user role permissions" };
      return;
    }

    await next();
  };
};
