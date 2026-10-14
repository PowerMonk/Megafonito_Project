# API reference — observed implementation

This is an implementation-based inventory, not a production API contract. JSON field casing is inconsistent across request/controller/model code. Unless otherwise noted, route behavior is in `backend/routes/` and handlers in `backend/controllers/`.

## Health and diagnostic routes

| Method/path | Guard | Observed behavior |
| --- | --- | --- |
| `GET /healthy` | None | Returns plain text `Service is healthy`, status 200. |
| `POST /test-error` | None | Deliberately throws an error to exercise error middleware. |

## Users

| Method/path | Guard | Observed behavior |
| --- | --- | --- |
| `POST /login` | None | Expects JSON containing `control_number`; looks up that user, creates a 2-hour JWT and returns token, role, user id, and name. **No password check.** |
| `POST /users` | `authMiddleware` | Controller expects control number, email, name, role and optional group/group type/schedule. Only attempted Admin-role creation is explicitly restricted to Admin. Creates user and returns 201 with token/user. Validation middleware is commented out. |
| `GET /users` | Auth + Admin role | Returns all users. |
| `GET /users/getuser/:control_number` | Auth | Returns matching user or 404. No self/admin authorization is enforced in the route/handler. |
| `PUT /users/:userId` | Auth | Intended to update self/admin user data. Handler reads `ctx.params.id`, so declared `userId` path parameter is not read and the request is rejected as invalid ID. |
| `DELETE /users/:control_number` | Auth | Handler permits self or Admin deletion based on looked-up user. |

## Notices

| Method/path | Guard | Observed behavior |
| --- | --- | --- |
| `POST /notices` | Auth + `validateNoticeCreation` + Admin/Teacher controller check | Accepts title/content/category, role visibility, target arrays, attachment fields, publish/expiry dates. Validation expects `userId` though controller takes author from auth state. |
| `GET /notices` | Auth | Paginated listing; accepts `page`, `limit`, `category`, `hasAttachment`, `startDate`, `endDate`, `includeFuture`, `includeExpired`. Model filters by role level/category/attachment/date/publish/expiry, but not target groups/classes. |
| `GET /allnotices` | Auth + Admin check in controller | Returns all notices. |
| `GET /notices/:userId` | Auth | Returns notices by author id with page/limit; no self/admin or audience authorization check. |
| `GET /notices/anuncio/:noticeId` | Auth | Returns a notice by id; no audience visibility check. |
| `PUT /notices/:noticeId` | Auth | Intended for author or Admin. Admin override checks `user.role_name`, which auth middleware does not set. The model constructs update SQL using request keys as identifiers without an allowlist. |
| `DELETE /notices/:noticeId` | Auth | Intended for author or Admin; same `role_name` mismatch can block Admin override. |

## S3 routes

| Method/path | Guard | Observed behavior |
| --- | --- | --- |
| `POST /upload/s3` | Auth | Expects multipart form data with a nonempty `file`; uploads under the configured test prefix and returns URL/key/name/size/type. |
| `GET /s3/files/:fileKey` | No auth middleware | Redirects to a short-lived presigned URL by default; `?presigned=true` returns URL JSON and optional `expires` controls expiry. |
| `GET /s3/list` | Auth | Lists objects; optional `prefix` query parameter. |
| `DELETE /s3/files/:fileKey` | Auth | Attempts object deletion. |

## Authentication and response caveats

Protected routes expect `Authorization: Bearer <JWT>`. JWT creation/verification is HS256 with a two-hour expiry. The route source contains some guards while docs/readmes claim broader role restrictions. Do not use the above as a security guarantee: see [Known gaps](known-gaps.md). Errors are inconsistently shaped between controller bodies and global error middleware.
