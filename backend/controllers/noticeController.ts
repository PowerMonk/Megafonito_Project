import { RouterContext } from "jsr:@oak/oak";
import {
  getPaginatedNotices,
  createNotice,
  getNoticeById,
  getNoticesByAuthorId,
  updateNotice,
  deleteNotice,
  getUserById,
  getAllNotices,
} from "../models/modelsMod.ts";
import { UserRole } from "../auth/authMod.ts";
import { getRoleLevelFromName } from "./controllersMod.ts";

// Create notice handler
export async function createNoticeHandler(ctx: RouterContext<string>) {
  const user = ctx.state.user;
  if (!user || !user.id || !user.role) {
    ctx.response.status = 401;
    ctx.response.body = { error: "Authentication required" };
    return;
  }
  console.log(user.role);
  if (
    ctx.state.user.role !== UserRole.ADMIN &&
    ctx.state.user.role !== UserRole.TEACHER
  ) {
    ctx.response.status = 403;
    ctx.response.body = { error: "Permission denied" };
    return;
  }

  // const roleLevel = getRoleLevelFromName(user.role);

  try {
    const requestBody = await ctx.request.body.json();
    const {
      title,
      content,
      category = "General",
      // Lowest role level that can view the notice
      min_role_level = 1,
      targetGroups = [],
      targetClasses = [],
      hasAttachment = false,
      attachmentUrl = null,
      attachmentKey = null,
      publishAt,
      expiryDate,
    } = requestBody;

    if (!title || !content || !category) {
      ctx.response.status = 400;
      ctx.response.body = {
        error: "Title, content and category are required",
      };
      return;
    }

    // Parse dates if provided
    let parsedPublishAt = undefined;
    let parsedExpiryDate = undefined;

    if (publishAt) {
      parsedPublishAt = new Date(publishAt);
    }

    if (expiryDate) {
      parsedExpiryDate = new Date(expiryDate);
    }

    const notice = await createNotice(
      title,
      content,
      user.id, // Not needed in the request body, get from user context
      category,
      // lowest role level that can view the notice
      min_role_level, // default to 1, could not be added in the request body
      targetGroups,
      targetClasses,
      hasAttachment,
      attachmentUrl,
      attachmentKey,
      parsedPublishAt,
      parsedExpiryDate
    );

    ctx.response.status = 201;
    ctx.response.body = { message: "Notice created successfully", notice };
  } catch (error) {
    console.error("Error creating notice:", error);
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to create notice" };
  }
}

export async function getNoticesHandler(ctx: RouterContext<string>) {
  try {
    const url = new URL(ctx.request.url);
    const page = parseInt(url.searchParams.get("page") || "1", 10);
    const limit = parseInt(url.searchParams.get("limit") || "12", 10);
    const category = url.searchParams.get("category") || undefined;

    // Parse hasAttachment param
    const hasAttachmentParam = url.searchParams.get("hasAttachment");
    let hasAttachment: boolean | undefined = undefined;
    if (hasAttachmentParam === "true") {
      hasAttachment = true;
    } else if (hasAttachmentParam === "false") {
      hasAttachment = false;
    }

    // Parse date filter parameters
    // Parse date filter parameters
    const startDate = url.searchParams.get("startDate")
      ? new Date(Date.parse(url.searchParams.get("startDate")!))
          .toISOString()
          .slice(0, 19)
          .replace("T", " ") + "-06"
      : undefined;

    const endDate = url.searchParams.get("endDate")
      ? new Date(Date.parse(url.searchParams.get("endDate")!))
          .toISOString()
          .slice(0, 19)
          .replace("T", " ") + "-06"
      : undefined;

    // Show future notices parameter (defaults to false)
    const includeFuture = url.searchParams.get("includeFuture") === "true";

    // Show expired notices parameter (defaults to false)
    const includeExpired = url.searchParams.get("includeExpired") === "true";

    const user = ctx.state.user;
    if (!user || !user.id || !user.role) {
      ctx.response.status = 401;
      ctx.response.body = { error: "Authentication required" };
      return;
    }

    // Get user role level
    const roleLevel = getRoleLevelFromName(user.role);

    console.log("Getting notices with filters:", {
      page,
      limit,
      category,
      hasAttachment,
      minRoleLevel: roleLevel,
      startDate,
      endDate,
      includeFuture,
      includeExpired,
    });

    const result = await getPaginatedNotices(
      page,
      limit,
      category,
      hasAttachment,
      roleLevel,
      startDate,
      endDate,
      includeFuture,
      includeExpired
    );

    ctx.response.status = 200;
    ctx.response.body = {
      data: result.data,
      pagination: result.pagination,
    };
  } catch (error) {
    console.error("Error getting notices:", error);
    ctx.response.status = 500;
    ctx.response.body = {
      error: "Failed to retrieve notices",
      details: error,
    };
  }
}

// Get all notices (admin only)
export async function getAllNoticesHandler(ctx: RouterContext<string>) {
  try {
    const user = ctx.state.user;
    if (!user || !user.id || !user.role) {
      ctx.response.status = 401;
      ctx.response.body = { error: "Authentication required" };
      return;
    }

    // Only allow admins to access all notices
    if (user.role !== UserRole.ADMIN) {
      ctx.response.status = 403;
      ctx.response.body = {
        error: "Permission denied. Admin access required.",
      };
      return;
    }

    const notices = await getAllNotices();

    ctx.response.status = 200;
    ctx.response.body = notices;
  } catch (error) {
    console.error("Error getting all notices:", error);
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to retrieve notices" };
  }
}

