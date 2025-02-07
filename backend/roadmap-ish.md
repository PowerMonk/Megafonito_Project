# Features to implement:

1. **Atomic Rate Limiting:** Mimmicks in memory locks, could use Deno workers in future updates.

2. **RBAC:** Currently a 7/10, future improvements:

   - Permission granularity.

   ```TypeScript
   // Add permissions enum
   export enum Permission {
   READ_USERS = "read:users",
   WRITE_USERS = "write:users",
   DELETE_USERS = "delete:users"
   }
   ```

   // Map roles to permissions
   const rolePermissions = {
   [UserRole.ADMIN]: [Permission.READ_USERS, Permission.WRITE_USERS, Permission.DELETE_USERS],
   [UserRole.USER]: [Permission.READ_USERS]
   };

- Role hierarchy.

  ```TypeScript
  export enum UserRole {
  SUPER_ADMIN = "super_admin",
  ADMIN = "admin",
  MODERATOR = "moderator",
  USER = "user"
  }
  ```

- Resource access control.

```TypeScript
   const requirePermission = (resource: string, action: string): Middleware => {
     return async (ctx, next) => {
       const user = ctx.state.user;
       if (!hasPermission(user, resource, action)) {
         ctx.response.status = 403;
         return;
       }
       await next();
     };
   };
```

3. **Pagination:** Add pagination to list endpoints.

4. **API Documentation:** Use Swagger (maybe Deno Docs?) to document the API.
