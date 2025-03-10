import { RouterContext } from "@oak/oak";
import { getS3Service } from "./proxyMod.ts";

/**
 * Handler for uploading files to S3
 *
 * This function:
 * 1. Validates the incoming form-data request
 * 2. Extracts the file from the request
 * 3. Uploads it to S3 using the S3Service
 * 4. Returns the URL and metadata for the uploaded file
 *
 * @param ctx - The Oak router context
 */
export async function s3UploadHandler(ctx: RouterContext<string>) {
  try {
    // Get the S3 service instance
    const s3Service = getS3Service();

    // Check if the body type is form-data
    if (ctx.request.body.type() !== "form-data") {
      throw new Error("Expected form-data");
    }

    // Parse the form data
    const formData = await ctx.request.body.formData();

    // Get the file and category from form data
    const file = formData.get("file");

    // Validate that a file was provided
    if (!file || !(file instanceof File)) {
      throw new Error("No file provided");
    }

    if (file.size === 0) {
      throw new Error("The uploaded file is empty");
    }

    // const category = (formData.get("category") as string) || "uploads";

    // Define custom prefix based on category
    // This organizes files by category in the S3 bucket
    // const customPrefix = `${s3Config.testFolder}/${category}`;

    // Use a simpler subfolder structure - just "tests"
    // This will create files in: mgf-tests/tests/filename.ext
    const subfolder = "tests";

    // Upload the file to S3 with the simplified folder structure
    const { url, key } = await s3Service.uploadFile(file, subfolder);

    // Upload the file to S3

    // Return success response with file details
    ctx.response.status = 201;
    ctx.response.body = {
      success: true,
      fileUrl: url, // Store this in the database
      fileKey: key, // Store this in the database
      originalName: file.name,
      size: file.size,
      type: file.type,
    };
  } catch (error) {
    // Handle errors
    ctx.response.status = 500;
    throw new Error("S3 upload error: " + error);
  }
}

/**
 * Handler for deleting files from S3
 *
 * @param ctx - The Oak router context
 */
export async function s3DeleteHandler(ctx: RouterContext<string>) {
  try {
    // Get the file key from request parameters
    const fileKey = ctx.params.fileKey;

    if (!fileKey) {
      throw new Error("File key is required");
    }

    const s3Service = getS3Service();
    const success = await s3Service.deleteFile(fileKey);

    if (success) {
      ctx.response.status = 200;
      ctx.response.body = {
        success: true,
        message: "File deleted successfully",
      };
    } else {
      ctx.response.status = 404;
      throw new Error("File not found or unable to delete");
    }
  } catch (error) {
    ctx.response.status = 500;
    throw new Error("S3 delete error: " + error);
  }
}