// Get notices by user ID
export async function getNoticesByUserHandler(ctx: RouterContext<string>) {
  try {
    const userId = parseInt(ctx.params.userId || "0");
    if (isNaN(userId) || userId <= 0) {
      ctx.response.status = 400;
      ctx.response.body = { error: "Invalid user ID" };
      return;
    }

    const user = await getUserById(userId);
    if (!user) {
      ctx.response.status = 404;
      ctx.response.body = { error: "User not found" };
      return;
    }

    const url = new URL(ctx.request.url);
    const page = parseInt(url.searchParams.get("page") || "1", 10);
    const limit = parseInt(url.searchParams.get("limit") || "12", 10);

    const notices = await getNoticesByAuthorId(userId, page, limit);

    ctx.response.status = 200;
    ctx.response.body = {
      data: notices.data,
      pagination: notices.pagination,
    };
  } catch (error) {
    console.error("Error getting user notices:", error);
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to retrieve user notices" };
  }
}

// Get single notice by ID
export async function getNoticeByIdHandler(ctx: RouterContext<string>) {
  try {
    const noticeId = parseInt(ctx.params.noticeId || "0");
    if (isNaN(noticeId) || noticeId <= 0) {
      ctx.response.status = 400;
      ctx.response.body = { error: "Invalid notice ID" };
      return;
    }

    const notice = await getNoticeById(noticeId);
    if (!notice) {
      ctx.response.status = 404;
      ctx.response.body = { error: "Notice not found" };
      return;
    }

    ctx.response.status = 200;
    ctx.response.body = notice;
  } catch (error) {
    console.error("Error getting notice:", error);
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to retrieve notice" };
  }
}

// Update notice
export async function updateNoticeHandler(ctx: RouterContext<string>) {
  const user = ctx.state.user;
  if (!user || !user.id) {
    ctx.response.status = 401;
    ctx.response.body = { error: "Authentication required" };
    return;
  }

  try {
    const noticeId = parseInt(ctx.params.noticeId || "0");
    if (isNaN(noticeId) || noticeId <= 0) {
      ctx.response.status = 400;
      ctx.response.body = { error: "Invalid notice ID" };
      return;
    }

    // Check if notice exists and user has permission
    const existingNotice = await getNoticeById(noticeId);
    if (!existingNotice) {
      ctx.response.status = 404;
      ctx.response.body = { error: "Notice not found" };
      return;
    }

    // Only author or admin can update
    if (existingNotice.author_id !== user.id && user.role_name !== "Admin") {
      ctx.response.status = 403;
      ctx.response.body = { error: "Permission denied" };
      return;
    }

    const requestBody = await ctx.request.body.json();

    // Handle date fields
    if (requestBody.publishAt) {
      requestBody.publish_at = new Date(requestBody.publishAt);
      delete requestBody.publishAt;
    }

    if (requestBody.expiryDate) {
      requestBody.expiry_date = new Date(requestBody.expiryDate);
      delete requestBody.expiryDate;
    }

    // Convert hasAttachment to has_attachment
    if (requestBody.hasAttachment !== undefined) {
      requestBody.has_attachment = requestBody.hasAttachment;
      delete requestBody.hasAttachment;
    }

    // Convert attachmentUrl to attachment_url
    if (requestBody.attachmentUrl !== undefined) {
      requestBody.attachment_url = requestBody.attachmentUrl;
      delete requestBody.attachmentUrl;
    }

    // Convert attachmentKey to attachment_key
    if (requestBody.attachmentKey !== undefined) {
      requestBody.attachment_key = requestBody.attachmentKey;
      delete requestBody.attachmentKey;
    }

    const success = await updateNotice(noticeId, requestBody);

    if (success) {
      const updatedNotice = await getNoticeById(noticeId);
      ctx.response.status = 200;
      ctx.response.body = updatedNotice;
    } else {
      ctx.response.status = 500;
      ctx.response.body = { error: "Failed to update notice" };
    }
  } catch (error) {
    console.error("Error updating notice:", error);
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to update notice" };
  }
}

// Delete notice
export async function deleteNoticeHandler(ctx: RouterContext<string>) {
  const user = ctx.state.user;
  if (!user || !user.id) {
    ctx.response.status = 401;
    ctx.response.body = { error: "Authentication required" };
    return;
  }

  try {
    const noticeId = parseInt(ctx.params.noticeId || "0");
    if (isNaN(noticeId) || noticeId <= 0) {
      ctx.response.status = 400;
      ctx.response.body = { error: "Invalid notice ID" };
      return;
    }

    // Check if notice exists and user has permission
    const existingNotice = await getNoticeById(noticeId);
    if (!existingNotice) {
      ctx.response.status = 404;
      ctx.response.body = { error: "Notice not found" };
      return;
    }

    // Only author or admin can delete
    if (existingNotice.author_id !== user.id && user.role_name !== "Admin") {
      ctx.response.status = 403;
      ctx.response.body = { error: "Permission denied" };
      return;
    }

    const success = await deleteNotice(noticeId);

    if (success) {
      ctx.response.status = 200;
      ctx.response.body = { message: "Notice deleted successfully" };
    } else {
      ctx.response.status = 500;
      ctx.response.body = { error: "Failed to delete notice" };
    }
  } catch (error) {
    console.error("Error deleting notice:", error);
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to delete notice" };
  }
}
