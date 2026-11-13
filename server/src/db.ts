import { Database } from 'bun:sqlite';
import { mkdirSync } from 'node:fs';
import { dirname } from 'node:path';

import { DEMO_USERS } from './seed';

export type Role = 'admin' | 'student';
export type Audience = 'all' | 'groups';

export interface User {
  id: number;
  username: string;
  name: string;
  email: string;
  role: Role;
  group_name: string | null;
  control_number: string | null;
  semester: number | null;
  created_at: string;
}

export interface UserRow extends User {
  password_hash: string;
}

export interface Announcement {
  id: number;
  title: string;
  content: string;
  category: string;
  author_id: number;
  author_name: string;
  audience: Audience;
  created_at: string;
  target_groups: string[];
  audience_label: string;
  has_attachment: false;
  attachment_url: null;
  attachment_key: null;
}

export interface AnnouncementPage {
  data: Announcement[];
  pagination: {
    currentPage: number;
    pageSize: number;
    totalItems: number;
    totalPages: number;
  };
}

export interface CreateAnnouncementInput {
  title: string;
  content: string;
  category: string;
  audience: Audience;
  groups: string[];
}

export interface ListAnnouncementsOptions {
  page?: number;
  limit?: number;
  category?: string | null;
  sort?: 'recent' | 'oldest' | string | null;
}

const SCHEMA = `
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'student')),
  group_name TEXT,
  control_number TEXT,
  semester INTEGER,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS announcements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'General',
  author_id INTEGER NOT NULL,
  author_name TEXT NOT NULL,
  audience TEXT NOT NULL CHECK (audience IN ('all', 'groups')),
  created_at TEXT NOT NULL,
  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS announcement_groups (
  announcement_id INTEGER NOT NULL,
  group_name TEXT NOT NULL,
  PRIMARY KEY (announcement_id, group_name),
  FOREIGN KEY (announcement_id) REFERENCES announcements(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_announcements_created_at
  ON announcements(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_announcement_groups_group
  ON announcement_groups(group_name);
`;

export async function initDb(path: string): Promise<Database> {
  if (path !== ':memory:') {
    mkdirSync(dirname(path), { recursive: true });
  }

  const db = new Database(path, { create: true });
  db.exec('PRAGMA foreign_keys = ON;');
  if (path !== ':memory:') {
    db.exec('PRAGMA journal_mode = WAL;');
  }
  db.exec(SCHEMA);
  await seedDemoUsers(db);
  return db;
}

