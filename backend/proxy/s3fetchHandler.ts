import { RouterContext } from "@oak/oak";
import { getS3Service } from "./proxyMod.ts";

/**
 * Handler for fetching files from S3
 *
 * Provides two approaches:
 * 1. Direct download: Returns the file content directly
 * 2. Pre-signed URL: Generates a time-limited URL for direct access
 *
 * @param ctx - The Oak router context
 */
export async function s3FetchHandler(ctx: RouterContext<string>) {
  try {
    // Get the file key from request parameters
    const fileKey = ctx.params.fileKey;

    if (!fileKey) {
      throw new Error("File key is required");
    }

    // Check if client wants a pre-signed URL instead of direct download
    const usePresignedUrl =
      ctx.request.url.searchParams.get("presigned") === "true";

    // Get expiration time from query param or use default (1 week)
    const expiresIn = parseInt(
      ctx.request.url.searchParams.get("expires") || "604800"
    ); // 1 week default

    const s3Service = getS3Service();

    if (usePresignedUrl) {
      // Generate and return a pre-signed URL
      const presignedUrl = await s3Service.generatePresignedUrl(
        fileKey,
        expiresIn
      );

      ctx.response.body = {
        presignedUrl,
        expiresIn,
      };
    } else {
      // Redirect to a pre-signed URL for direct file access
      const presignedUrl = await s3Service.generatePresignedUrl(fileKey, 60); // Short-lived URL
      ctx.response.redirect(presignedUrl);
    }
  } catch (error) {
    ctx.response.status = 500;
    throw new Error("S3 fetch error: " + error);
  }
}

/**
 * Handler for listing files in an S3 directory
 *
 * @param ctx - The Oak router context
 */
export async function s3ListHandler(ctx: RouterContext<string>) {
  try {
    // Get optional prefix from query params
    const prefix = ctx.request.url.searchParams.get("prefix") || undefined;

    const s3Service = getS3Service();
    const files = await s3Service.listFiles(prefix);

    ctx.response.body = {
      files,
      count: files.length,
    };
  } catch (error) {
    ctx.response.status = 500;
    throw new Error("S3 list error: " + error);
  }
}
