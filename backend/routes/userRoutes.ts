import { Router } from "@oak/oak";
import {
  userCreatorHandler,
  getAllUsersHandler,
  userUpdaterHandler,
  userDeleterHandler,
  getSingleUserHandler,
  // getUserAndUpdateHandler,
  loginHandler,
} from "../controllers/controllersMod.ts";
import { Validation } from "../utils/utilsMod.ts";
import { authMiddleware, requireRole, UserRole } from "../auth/authMod.ts";

export const validation = new Validation();
export const router = new Router();

router
  .post(
    "/users",
    authMiddleware,
    // validation.validateUserCreation,
    userCreatorHandler
  )
  .post("/login", loginHandler)
  .get(
    "/users",
    authMiddleware, // 1. Validates token & sets ctx.state.user
    requireRole([UserRole.ADMIN]), // 2. Checks if user.role is "admin"
    getAllUsersHandler // 3. Only executes if role check passes
  )
  .get("/users/getuser/:control_number", authMiddleware, getSingleUserHandler)
  // .put(
  //   "/users/dualtransaction/:userId",
  //   authMiddleware,
  //   getUserAndUpdateHandler
  // )
  .put("/users/:userId", authMiddleware, userUpdaterHandler)
  .delete("/users/:control_number", authMiddleware, userDeleterHandler);

export default router;
