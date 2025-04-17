// Aún no sé como crear tests, xd
import { assert, assertEquals } from "@std/assert";
import { Application, Router } from "@oak/oak";
import { Validation } from "./utils/validation.ts";
import { isEmptyObject } from "./utils/responseUtils.ts";
import { testConnection } from "./db/dbMod.ts";
import { AppError } from "./utils/utilsMod.ts";

// 1. Basic test to verify Deno is working
Deno.test("basic assertion test", () => {
  assert(true, "This test should always pass");
});

// 2. Testing utility functionss
Deno.test("isEmptyObject utility function", () => {
  // Should return true for null objects
  assertEquals(isEmptyObject(null), true);
  assert(isEmptyObject(null));

  // Should return true for empty objects
  assertEquals(isEmptyObject({}), true);
  assert(isEmptyObject({}));

  // Should return false for non-empty objects
  assertEquals(isEmptyObject({ id: 1, name: "test" }), false);
});

// 3. Testing validation class
// Deno.test("Validation class private methods", () => {
//   const validation = new Validation();

//   // We need to access private methods for testing
//   // This is a trick to access them, creating a subclass
//   class TestableValidation extends Validation {
//     testValidateMinLength(value: string, minLength: number): boolean {
//       return this["#validateMinLength"](value, minLength);
//     }

//     testValidateEmailFormat(email: string): boolean {
//       return this["#validateEmailFormat"](email);
//     }

//     testValidatePositiveNumber(value: number): boolean {
//       return this["#validatePositiveNumber"](value);
//     }
//   }

//   const testValidation = new TestableValidation();

//   // Test minimum length validation
//   assertEquals(testValidation.testValidateMinLength("test", 4), true);
//   assertEquals(testValidation.testValidateMinLength("tes", 4), false);

//   // Test email format validation
//   assertEquals(
//     testValidation.testValidateEmailFormat("test@example.com"),
//     true
//   );
//   assertEquals(testValidation.testValidateEmailFormat("invalid-email"), false);

//   // Test positive number validation
//   assertEquals(testValidation.testValidatePositiveNumber(5), true);
//   assertEquals(testValidation.testValidatePositiveNumber(-1), false);
// });

// // 4. Testing database connection
// Deno.test({
//   name: "Database connection test",
//   async fn() {
//     const connected = await testConnection();
//     assertEquals(connected, true);
//   },
//   sanitizeResources: false,
//   sanitizeOps: false,
// });

// // 5. Testing AppError class
// Deno.test("AppError creation", () => {
//   const error = new AppError("Test error", 400, { type: "ValidationError" });
//   assertEquals(error.message, "Test error");
//   assertEquals(error.status, 400);
//   assertEquals(error.details.type, "ValidationError");
// });

// // 6. Mock API test (Integration test example)
// Deno.test({
//   name: "API health endpoint returns correct response",
//   async fn() {
//     // Create a test application
//     const app = new Application();
//     const router = new Router();

//     // Define test route
//     router.get("/healthy", (ctx) => {
//       ctx.response.body = "Service is healthy";
//       ctx.response.status = 200;
//     });

//     app.use(router.routes());

//     // Start the app in test mode
//     const controller = new AbortController();
//     const { signal } = controller;

//     const serverPromise = app.listen({ port: 9000, signal });

//     // Allow server to start
//     await new Promise((resolve) => setTimeout(resolve, 100));

//     try {
//       // Make a request to our test server
//       const response = await fetch("http://localhost:9000/healthy");
//       const body = await response.text();

//       assertEquals(response.status, 200);
//       assertEquals(body, "Service is healthy");
//     } finally {
//       // Stop the server
//       controller.abort();
//       await serverPromise;
//     }
//   },
//   sanitizeResources: false,
//   sanitizeOps: false,
// });

// // 7. Example mock test for middleware
// Deno.test({
//   name: "Logging middleware test",
//   async fn() {
//     let logCalled = false;

//     // Original console.log
//     const originalLog = console.log;

//     try {
//       // Mock console.log
//       console.log = (...args: unknown[]) => {
//         if (args[0] === "Request:") {
//           logCalled = true;
//         }
//       };

//       // Import middleware
//       const { loggingMiddleware } = await import("./utils/utilsMod.ts");

//       // Create mock context
//       const ctx = {
//         request: {
//           url: new URL("http://localhost/test"),
//           method: "GET",
//         },
//         response: {},
//       };

//       // Execute middleware with mock next function
//       await loggingMiddleware(ctx as any, () => Promise.resolve());

//       // Verify middleware logged the request
//       assertEquals(logCalled, true);
//     } finally {
//       // Restore original console.log
//       console.log = originalLog;
//     }
//   },
// });
