import { join } from "jsr:@std/path";
import { load } from "../dependencies/depsMod.ts";

// Obtains the absolute path to the .env file
const envPath = join(Deno.cwd(), ".env");

const env = await load({
  export: true,
  envPath: envPath,
});

const accessKeyId = env.S3_ACCESS_KEY;
const secretAccessKey = env.S3_SECRET_KEY;

// Validación de las variables de entorno
if (!accessKeyId || !secretAccessKey) {
  throw new Error(
    "Las variables de entorno S3_ACCESS_KEY y S3_SECRET_KEY son obligatorias"
  );
}

export const s3Config = {
  region: "us-east-1",
  bucketName: "test-mgf-s3-bucket",
  testFolder: "mgf-tests",
  accessKeyId, // Ahora TypeScript sabe que no será undefined
  secretAccessKey, // Ahora TypeScript sabe que no será undefined
  endPoint: "https://test-mgf-s3-bucket.s3.us-east-1.amazonaws.com/mgf-tests/",
};
