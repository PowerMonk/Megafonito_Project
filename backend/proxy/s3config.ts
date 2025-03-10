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
  region: "us-east-1", // Tu región
  bucketName: "test-mgf-s3-bucket", // Tu bucket
  testFolder: "mgf-tests", // Tu carpeta (sin "/" al final)
  accessKeyId: Deno.env.get("S3_ACCESS_KEY"), // Clave de acceso
  secretAccessKey: Deno.env.get("S3_SECRET_KEY"), // Clave secreta
  endPoint: "https://s3.us-east-1.amazonaws.com", // Solo el endpoint base
};
