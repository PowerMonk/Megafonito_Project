# Backend as built

## Runtime and startup

The service is TypeScript on Deno with Oak. `backend/main.ts` constructs an Oak `Application`, calls `testConnection()` without awaiting or gating startup on its result, installs the health and deliberate test-error routes, then registers error logging, request logging, and rate-limit middleware before the combined router. It listens on port `8000`.

The router is assembled through barrel exports: `routesMod.ts` re-exports the user and notice routers; controllers call model functions; models call PostgreSQL query helpers. The S3 route barrel eagerly imports S3 config. Database, JWT, and S3 modules load dotenv values at module initialization from `.env` relative to `Deno.cwd()`.

## Layer responsibilities

| Layer | Responsibility and current state |
| --- | --- |
| Routes | `userRoutes.ts` and `noticeRoutes.ts` declare HTTP methods, paths, auth/role/validation middleware, and handlers. |
| Controllers | Parse JSON/query/path parameters, enforce some role/ownership checks, call models, and write Oak response status/body. |
| Auth | JOSE signs/verifies HS256 JWTs; middleware parses Bearer tokens into `ctx.state.user`; `requireRole` checks role strings. The login path only looks up a control number and does not verify a password. |
| Models | PostgreSQL operations for users and notices. User model supports transactional role/group creation; notice model builds filters and pagination and persists selected notice fields. |
| PostgreSQL | `npm:postgres` client plus `sql.unsafe` query helpers for reads/writes/transactions/pagination. SQL schema/migrations are not automatically executed. |
| S3 proxy | Upload, delete, list, and presigned URL handlers backed by an S3 client. Configuration currently references a fixed test bucket/prefix and requires credentials. |
| Utilities | Validation, structured/error logging middleware, response/error types, local rate limiter, and safe-query wrappers. |

## Middleware behavior

`main.ts` registers `loggingErrorMiddleware`, `loggingMiddleware`, and `rateLimiter`, then router middleware. The limiter stores counters/queues in process memory (100 requests per 15-minute window per IP); it is neither distributed nor persistent. Logging includes request URLs and error details. Authentication is attached at individual route declarations rather than as a global middleware.

## Active capability vs schema/plan

- User and notice handlers/models are present.
- Polls/responses and resources exist in SQL schema but do not have active model/controller/route implementations.
- Legacy roadmap notes mention SQLite-to-PostgreSQL migration even though active DB code uses PostgreSQL. A local SQLite-named file does not represent the active store.
- Migrations are checked into `db/migrations/`, but `testConnection()` executes `SELECT 1`; there is no migration runner in the inspected startup path.

## Important implementation caveats

- Login uses only a control-number lookup and then signs a token; there is no password/secret comparison.
- User creation route requires authentication but does not globally require Admin; controller rejects only requests that attempt to create an Admin role.
- `PUT /users/:userId` is read as `ctx.params.id` by its handler, so it fails the positive-ID check.
- Auth middleware sets `ctx.state.user.role`; notice update/delete handlers check `user.role_name` for the admin exception.
- Audience fields are accepted/stored, but normal notice listing does not filter by the caller's target groups/classes; single notice and author-notice retrieval also lack audience checks.
- Notice update column names are interpolated from request keys. Parameter binding for values does not make unvalidated SQL identifiers safe.
- The backend test file imports database-dependent modules; environment and connectivity can affect test startup.
- Missing S3 credentials may make route imports/server startup fail even when a request does not use file endpoints.

## Local run outline

The task is declared in `backend/deno.json`; running it requires a Deno installation, database/JWT/S3 configuration, permissions granted by the task, and a reachable PostgreSQL server. The precise environment names and Docker caveats are in [Configuration and deployment](configuration-and-deployment.md). This describes what code expects, not a supported production deployment.
