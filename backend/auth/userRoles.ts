/**
 * Defines available user roles in the application.
 * Used for role-based access control (RBAC).
 */
export enum UserRole {
  /** Full access to all system features */
  ADMIN = "Admin",
  TEACHER = "Teacher",
  /** Standard access with limited permissions */
  USER = "user",
  STUDENT = "Student",
}

/**
 * Structure of user data stored in JWT tokens.
 */
export interface UserClaims {
  id: number;
  username: string;
  role: UserRole;
}
