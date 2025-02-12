# API Flow - Megafonito

## RBAC

#### Role Requirements ->

- **auth/authMiddleware.ts**:

  - **requireRole()**: Creates a middleware that checks if the user has required role(s).

- **auth/userRoles.ts**:

  - **enum UserRole**: Defines available user roles in the application.
    Used for role-based access control (RBAC).

- **routes/userRoutes.ts**

  - **get("/users")**: Requires the admin role to get all users.

- **controllers/userController.ts**:

  - **loginHandler**: Generates a token based on the user role.
