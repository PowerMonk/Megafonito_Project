import { S3Client } from "jsr:@bradenmacdonald/s3-lite-client@0.9.0";
// import * as storage_S3 from "jsr:@frytg/storage-s3";
import { s3Config } from "./s3config.ts";

/**
 * S3Service class
 *
 * Provides a complete interface for interacting with AWS S3
 * Handles uploads, downloads, deletion and URL generation for S3 objects
 */
export class S3Service {
  private s3Client: S3Client;
  private bucketName: string;
  // private folder: string = s3Config.testFolder;
  private folderPrefix: string = `${s3Config.testFolder}/`;

  /**
   * Constructor initializes the S3 client using provided configuration
   * Includes validation checks for required credentials
   */
  constructor() {
    this.s3Client = new S3Client({
      endPoint: s3Config.endPoint,
      region: s3Config.region,
      bucket: s3Config.bucketName,
      accessKey: s3Config.accessKeyId,
      secretKey: s3Config.secretAccessKey,
    });

    this.bucketName = s3Config.bucketName;

    // Validate that required environment variables are present
    if (!s3Config.accessKeyId || !s3Config.secretAccessKey) {
      throw new Error("Missing S3 credentials - check environment variables");
    }

    try {
      console.log("S3 client initialized successfully");
    } catch (error) {
      console.error("Failed to initialize S3 client:", error);
      throw new Error(`S3 initialization failed: ${error}`);
    }
  }

  /**
   * Uploads a file to S3
   * @param file - The file object to upload
   * @param customPrefix - Optional custom folder path within the bucket
   * @returns Promise with the uploaded file's URL and key
   */
  async uploadFile(
    file: File,
    customPrefix?: string
  ): Promise<{ url: string; key: string }> {
    try {
      // Generate a unique key for the file
      const timestamp = Date.now();
      const randomString = Math.random().toString(36).substring(2, 10);
      const originalName = file.name;
      const sanitizedName = originalName.replace(/[^a-zA-Z0-9.-]/g, "_");

      // Determine file prefix (folder structure)
      const prefix = customPrefix
        ? `${this.folderPrefix}${customPrefix}/`
        : this.folderPrefix;

      // Create the full S3 key (path)
      const key = `${prefix}${timestamp}_${randomString}_${sanitizedName}`;

      // Convert file to ArrayBuffer and then to Uint8Array for upload
      const fileContent = await file.arrayBuffer();
      const fileBytes = new Uint8Array(fileContent);

      // Determine content type
      let contentType = file.type;
      if (!contentType || contentType === "application/octet-stream") {
        // Try to infer content type from file extension if not provided
        const extension = sanitizedName.split(".").pop()?.toLowerCase();
        contentType = this.getContentTypeFromExtension(extension || "");
      }

      // Upload the file to S3
      await this.s3Client.putObject(key, fileBytes);

      // Generate a URL for the uploaded file
      const url = `https://${this.bucketName}.s3.${s3Config.region}.amazonaws.com/${key}`;

      console.log(`File uploaded successfully: ${url}`);
      return { url, key };
    } catch (error) {
      console.error("Failed to upload file to S3:", error);
      throw new Error(`S3 upload failed: ${error}`);
    }
  }

  /**
   * Generates a pre-signed URL for a file in S3
   * This URL can be used to download the file directly
   *
   * @param key - The S3 key of the file
   * @param expiresIn - Expiration time in seconds (default: 3600 = 1 hour)
   * @returns Promise with the pre-signed URL
   */
  async generatePresignedUrl(
    key: string,
    expiresIn: number = 3600 * 24 * 7 // 1 week
  ): Promise<string> {
    try {
      // Generate a pre-signed URL using the S3 client
      const presignedUrl = await this.s3Client.presignedGetObject(key, {
        bucketName: this.bucketName,
        expirySeconds: expiresIn,
        requestDate: new Date(),
      });
      return presignedUrl;
    } catch (error) {
      console.error("Failed to generate presigned URL:", error);
      throw new Error(`Presigned URL generation failed: ${error}`);
    }
  }

