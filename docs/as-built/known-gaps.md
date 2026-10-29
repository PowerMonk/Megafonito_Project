# Known gaps and risks

Findings below reflect source inspection, not a penetration test or production execution. These items should remain visible while the project is a prototype.

## Integration and product behavior

| Priority | Finding | Evidence / implication |
| --- | --- | --- |
| High | Flutter and backend are not integrated. | Active `ApiService` is mock-only; no HTTP call path to Deno routes. Client visuals must not imply server-backed behavior. |
| High | Login is not credential authentication. | Flutter bypasses login; backend issues a JWT after control-number lookup without a password/secret check. |
| High | Mock notices are transient. | Notice creation mutates a newly constructed mock map; reload rebuilds original examples. |
| High | File upload is simulated in the Flutter flow. | `StorageService` returns a fake URL/key and does not send bytes to S3/API. |
| Medium | User-entered link overwrites title. | Notice/opportunity form Link and Title fields share a controller. |
| Medium | Opportunity/message submit handlers are not connected to shell behavior. | Their callbacks are optional and menu navigation does not pass them. |
| Medium | Sort/filter UI does not match its actual service query. | Sort state isn't passed, attachment choice is not applied from shell, helpers sort missing `fecha`. |
| Medium | Some detail dates/links are sample constants. | Notice detail has a fixed expiry fallback; opportunity content uses hard-coded expiry dates and institution URL. |
| Medium | Some support/process/schedule UI actions are placeholders. | Taps log/show placeholder feedback or do not navigate to implemented content. |
| Medium | Sign-out navigation does not clear mock auth state. | Account screen routes to Login but skips `AuthService.logout`. |

## Backend authorization, privacy, and data correctness

| Priority | Finding | Evidence / implication |
| --- | --- | --- |
| Critical | Audience targeting is not enforced in query paths. | `target_groups`/`target_classes` are stored, but list, by-id, and author query paths do not filter/authorize them. Could expose announcements beyond their intended audience. |
| High | Login has no password check. | `loginHandler` accepts only `control_number`; user record lookup is enough to mint a token. |
| High | User creation guard is broader than docs claim. | `POST /users` requires any authenticated user; only creating an Admin role triggers an Admin check. |
| High | User update parameter mismatch. | Route declares `:userId`; handler reads `ctx.params.id`, so ID parses as zero and request is rejected. |
| High | Admin notice override uses a missing field. | Middleware sets `role`; update/delete handlers test `role_name`. |
| High | Dynamic SQL identifiers are not allowlisted. | Notice model inserts request object keys into quoted SQL column identifiers; parameterization applies to values only. |
| Medium | Single notice and author listing have incomplete access checks. | Authentication exists, but no target-group/class audience check; by-author does not constrain requester identity/role. |
| Medium | Migrations are not run on startup. | Connection test runs `SELECT 1`; no migration runner was found. |
| Medium | S3 fetch route is unauthenticated. | `GET /s3/files/:fileKey` has no auth middleware and uses S3 presigned URLs. |
| Medium | Rate limiting is process-local. | In-memory map resets on restart and is not shared across replicas. |
| Medium | Error/log paths can expose implementation details. | Error responses may include error text/details; auth and controller code logs tokens/payloads/user-related data. |

## Delivery and maintenance

- Compose has no PostgreSQL service; its SQLite-named mount conflicts with the PostgreSQL code path.
- The Docker build context is the backend folder while ignore rules are at repository root; local files can enter the build context.
- S3 environment validation happens during module loading, coupling file-service configuration to broader API route startup.
- Deno task permissions are broad; backend lockfile is not tracked.
- Root README, backend readme, API notes, compose comments, SQL migration state, and active code have discrepancies.
- `backend/docs.md` cannot currently be read as ordinary Markdown; a later cleanup should determine whether to recover or replace it.
- Frontend CI has no analysis/test gate. The project now has tracked widget tests and a clean local analyzer result, but CI does not run them.
- The Dart/Flutter minimums were aligned to the current lockfile and file_picker release; consumers must use Flutter 3.44+ / Dart 3.13+.
- Flutter source contains hardcoded sample profile data and sample/mock data. Keep these out of docs/screenshots shared publicly unless sanitized.
- The logo SVG includes embedded font/style/metadata elements that cause non-fatal parser warnings during widget tests.
- Android Gradle support is now aligned with Flutter 3.47: Gradle 9.3.1 / AGP 9.1.0, using built-in Kotlin with the legacy DSL compatibility flag. The prior Cronet namespace conflict was resolved by removing its unused package dependency. Revisit the Android dependency matrix when Flutter updates its supported toolchain.

## Suggested separate follow-up work (outside visual scope)

1. Define the dataset, access/audience model, and threat/authorization requirements before finalizing production schema/API behavior.
2. Implement password-based or institutional authentication and consistent role claims/guards.
3. Enforce target audience constraints in every notice retrieval path and test them.
4. Add migration/deployment automation, correct Docker context ignores, database service configuration, and least-privilege Deno permissions.
5. Define durable client/backend API contracts and replace mock service implementations deliberately.
6. Add focused backend route/model tests and real Flutter service/widget test coverage.
