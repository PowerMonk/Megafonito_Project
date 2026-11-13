import type { Database } from 'bun:sqlite';
import { randomBytes } from 'node:crypto';

import {
  findUserById,
  findUserByUsername,
  publicUser,
  type User,
} from './db';

interface Session {
  userId: number;
  createdAt: number;
}

const sessions = new Map<string, Session>();

export async function authenticate(
  db: Database,
  username: string,
  password: string,
): Promise<User | null> {
  const row = findUserByUsername(db, username);
  if (!row) return null;

  const valid = await Bun.password.verify(password, row.password_hash);
  if (!valid) return null;

  return publicUser(row);
}

export function createSession(userId: number): string {
  const token = randomBytes(32).toString('hex');
  sessions.set(token, { userId, createdAt: Date.now() });
  return token;
}

export function endSession(token: string | null): void {
  if (token) sessions.delete(token);
}

export function clearSessions(): void {
  sessions.clear();
}

export function getBearerToken(req: Request): string | null {
  const header = req.headers.get('authorization');
  if (!header) return null;
  const [scheme, token] = header.split(' ');
  if (scheme?.toLowerCase() !== 'bearer' || !token) return null;
  return token.trim();
}

export function getSessionUser(
  db: Database,
  token: string | null,
): User | null {
  if (!token) return null;
  const session = sessions.get(token);
  if (!session) return null;
  const row = findUserById(db, session.userId);
  return row ? publicUser(row) : null;
}

export function getRequestUser(db: Database, req: Request): User | null {
  return getSessionUser(db, getBearerToken(req));
}

export function isAdmin(user: User): boolean {
  return user.role === 'admin';
}
