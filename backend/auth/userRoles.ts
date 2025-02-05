export enum UserRole {
    ADMIN = "admin",
    USER = "user",
  }
  
  export interface UserClaims {
    id: number;
    username: string;
    role: UserRole;
  }