import {
  queryAll,
  queryOne,
  execute,
  paginatedQuery,
} from "../db/postgres/dbQueries.ts";

// Update notice interface to match new schema
export interface Notice {
  id: number;
  title: string;
  content: string;
  author_id: number;
  category: string;
  min_role_level: number;
  target_groups?: number[];
  target_classes?: number[];
  has_attachment: boolean;
  attachment_url?: string;
  attachment_key?: string;
  created_at: Date;
  publish_at?: Date;
  expiry_date?: Date;
  author_name?: string; // Joined from users table
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    currentPage: number;
    pageSize: number;
    totalItems: number;
    totalPages: number;
  };
}

export async function getAllNotices(): Promise<Notice[]> {
  const query = `
    SELECT n.*, u.name as author_name 
    FROM notices n 
    LEFT JOIN users u ON n.author_id = u.id
    ORDER BY n.created_at DESC
  `;

  return (await queryAll(query)) as Notice[];
}

// Get paginated notices with filters
export async function getPaginatedNotices(
  page: number = 1,
  limit: number = 12,
  category?: string,
  hasAttachment?: boolean,
  minRoleLevel?: number
): Promise<PaginatedResponse<Notice>> {
  let baseQuery = `
    SELECT n.*, u.name as author_name 
    FROM notices n 
    LEFT JOIN users u ON n.author_id = u.id
    WHERE ($4::INTEGER IS NULL OR n.min_role_level <= $4)
  `;

  const params: any[] = [];

  // Add category filter if provided
  if (category) {
    baseQuery += ` AND n.category = $1`;
    params.push(category);
  } else {
    params.push(null);
  }

  // Add has_attachment filter if provided
  if (hasAttachment !== undefined) {
    baseQuery += ` AND n.has_attachment = $2`;
    params.push(hasAttachment);
  } else {
    params.push(null);
  }

  // Add current date filter for published notices
  baseQuery += ` AND (n.publish_at IS NULL OR n.publish_at <= CURRENT_TIMESTAMP)`;

  // Add expiry date filter
  baseQuery += ` AND (n.expiry_date IS NULL OR n.expiry_date > CURRENT_TIMESTAMP)`;

  // Add null for the third parameter
  params.push(null);

  // Add min role level
  params.push(minRoleLevel);

  // Add ORDER BY clause
  baseQuery += ` ORDER BY n.created_at DESC`;

  // Execute paginated query
  const { data, total } = await paginatedQuery(baseQuery, page, limit, params);

  // Calculate total pages
  const totalPages = Math.ceil(total / limit);

  // Return paginated response
  return {
    data: data as Notice[],
    pagination: {
      currentPage: page,
      pageSize: limit,
      totalItems: total,
      totalPages,
    },
  };
}

// Create notice
export async function createNotice(
  title: string,
  content: string,
  authorId: number,
  category: string = "General",
  minRoleLevel: number = 1,
  targetGroups: number[] = [],
  targetClasses: number[] = [],
  hasAttachment: boolean = false,
  attachmentUrl?: string,
  attachmentKey?: string,
  publishAt?: Date,
  expiryDate?: Date
): Promise<Notice> {
  const query = `
    INSERT INTO notices (
      title, content, author_id, category, min_role_level,
      target_groups, target_classes, has_attachment, 
      attachment_url, attachment_key, publish_at, expiry_date
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
    RETURNING *
  `;

  const result = (await queryOne(query, [
    title,
    content,
    authorId,
    category,
    minRoleLevel,
    targetGroups,
    targetClasses,
    hasAttachment,
    attachmentUrl,
    attachmentKey,
    publishAt,
    expiryDate,
  ])) as Notice;

  return result;
}

// Get notice by ID
export async function getNoticeById(noticeId: number): Promise<Notice | null> {
  try {
    const query = `
      SELECT n.*, u.name as author_name 
      FROM notices n 
      LEFT JOIN users u ON n.author_id = u.id 
      WHERE n.id = $1
    `;

    return (await queryOne(query, [noticeId])) as Notice;
  } catch (error) {
    console.error(`Error getting notice ${noticeId}:`, error);
    return null;
  }
}

// Get notices by user ID
export async function getNoticesByAuthorId(
  authorId: number,
  page: number = 1,
  limit: number = 12
): Promise<PaginatedResponse<Notice>> {
  const baseQuery = `
    SELECT n.*, u.name as author_name 
    FROM notices n 
    LEFT JOIN users u ON n.author_id = u.id 
    WHERE n.author_id = $1
    ORDER BY n.created_at DESC
  `;

  // Execute paginated query
  const { data, total } = await paginatedQuery(baseQuery, page, limit, [
    authorId,
  ]);

  // Calculate total pages
  const totalPages = Math.ceil(total / limit);

  // Return paginated response
  return {
    data: data as Notice[],
    pagination: {
      currentPage: page,
      pageSize: limit,
      totalItems: total,
      totalPages,
    },
  };
}

// Update notice
export async function updateNotice(
  noticeId: number,
  updateData: Partial<Notice> // Partial makes all fields optional
): Promise<boolean> {
  // Build dynamic update query
  let query = "UPDATE notices SET ";
  const setClauses: string[] = [];
  const values: any[] = [];
  let paramCount = 1;

  // Add each field to update
  for (const [key, value] of Object.entries(updateData)) {
    // Skip id field
    if (key === "id") continue;

    setClauses.push(`${key} = $${paramCount}`);
    values.push(value);
    paramCount++;
  }

  // Complete the query
  query += setClauses.join(", ");
  query += ` WHERE id = $${paramCount} RETURNING *`;
  values.push(noticeId);

  try {
    (await queryOne(query, values)) as Notice;
    return true;
  } catch (error) {
    console.error(`Error updating notice ${noticeId}:`, error);
    return false;
  }
}

// Delete notice
export async function deleteNotice(noticeId: number): Promise<boolean> {
  try {
    const query = "DELETE FROM notices WHERE id = $1";
    await execute(query, [noticeId]);
    return true;
  } catch (error) {
    console.error(`Error deleting notice ${noticeId}:`, error);
    return false;
  }
}
