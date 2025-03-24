import { Middleware } from "@oak/oak";
import { verifyJWT, UserRole } from "./authMod.ts";

export const authMiddleware: Middleware = async (ctx, next) => {
  try {
    // Get token from header
    const authHeader = ctx.request.headers.get("Authorization");

    // More detailed error handling for debugging
    if (!authHeader) {
      console.error("No Authorization header found");
      ctx.response.status = 401;
      ctx.response.body = { message: "Unauthorized: No token provided" };
      return;
    }

    if (!authHeader.startsWith("Bearer ")) {
      console.error("Authorization header doesn't start with 'Bearer '");
      ctx.response.status = 401;
      ctx.response.body = { message: "Unauthorized: Invalid token format" };
      return;
    }

    const token = authHeader.split(" ")[1];

    if (!token || token.trim() === "") {
      console.error("Empty token after splitting");
      ctx.response.status = 401;
      ctx.response.body = { message: "Unauthorized: Empty token" };
      return;
    }

    console.log("Verifying token:", token.substring(0, 10) + "...");
    const payload = await verifyJWT(token);
    console.log("Token verified, payload:", payload);

    // Check if payload has the expected structure
    if (!payload || typeof payload !== "object") {
      console.error("Invalid payload structure:", payload);
      ctx.response.status = 401;
      ctx.response.body = { message: "Invalid token payload" };
      return;
    }

    // Set the user in state with the correct role from the token
    ctx.state.user = {
      id: payload.id,
      name: payload.name, // Changed from username to name to match your new JWT structure
      role: payload.role,
    };

    await next();
  } catch (error) {
    console.error("Auth middleware error:", error);
    ctx.response.status = 401;
    ctx.response.body = {
      message: "Unauthorized: Invalid token",
      error: String(error),
    };
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
