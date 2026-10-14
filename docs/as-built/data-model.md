# Data model and persistence

## SQL schema inventory

The schema is defined in `backend/db/migrations/01_schema.sql`; the separate `02_indexes.sql` adds indexes and `03_seed.sql` inserts development reference data. These SQL files are not automatically applied by the inspected app startup.

| Table | Purpose / notable fields |
| --- | --- |
| `user_roles` | Named roles and integer `reach_level`. |
| `groups` | Named/type groups with optional parent group. |
| `users` | Control number, email, name, role FK, optional primary group, JSONB schedule, created timestamp. No password column is defined in this schema. |
| `user_groups` | Many-to-many user/group associations. |
| `classes` | Class name/code, optional group, description. |
| `user_classes` | Many-to-many user/class membership with relationship role. |
| `notices` | Title/content/author/category, minimum role level, target group/class integer arrays, attachment fields, creation/publish/expiry timestamps. |
| `polls` | Title/question/options JSON, author, role/group/class targeting and expiry. No active API/model implementation was found. |
| `poll_responses` | User's selected poll option and submission time, unique per poll/user. No active API/model implementation was found. |
| `resources` | Typed title/description/details JSON and visibility/expiry fields; no active API/model implementation was found. |

## Current persistence adapter

The active connection uses `npm:postgres` from `backend/db/postgres/client.ts`. Query helpers in `db/postgres/dbQueries.ts` call `sql.unsafe` for generic query strings/parameters, transaction operations, and pagination. Models implemented against this layer are user and notice models. `db/safeQueries.ts` exports synchronous wrappers and currently does not form the main async model path.

## Data-flow and consistency notes

- Flutter's `Notice` model and the feed service can represent backend-shaped notice JSON, but the active UI feed never fetches backend results.
- `Notice` model conversions have assumptions about non-null field types and `created_at` parse validity.
- Notice creation stores target arrays and visibility fields; list queries enforce minimum role level but omit group/class targeting. This makes stored audience controls ineffective in query paths.
- Database indexing covers common identities, role/group/class relationships, notices, polls, and resources. No index can compensate for the missing authorization filter.
- Seed statements are intended to be repeatable through `ON CONFLICT`, but they contain development identity-like values and should not be copied to public docs/logs.
- A local ignored artifact named `megafonito.db` and older roadmap language refer to SQLite. The code currently reviewed connects to PostgreSQL; the local artifact is not evidence of active SQLite persistence.

## Diagram

`backend/db/DB_flowchart.svg` is the tracked relationship diagram. It is a historical generated SVG and should be checked against the SQL migrations when the schema is next changed.
