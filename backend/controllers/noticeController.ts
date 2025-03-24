import { RouterContext } from "jsr:@oak/oak";
import {
  getPaginatedNotices,
  createNotice,
  getNoticeById,
  getNoticesByAuthorId,
  updateNotice,
  deleteNotice,
  getUserById,
} from "../models/modelsMod.ts";

// Create notice handler
export async function createNoticeHandler(ctx: RouterContext<string>) {
  const user = ctx.state.user;
  if (!user || !user.id) {
    ctx.response.status = 401;
    ctx.response.body = { error: "Authentication required" };
    return;
  }

  try {
    const requestBody = await ctx.request.body.json();
    const {
      title,
      content,
      category = "General",
      minRoleLevel = 1,
      targetGroups = [],
      targetClasses = [],
      hasAttachment = false,
      attachmentUrl = null,
      attachmentKey = null,
      publishAt,
      expiryDate,
    } = requestBody;

    if (!title || !content) {
      ctx.response.status = 400;
      ctx.response.body = { error: "Title and content are required" };
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
      user.id,
      category,
      minRoleLevel,
      targetGroups,
      targetClasses,
      hasAttachment,
      attachmentUrl,
      attachmentKey,
      parsedPublishAt,
      parsedExpiryDate
    );

    ctx.response.status = 201;
    ctx.response.body = notice;
  } catch (error) {
    console.error("Error creating notice:", error);
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to create notice" };
  }
}

// Get all notices (paginated, with filters)
export async function getNoticesHandler(ctx: RouterContext<string>) {
  try {
    const url = new URL(ctx.request.url);
    const page = parseInt(url.searchParams.get("page") || "1", 10);
    const limit = parseInt(url.searchParams.get("limit") || "12", 10);
    const category = url.searchParams.get("category") || undefined;

    // Update parameter name to match the new schema
    const hasAttachmentParam = url.searchParams.get("hasAttachment");
    const hasAttachment =
      hasAttachmentParam === "true"
        ? true
        : hasAttachmentParam === "false"
        ? false
        : undefined;

    // Get user role level from auth context
    const minRoleLevel = ctx.state.user?.roleLevel || 1;

    const result = await getPaginatedNotices(
      page,
      limit,
      category,
      hasAttachment,
      minRoleLevel
    );

    ctx.response.status = 200;
    ctx.response.body = {
      data: result.data,
      pagination: result.pagination,
    };
  } catch (error) {
    console.error("Error getting notices:", error);
    ctx.response.status = 500;
    ctx.response.body = { error: "Failed to retrieve notices" };
  }
}

// Get notices by user ID
export async function getNoticesByUserHandler(ctx: RouterContext<string>) {
  try {
    const userId = parseInt(ctx.params.id || "0");
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
    const noticeId = parseInt(ctx.params.id || "0");
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
    const noticeId = parseInt(ctx.params.id || "0");
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
    const noticeId = parseInt(ctx.params.id || "0");
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