  /**
   * Deletes a file from S3
   *
   * @param key - The S3 key of the file to delete
   * @returns Promise<boolean> indicating success or failure
   */
  async deleteFile(key: string): Promise<boolean> {
    try {
      await this.s3Client.deleteObject(key, { bucketName: this.bucketName });
      console.log(`File deleted successfully: ${key}`);
      return true;
    } catch (error) {
      console.error("Failed to delete file from S3:", error);
      // Instead of throwing, return false to indicate failure
      return false;
    }
  }
  /**
   * Lists files in an S3 directory
   *
   * @param prefix - The directory prefix to list
   * @returns Promise with the list of objects
   */
  async listFiles(
    prefix: string = this.folderPrefix
  ): Promise<Array<{ key: string; size: number; lastModified: Date }>> {
    try {
      const result = this.s3Client.listObjects({
        prefix,
        bucketName: this.bucketName,
      });

      // Usar un bucle 'for await' para iterar sobre el AsyncGenerator
      const files: Array<{ key: string; size: number; lastModified: Date }> =
        [];

      for await (const item of result) {
        files.push({
          key: item.key,
          size: item.size,
          lastModified: new Date(item.lastModified),
        });
      }

      return files;
    } catch (error) {
      console.error("Failed to list files from S3:", error);
      throw new Error(`S3 list operation failed: ${error}`);
    }
  }
  /**
   * Helper function to determine content type from file extension
   *
   * @param extension - The file extension
   * @returns The content type
   */
  private getContentTypeFromExtension(extension: string): string {
    const contentTypeMap: Record<string, string> = {
      pdf: "application/pdf",
      jpg: "image/jpeg",
      jpeg: "image/jpeg",
      png: "image/png",
      gif: "image/gif",
      doc: "application/msword",
      docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      xls: "application/vnd.ms-excel",
      xlsx: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      txt: "text/plain",
      csv: "text/csv",
      json: "application/json",
      xml: "application/xml",
      zip: "application/zip",
      // Lenguajes de programación
      py: "text/x-python",
      cs: "text/x-csharp",
      c: "text/x-c",
      cpp: "text/x-c++",
      java: "text/x-java-source",
      js: "application/javascript",
      ts: "application/typescript",
      html: "text/html",
      css: "text/css",
      php: "application/x-httpd-php",
      rb: "text/x-ruby",
      go: "text/x-go",
      swift: "text/x-swift",
      kt: "text/x-kotlin",
      sh: "application/x-sh",
      bash: "application/x-sh",
      pl: "text/x-perl",
      lua: "text/x-lua",
      r: "text/x-r",
      dart: "application/vnd.dart",
      scala: "text/x-scala",
      groovy: "text/x-groovy",
      rust: "text/x-rust",
      // Otros tipos de archivos
      mp3: "audio/mpeg",
      mp4: "video/mp4",
      wav: "audio/wav",
      ogg: "audio/ogg",
      webm: "video/webm",
      avi: "video/x-msvideo",
      mov: "video/quicktime",
      svg: "image/svg+xml",
      ico: "image/x-icon",
      ttf: "font/ttf",
      woff: "font/woff",
      woff2: "font/woff2",
      eot: "application/vnd.ms-fontobject",
      otf: "font/otf",
      md: "text/markdown",
      yaml: "application/x-yaml",
      yml: "application/x-yaml",
      sql: "application/sql",
      jsx: "text/jsx",
      tsx: "text/tsx",
      vue: "text/vue",
      svelte: "text/svelte",
      wasm: "application/wasm",
      // Archivos de configuración
      ini: "text/plain",
      conf: "text/plain",
      properties: "text/plain",
      toml: "application/toml",
    };

    return contentTypeMap[extension] || "application/octet-stream";
  }
}

// Singleton instance of the S3 service
let s3ServiceInstance: S3Service | null = null;

/**
 * Gets the S3 service instance
 * Creates a new instance if one does not exist (Singleton pattern)
 *
 * @returns The S3 service instance
 */
export function getS3Service(): S3Service {
  if (!s3ServiceInstance) {
    s3ServiceInstance = new S3Service();
  }
  return s3ServiceInstance;
}
