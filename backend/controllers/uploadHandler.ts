import { RouterContext } from "@oak/oak";
import { ensureDir } from "jsr:@std/fs"; // Import utility to create directories if they don't exist

// === CONFIGURATION CONSTANTS ===
// Set the directory where uploaded files will be stored on the server
const UPLOAD_DIR = "./uploads";
// Define the URL path prefix that will be used to access files in HTTP requests
const FILE_URL_PREFIX = "/files";

// === INITIALIZE UPLOAD DIRECTORY ===
// This is a top-level await that runs when this module is imported
// It creates the uploads directory if it doesn't already exist
await ensureDir(UPLOAD_DIR);

/**
 * Handles file uploads via multipart/form-data requests
 *
 * This function:
 * 1. Validates the request contains form-data
 * 2. Extracts the uploaded file
 * 3. Generates a unique filename
 * 4. Saves the file to the server filesystem
 * 5. Returns the URL where the file can be accessed
 */
export async function uploadFileHandler(ctx: RouterContext<string>) {
  try {
    // === VALIDATE REQUEST TYPE ===
    // Check if the request body is the expected format (form-data)
    const bodyType = ctx.request.body.type();
    if (bodyType !== "form-data") {
      // If not form-data, return 400 Bad Request
      ctx.response.status = 400;
      ctx.response.body = { error: "Expected form-data" };
      return;
    }

    // === EXTRACT FORM DATA ===
    // Parse the multipart/form-data from the request body
    const formData = await ctx.request.body.formData();
    // Look for a field named "file" in the form data
    const file = formData.get("file");

    // === VALIDATE FILE PRESENCE ===
    // Check if a file was provided and it's actually a File object
    if (!file || !(file instanceof File)) {
      ctx.response.status = 400;
      ctx.response.body = { error: "No file provided" };
      return;
    }

    // === GENERATE UNIQUE FILENAME ===
    // Extract the original filename and extension
    const originalName = file.name || "unknown";
    const fileExt = originalName.split(".").pop() || "bin"; // Default to 'bin' if no extension

    // Create a unique identifier using timestamp + random number
    // This prevents filename collisions when multiple files are uploaded
    const uniqueId = `${Date.now()}_${Math.floor(Math.random() * 10000)}`;
    const fileName = `${uniqueId}.${fileExt}`;

    // === PREPARE FILE PATHS ===
    // Full filesystem path where the file will be saved
    const filePath = `${UPLOAD_DIR}/${fileName}`;
    // URL path where the file can be accessed by clients
    const fileUrl = `${FILE_URL_PREFIX}/${fileName}`;

    // === SAVE FILE TO DISK ===
    // Get file content as ArrayBuffer
    const fileContent = await file.arrayBuffer();
    // Convert ArrayBuffer to Uint8Array (required by Deno's file system API)
    // and write it to the specified path
    await Deno.writeFile(filePath, new Uint8Array(fileContent));

    // === RETURN SUCCESS RESPONSE ===
    // Set 201 Created status code
    ctx.response.status = 201;
    // Return useful information about the uploaded file
    ctx.response.body = {
      success: true,
      fileUrl, // URL path to access the file
      fileName, // The generated unique filename on the server
      originalName, // The original filename from the user
    };
  } catch (error) {
    // === ERROR HANDLING ===
    // Log the error for server-side debugging
    console.error("File upload error:", error);
    // Return a 500 Internal Server Error
    ctx.response.status = 500;
    ctx.response.body = {
      error: "Failed to upload file",
      details: error, // Include error details in response
    };
  }
}

/**
 * Serves static files from the uploads directory
 *
 * This function:
 * 1. Extracts the requested filename from the URL parameters
 * 2. Reads the file from disk
 * 3. Sets appropriate content-type headers based on file extension
 * 4. Returns the file content as the response
 */
export function serveFileHandler(ctx: RouterContext<string>) {
  // Extract the filename from URL parameters
  const fileName = ctx.params.fileName;
  // Construct the full filesystem path
  const filePath = `${UPLOAD_DIR}/${fileName}`;

  try {
    // === READ FILE FROM DISK ===
    // Read the file synchronously and set it as the response body
    ctx.response.body = Deno.readFileSync(filePath);

    // === SET CONTENT TYPE ===
    // Determine appropriate content-type header based on file extension
    const fileExt = fileName.split(".").pop()?.toLowerCase();
    switch (fileExt) {
      case "pdf":
        ctx.response.headers.set("Content-Type", "application/pdf");
        break;
      case "jpg":
      case "jpeg":
        ctx.response.headers.set("Content-Type", "image/jpeg");
        break;
      case "png":
        ctx.response.headers.set("Content-Type", "image/png");
        break;
      case "doc":
      case "docx":
        ctx.response.headers.set("Content-Type", "application/msword");
        break;
      case "xls":
      case "xlsx":
        ctx.response.headers.set("Content-Type", "application/vnd.ms-excel");
        break;
      default:
        // Use a generic binary content type if extension is unknown
        ctx.response.headers.set("Content-Type", "application/octet-stream");
    }
  } catch (error) {
    // === ERROR HANDLING ===
    // Log error for debugging purposes
    console.error("File not found:", error);
    // Return 404 Not Found if the file doesn't exist
    ctx.response.status = 404;
    ctx.response.body = { error: "File not found" };
  }
}
