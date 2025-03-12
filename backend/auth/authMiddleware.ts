import { Middleware } from "@oak/oak";
import { verifyJWT, UserRole } from "./authMod.ts";

export const authMiddleware: Middleware = async (ctx, next) => {
  try {
    // Get token from header
    const authHeader = ctx.request.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      ctx.response.status = 401;
      ctx.response.body = { message: "Unauthorized: No token provided" };
      return;
    }

    const token = authHeader.split(" ")[1];
    const payload = await verifyJWT(token);

    // Check if payload has the expected structure
    if (!payload || typeof payload !== "object") {
      ctx.response.status = 401;
      ctx.response.body = { message: "Invalid token payload" };
      throw new Error("Invalid token payload");
    }

    // Set the user in state with the correct role from the token
    ctx.state.user = {
      id: payload.id,
      username: payload.username,
      role: payload.role, // Make sure this is setting the literal string "admin"
    };

    await next();
  } catch (error) {
    ctx.response.status = 401;
    ctx.response.body = { message: "Unauthorized: Invalid token" };
    throw new Error(error + "Unauthorized: Invalid token");
  }
};

/**
 * Creates a middleware that checks if the user has required role(s).
 * @param roles - Array of roles allowed to access the route
 * @returns Middleware that validates user role against allowed roles
 * @throws 403 if user lacks required role
 *
 * @example
 * router.get("/admin", requireRole([UserRole.ADMIN]))
 */

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
