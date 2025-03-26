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

// Create notice
export async function createNotice(
  title: string,
  content: string,
  authorId: number,
  category: string = "General",
  min_role_level: number = 1,
  targetGroups: number[] = [], // Array of group IDs
  targetClasses: number[] = [], // Array of class IDs
  hasAttachment: boolean = false,
  attachmentUrl?: string,
  attachmentKey?: string,
  publishAt?: Date,
  expiryDate?: Date
): Promise<Notice> {
  try {
    // Sanitize arrays - ensure they're valid PostgreSQL integer arrays
    const safeTargetGroups =
      targetGroups && targetGroups.length > 0
        ? targetGroups.filter((id) => typeof id === "number")
        : [];

    const safeTargetClasses =
      targetClasses && targetClasses.length > 0
        ? targetClasses.filter((id) => typeof id === "number")
        : [];

    console.log("Creating notice with params:", {
      title,
      content,
      authorId,
      category,
      min_role_level,
      safeTargetGroups,
      safeTargetClasses,
      hasAttachment,
      attachmentUrl,
      attachmentKey,
      publishAt,
      expiryDate,
    });

    const query = `
      INSERT INTO notices (
        title, content, author_id, category, min_role_level,
        target_groups, target_classes, has_attachment, 
        attachment_url, attachment_key, publish_at, expiry_date
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING *
    `;

    const newNotice = await queryOne(query, [
      title,
      content,
      authorId,
      category,
      min_role_level,
      safeTargetGroups,
      safeTargetClasses,
      hasAttachment,
      attachmentUrl,
      attachmentKey,
      publishAt,
      expiryDate,
    ]);

    return newNotice as Notice;
  } catch (error) {
    console.error("Error creating notice:", error);
    throw error;
  }
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
  minRoleLevel?: number,
  startDate?: string,
  endDate?: string,
  includeFuture: boolean = false,
  includeExpired: boolean = false
): Promise<PaginatedResponse<Notice>> {
  // Start with a basic query
  let baseQuery = `
    SELECT n.*, u.name as author_name 
    FROM notices n 
    LEFT JOIN users u ON n.author_id = u.id
    WHERE 1=1
  `;

  const params: any[] = [];

  // Apply role level security filter
  if (minRoleLevel !== undefined) {
    baseQuery += ` AND n.min_role_level <= $${params.length + 1}`;
    params.push(minRoleLevel);
  }

  // Apply category filter only if provided
  if (category && category !== "All") {
    baseQuery += ` AND n.category = $${params.length + 1}`;
    params.push(category);
  }

  // Apply attachment filter only if specifically requested
  if (hasAttachment === true) {
    baseQuery += ` AND n.has_attachment = true`;
  } else if (hasAttachment === false) {
    baseQuery += ` AND n.has_attachment = false`;
  }

  // Apply date range filter if provided
  if (startDate) {
    baseQuery += ` AND n.created_at >= $${params.length + 1}`;
    params.push(startDate);
  }

  if (endDate) {
    baseQuery += ` AND n.created_at <= $${params.length + 1}`;
    params.push(endDate);
  }

  // Add published notices filter (unless includeFuture is true)
  if (!includeFuture) {
    baseQuery += ` AND (n.publish_at IS NULL OR n.publish_at <= CURRENT_TIMESTAMP)`;
  }

  // Add expiry filter (unless includeExpired is true)
  if (!includeExpired) {
    baseQuery += ` AND (n.expiry_date IS NULL OR n.expiry_date > CURRENT_TIMESTAMP)`;
  }

  // Add ORDER BY clause
  baseQuery += ` ORDER BY n.created_at DESC`;

  // console.log("Executing query:", baseQuery, "with params:", params);

  // Execute paginated query
  const { data, total } = await paginatedQuery(baseQuery, page, limit, params);
  // Calculate total pages
  const totalPages = Math.ceil(total / limit);

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
  updateData: Partial<Notice> // makes all fields optional
): Promise<boolean> {
  // Build dynamic update query
  let query = "UPDATE notices SET ";
  const setClauses: string[] = [];
  const values: any[] = [];
  let paramCount = 1;

  console.log("Updating notice with data:", updateData);

  // Add each field to update
  for (const [key, value] of Object.entries(updateData)) {
    // Skip id field
    if (key === "id") continue;

    // For arrays (target_groups, target_classes), ensure they're properly formatted
    if (Array.isArray(value)) {
      // Make sure array only contains numbers
      const safeArray = value.filter((item) => typeof item === "number");
      setClauses.push(`"${key}" = $${paramCount}`);
      values.push(safeArray);
    }
    // Handle date objects
    else if (value instanceof Date) {
      setClauses.push(`"${key}" = $${paramCount}`);
      values.push(value);
    }
    // Handle all other types
    else {
      setClauses.push(`"${key}" = $${paramCount}`);
      values.push(value);
    }

    paramCount++;
  }

  // If no fields to update, return early
  if (setClauses.length === 0) {
    console.log("No fields to update for notice", noticeId);
    return true;
  }

  // Complete the query
  query += setClauses.join(", ");
  query += ` WHERE id = $${paramCount} RETURNING *`;
  values.push(noticeId);

  console.log("Executing update query:", query);
  console.log("With values:", values);

  try {
    const result = await queryOne(query, values);
    console.log("Update result:", result);
    return true;
  } catch (error) {
    console.error(`Error updating notice ${noticeId}:`, error);
    return false;
  }
}
// Delete notice
export async function deleteNotice(noticeId: number): Promise<boolean> {
  try {
    console.log(`Attempting to delete notice with ID: ${noticeId}`);
    const query = "DELETE FROM notices WHERE id = $1";
    const result = await execute(query, [noticeId]);

    if (result > 0) {
      console.log(`Notice with ID ${noticeId} deleted.`);
      return true;
    } else {
      console.log(`No notice found with ID ${noticeId}.`);
      return false;
    }
  } catch (error) {
    console.error(`Error deleting notice ${noticeId}:`, error);
    return false;
  }
}
