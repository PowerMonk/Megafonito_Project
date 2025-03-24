import postgres from "npm:postgres";
import { load } from "../../dependencies/depsMod.ts";
import { join } from "jsr:@std/path";

// Obtains the absolute path to the .env file
const envPath = join(Deno.cwd(), ".env");

const env = await load({
  export: true,
  envPath: envPath,
});

const dbNameKey = env.DB_NAME;
const dbPwdKey = env.DB_PASSWORD;

// Validación de las variables de entorno
if (!dbNameKey || !dbPwdKey) {
  throw new Error(
    "Las variables de entorno DB_NAME y DB_PASSWORD son obligatorias"
  );
}

const sqlConfig = {
  host: Deno.env.get("DB_HOST") || "localhost",
  port: parseInt(Deno.env.get("DB_PORT") || "5432"),
  database: Deno.env.get("DB_NAME"),
  username: Deno.env.get("DB_USER"),
  password: Deno.env.get("DB_PASSWORD"),
  max: 10, // Connection pool size
  idle_timeout: 600, // Seconds a connection can be idle before being removed
  connect_timeout: 10, // Seconds to wait before timing out when connecting
};

// Create SQL client
const sql = postgres(sqlConfig);

// Test database connection
export async function testConnection() {
  try {
    const result = await sql`SELECT 1 as connected`;
    console.log("PostgreSQL connection successful:", result[0].connected === 1);
    return true;
  } catch (error) {
    console.error("PostgreSQL connection failed:", error);
    return false;
  }
}

// Close connection
export async function closePool() {
  await sql.end();
  console.log("PostgreSQL connection closed");
}

export { sql };