async function seedDemoUsers(db: Database): Promise<void> {
  const existing = db.query('SELECT COUNT(*) AS count FROM users').get() as {
    count: number;
  };
  if (existing.count > 0) return;

  const insert = db.prepare(`
    INSERT INTO users
      (username, password_hash, name, email, role, group_name,
       control_number, semester, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const createdAt = new Date().toISOString();
  for (const user of DEMO_USERS) {
    const passwordHash = await Bun.password.hash(user.password);
    insert.run(
      user.username,
      passwordHash,
      user.name,
      user.email,
      user.role,
      user.groupName,
      user.controlNumber,
      user.semester,
      createdAt,
    );
  }
}

export function publicUser(row: UserRow | User): User {
  return {
    id: row.id,
    username: row.username,
    name: row.name,
    email: row.email,
    role: row.role,
    group_name: row.group_name,
    control_number: row.control_number,
    semester: row.semester,
    created_at: row.created_at,
  };
}

export function findUserByUsername(
  db: Database,
  username: string,
): UserRow | null {
  const row = db
    .query('SELECT * FROM users WHERE username = ?')
    .get(username.trim().toLowerCase()) as UserRow | null;
  return row ?? null;
}

export function findUserById(db: Database, id: number): UserRow | null {
  const row = db.query('SELECT * FROM users WHERE id = ?').get(id) as
    | UserRow
    | null;
  return row ?? null;
}

export function listStudentGroups(db: Database): string[] {
  const rows = db
    .query(
      `SELECT DISTINCT group_name
       FROM users
       WHERE role = 'student' AND group_name IS NOT NULL AND group_name <> ''
       ORDER BY group_name ASC`,
    )
    .all() as { group_name: string }[];
  return rows.map((row) => row.group_name);
}

function mapAnnouncement(row: Record<string, unknown>): Announcement {
  const groupsCsv = row.groups_csv ? String(row.groups_csv) : '';
  const groups = groupsCsv
    ? groupsCsv.split('||').filter((group) => group.length > 0)
    : [];
  const audience = row.audience as Audience;

  return {
    id: Number(row.id),
    title: String(row.title),
    content: String(row.content),
    category: String(row.category),
    author_id: Number(row.author_id),
    author_name: String(row.author_name),
    audience,
    created_at: String(row.created_at),
    target_groups: groups,
    audience_label:
      audience === 'all' ? 'Todos los estudiantes' : groups.join(', '),
    has_attachment: false,
    attachment_url: null,
    attachment_key: null,
  };
}

export function getAnnouncement(
  db: Database,
  id: number,
): Announcement | null {
  const row = db
    .query(
      `SELECT a.*,
              (SELECT group_concat(group_name, '||')
               FROM announcement_groups g
               WHERE g.announcement_id = a.id) AS groups_csv
       FROM announcements a
       WHERE a.id = ?`,
    )
    .get(id) as Record<string, unknown> | null;
  return row ? mapAnnouncement(row) : null;
}

export function listAnnouncements(
  db: Database,
  user: User,
  options: ListAnnouncementsOptions = {},
): AnnouncementPage {
  const page = Math.max(1, Number(options.page) || 1);
  const limit = Math.min(50, Math.max(1, Number(options.limit) || 5));
  const offset = (page - 1) * limit;

  const where: string[] = [];
  const params: (string | number)[] = [];

  if (user.role === 'student') {
    where.push(
      `(a.audience = 'all' OR EXISTS (
         SELECT 1 FROM announcement_groups g2
         WHERE g2.announcement_id = a.id AND g2.group_name = ?
       ))`,
    );
    params.push(user.group_name ?? '__sin_grupo__');
  }

  if (options.category && options.category !== 'All') {
    where.push('a.category = ?');
    params.push(options.category);
  }

  const whereSql = where.length > 0 ? `WHERE ${where.join(' AND ')}` : '';
  const order = options.sort === 'oldest' ? 'ASC' : 'DESC';

  const totalRow = db
    .query(`SELECT COUNT(*) AS count FROM announcements a ${whereSql}`)
    .get(...params) as { count: number };

  const rows = db
    .query(
      `SELECT a.*,
              (SELECT group_concat(group_name, '||')
               FROM announcement_groups g
               WHERE g.announcement_id = a.id) AS groups_csv
       FROM announcements a
       ${whereSql}
       ORDER BY a.created_at ${order}, a.id ${order}
       LIMIT ? OFFSET ?`,
    )
    .all(...params, limit, offset) as Record<string, unknown>[];

  return {
    data: rows.map(mapAnnouncement),
    pagination: {
      currentPage: page,
      pageSize: limit,
      totalItems: totalRow.count,
      totalPages: Math.ceil(totalRow.count / limit),
    },
  };
}

export function createAnnouncement(
  db: Database,
  author: User,
  input: CreateAnnouncementInput,
): Announcement {
  const createdAt = new Date().toISOString();
  const groups = input.audience === 'groups' ? input.groups : [];

  const insertAnnouncement = db.prepare(`
    INSERT INTO announcements
      (title, content, category, author_id, author_name, audience, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `);
  const insertGroup = db.prepare(`
    INSERT INTO announcement_groups (announcement_id, group_name)
    VALUES (?, ?)
  `);

  const transaction = db.transaction(() => {
    const result = insertAnnouncement.run(
      input.title,
      input.content,
      input.category,
      author.id,
      author.name,
      input.audience,
      createdAt,
    );
    const id = Number(result.lastInsertRowid);
    for (const group of groups) {
      insertGroup.run(id, group);
    }
    return id;
  });

  const id = transaction();
  return getAnnouncement(db, id)!;
}

export function updateAnnouncement(
  db: Database,
  id: number,
  input: CreateAnnouncementInput,
): Announcement | null {
  const existing = getAnnouncement(db, id);
  if (!existing) return null;

  const groups = input.audience === 'groups' ? input.groups : [];
  const update = db.prepare(`
    UPDATE announcements
    SET title = ?, content = ?, category = ?, audience = ?
    WHERE id = ?
  `);
  const deleteGroups = db.prepare(
    'DELETE FROM announcement_groups WHERE announcement_id = ?',
  );
  const insertGroup = db.prepare(`
    INSERT INTO announcement_groups (announcement_id, group_name)
    VALUES (?, ?)
  `);

  const transaction = db.transaction(() => {
    update.run(input.title, input.content, input.category, input.audience, id);
    deleteGroups.run(id);
    for (const group of groups) {
      insertGroup.run(id, group);
    }
  });
  transaction();

  return getAnnouncement(db, id);
}

export function deleteAnnouncement(
  db: Database,
  id: number,
): Announcement | null {
  const existing = getAnnouncement(db, id);
  if (!existing) return null;
  db.query('DELETE FROM announcements WHERE id = ?').run(id);
  return existing;
}

export function resetDemo(db: Database): void {
  db.transaction(() => {
    db.exec('DELETE FROM announcement_groups;');
    db.exec('DELETE FROM announcements;');
    db.exec("DELETE FROM sqlite_sequence WHERE name = 'announcements';");
  })();
}
