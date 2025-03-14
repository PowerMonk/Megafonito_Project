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

// Notice interface with added file-related fields
export interface Notice extends DatabaseRow {
  id: number;
  title: string;
  content: string;
  user_id: number;
  category: string;
  has_file: boolean;
  file_url: string | null;
  file_key: string | null; // Added this field to store S3 keys
  created_at: string;
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

export function createNotice(
  title: string,
  content: string,
  userId: number,
  category: string = "Clases",
  hasFile: boolean = false,
  fileUrl: string | null = null,
  fileKey: string | null = null // Add file key parameter
) {
  const query = `
    INSERT INTO notices (title, content, user_id, category, has_file, file_url, file_key) 
    VALUES (?, ?, ?, ?, ?, ?, ?);
  `;
  return safeExecute(() =>
    execute(
      query,
      title,
      content,
      userId,
      category,
      hasFile ? 1 : 0,
      fileUrl,
      fileKey
    )
  );
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

// export function updateNotice(noticeId: number, title: string, content: string) {
//   const query = `
//       UPDATE notices SET title = ?, content = ? WHERE id = ?;
//     `;
//   return safeExecute(() => execute(query, title, content, noticeId));
// }

// Update the updateNotice function to include new fields
export function updateNotice(
  noticeId: number,
  title: string,
  content: string,
  category: string,
  hasFile?: boolean,
  fileUrl?: string,
  fileKey?: string // Add file key parameter
) {
  let query = ` UPDATE notices SET title = ?, content = ? WHERE id = ?`;
  const params = [title, content, noticeId];

  if (category !== undefined) {
    query += `, category = ?`;
    params.push(category);
  }

  if (hasFile !== undefined) {
    query += `, has_file = ?`;
    params.push(hasFile ? 1 : 0);
  }

  if (fileUrl !== undefined) {
    query += `, file_url = ?`;
    params.push(fileUrl);
  }
  if (fileKey !== undefined) {
    query += `, file_key = ?`;
    params.push(fileKey);
  }

  return safeExecute(() => execute(query, ...params));
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
// export function getPaginatedNotices(
//   page: number = 1,
//   limit: number = 12
// ): PaginatedResponse<Notice> {
//   const query = `
//     SELECT n.*, u.username as author
//     FROM notices n
//     LEFT JOIN users u ON n.user_id = u.id
//     ORDER BY n.created_at DESC
//   `;

//   const { data, total } = paginatedQuery(query, page, limit);

//   return {
//     // Since Notice inherits from DatabaseRow, the conversion is safe.
//     data: data as Notice[],
//     pagination: {
//       currentPage: page,
//       pageSize: limit,
//       totalItems: total,
//       totalPages: Math.ceil(total / limit),
//     },
//   };
// }
// Update the getPaginatedNotices function to include filters
export function getPaginatedNotices(
  page: number = 1,
  limit: number = 12,
  category?: string,
  hasFiles?: boolean
): PaginatedResponse<Notice> {
  let baseQuery = `
    SELECT n.*, u.username as author 
    FROM notices n 
    LEFT JOIN users u ON n.user_id = u.id 
  `;

  const whereConditions: string[] = [];
  const queryParams: (string | number | null | boolean)[] = [];

  if (category) {
    whereConditions.push(`n.category = ?`);
    queryParams.push(category);
  }

  if (hasFiles !== undefined) {
    whereConditions.push(`n.has_file = ?`);
    queryParams.push(hasFiles ? 1 : 0);
  }

  if (whereConditions.length > 0) {
    baseQuery += ` WHERE ${whereConditions.join(" AND ")}`;
  }

  baseQuery += ` ORDER BY n.created_at DESC`;

  const { data, total } = paginatedQuery(
    baseQuery,
    page,
    limit,
    ...queryParams
  );

  return {
    data: data as Notice[],
    pagination: {
      currentPage: page,
      pageSize: limit,
      totalItems: total,
      totalPages: Math.ceil(total / limit),
    },
  };
}
