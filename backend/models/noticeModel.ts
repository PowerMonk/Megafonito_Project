import {
  execute,
  queryAll,
  safeQuery,
  safeQueryAll,
  safeExecute,
  queryOne,
  DatabaseRow,
  paginatedQuery,
} from "../db/dbMod.ts";

// In your noticeModel.ts, you can now use it like this:
export interface Notice extends DatabaseRow {
  id: number;
  title: string;
  content: string;
  user_id: number;
  created_at: string;
  // Add any other notice-specific fields
}

export interface PaginatedResponse<T extends DatabaseRow> {
  data: T[];
  pagination: {
    currentPage: number;
    pageSize: number;
    totalItems: number;
    totalPages: number;
  };
}

export function createNotice(title: string, content: string, userId: number) {
  const query = `
      INSERT INTO notices (title, content, user_id) VALUES (?, ?, ?);
    `;
  return safeExecute(() => execute(query, title, content, userId));
}

export function getNoticesByUser(userId: number) {
  const query = `
      SELECT * FROM notices WHERE user_id = ?;
    `;
  return safeQueryAll(() => queryAll(query, userId));
}
export function getNoticeByUserIdAndNoticeId(userId: number, noticeId: number) {
  const query = `
      SELECT * FROM notices WHERE user_id = ? AND id = ?;
    `;
  // return safeQueryAll(() => queryAll(query, userId, noticeId));
  return safeQuery(() => queryOne(query, userId, noticeId));
}

export function getNoticesByNoticeId(noticeId: number) {
  const query = `
      SELECT * FROM notices WHERE id = ?;
    `;
  return safeQuery(() => queryOne(query, noticeId));
}

export function updateNotice(noticeId: number, title: string, content: string) {
  const query = `
      UPDATE notices SET title = ?, content = ? WHERE id = ?;
    `;
  return safeExecute(() => execute(query, title, content, noticeId));
}

export function deleteNotice(noticeId: number) {
  const query = `
      DELETE FROM notices WHERE id = ?;
    `;
  return safeExecute(() => execute(query, noticeId));
}
export function getAllNotices() {
  const query = `
      SELECT * FROM notices;
    `;
  return safeQueryAll(() => queryAll(query));
}

// DESC makes them come from last to first
export function getPaginatedNotices(
  page: number = 1,
  limit: number = 12
): PaginatedResponse<Notice> {
  const query = `
    SELECT n.*, u.username as author 
    FROM notices n 
    LEFT JOIN users u ON n.user_id = u.id 
    ORDER BY n.created_at DESC
  `;

  const { data, total } = paginatedQuery(query, page, limit);

  return {
    // Since Notice inherits from DatabaseRow, the conversion is safe.
    data: data as Notice[],
    pagination: {
      currentPage: page,
      pageSize: limit,
      totalItems: total,
      totalPages: Math.ceil(total / limit),
    },
  };
}
