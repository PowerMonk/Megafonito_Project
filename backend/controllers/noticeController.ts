import { RouterContext } from "@oak/oak";
import {
  createNotice,
  getNoticesByUser,
  updateNotice,
  deleteNotice,
  getNoticeByUserIdAndNoticeId,
  getNoticesByNoticeId,
  getAllNotices,
  getPaginatedNotices,
} from "../models/modelsMod.ts";
import {
  checkNoticeExistsByNoticeId,
  checkNoticeExistsByUserId,
} from "../utils/utilsMod.ts";
import { getS3Service } from "../proxy/proxyMod.ts";

export async function createNoticeHandler(ctx: RouterContext<string>) {
  const { title, content, userId, category, hasFile, fileUrl, fileKey } =
    await ctx.request.body.json();

  // Handle different possible formats of hasFile
  let hasFileValue;
  if (
    hasFile === true ||
    hasFile === "true" ||
    hasFile === 1 ||
    hasFile === "1"
  ) {
    hasFileValue = 1;
  } else {
    hasFileValue = 0;
  }

  console.log("hasFileValue after conversion:", hasFileValue);

  // These will throw if not found
  checkNoticeExistsByUserId(userId);

  // This guard clause is not needed since the  function will throw an error if the user is not found
  // if (!user) return;

  createNotice(
    title,
    content,
    userId,
    category,
    hasFileValue,
    fileUrl,
    fileKey
  );
  ctx.response.status = 201;
  ctx.response.body = {
    message: `Notice created successfully! at ${new Date()}`,
  };
}

export function getNoticesByUserHandler(ctx: RouterContext<string>) {
  const userId = +ctx.params.userId;

  checkNoticeExistsByUserId(userId);

  const noticesObtainedById = getNoticesByUser(userId);
  ctx.response.body = noticesObtainedById;
}

export function getNoticeByUserAndIdHandler(ctx: RouterContext<string>) {
  const userId = +ctx.params.userId;
  const noticeId = +ctx.params.noticeId;

  checkNoticeExistsByUserId(userId);
  checkNoticeExistsByNoticeId(noticeId);

  const noticeObtainedByUserAndById = getNoticeByUserIdAndNoticeId(
    userId,
    noticeId
  );

  ctx.response.body = noticeObtainedByUserAndById;
}

export function getNoticesByNoticeIdHandler(ctx: RouterContext<string>) {
  const noticeId = +ctx.params.noticeId;

  checkNoticeExistsByNoticeId(noticeId);

  const noticesObtainedByNoticeId = getNoticesByNoticeId(noticeId);
  ctx.response.body = noticesObtainedByNoticeId;
}

export async function noticeUpdaterHandler(ctx: RouterContext<string>) {
  const noticeId = +ctx.params.noticeId;
  const { title, content, category, hasFile, fileUrl, fileKey } =
    await ctx.request.body.json();

  checkNoticeExistsByNoticeId(noticeId);

  // Update notice with all fields, including file information
  updateNotice(noticeId, title, content, category, hasFile, fileUrl, fileKey);
  ctx.response.status = 200;
  ctx.response.body = {
    message: `Notice updated successfully! at ${new Date()}`,
  };
}

export async function noticeDeleterHandler(ctx: RouterContext<string>) {
  const noticeId = +ctx.params.noticeId;

  checkNoticeExistsByNoticeId(noticeId);

  // Get notice to check if it has attached files
  const notice = getNoticesByNoticeId(noticeId);

  // If notice has files, delete them from S3
  if (notice && notice.has_file && notice.file_key) {
    try {
      const fileKey = String(notice.file_key);
      const s3Service = getS3Service();
      await s3Service.deleteFile(fileKey);
    } catch (error) {
      console.error("Failed to delete file from S3:", error);
      // Continue with notice deletion even if file deletion fails
    }
  }

  deleteNotice(noticeId);
  ctx.response.status = 200;
  ctx.response.body = {
    message: `Notice deleted successfully! at ${new Date()}`,
  };
}

export function getAllNoticesHandler(ctx: RouterContext<string>) {
  const allNotices = getAllNotices();
  ctx.response.body = allNotices;
}

export function getPaginatedNoticesHandler(ctx: RouterContext<string>) {
  // Parse query parameters
  const page = parseInt(ctx.request.url.searchParams.get("page") ?? "1");
  const limit = parseInt(ctx.request.url.searchParams.get("limit") ?? "5");
  const category = ctx.request.url.searchParams.get("category") || undefined;
  const hasFiles = ctx.request.url.searchParams.has("hasFiles")
    ? ctx.request.url.searchParams.get("hasFiles") === "true"
    : undefined;

  // Get notices with filters
  const paginatedNotices = getPaginatedNotices(page, limit, category, hasFiles);
  ctx.response.body = paginatedNotices;
}
