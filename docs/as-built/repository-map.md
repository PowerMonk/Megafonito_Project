# Repository map

This page inventories the tracked project files and their purpose. Generated files and private/ignored local state are not listed as source-of-truth artifacts. The separate pages linked here give behavioral detail.

## Root

| Path | Purpose / observed note |
| --- | --- |
| `readme.md` | Product summary, claimed stack/features, and quick-start commands. Some feature/API claims overstate current integration/authorization. |
| `README.Docker.md` | Historical Docker build/run notes; cloud deployment explicitly untested. |
| `BugsAndFixes.md` | Historical Android/iOS file-access notes; not a verified current platform-permission specification. |
| `Dockerfile` | Deno API container recipe; copies its build context and runs the `server` task. |
| `compose.yaml` | API-only compose service; no PostgreSQL service, includes an SQLite-named bind mount, and bind-mounts backend source. |
| `.dockerignore` | Root-context ignore patterns, including `.env` and `frontend/`. It is outside Compose's `backend/` build context, so do not assume it excludes files from that context. |
| `.github/workflows/flutter-ci.yml` | Push/manual Flutter workflow; generates platform files, gets packages, and builds release APK. |
| `UX/UI/` | Historical UI reference PDFs; see [UX reference inventory](../references/ux-assets.md). |
| `frontend/` | Flutter app, assets, Android project files, package configuration, and lockfile. |
| `backend/` | Deno/Oak server, database, routes, auth, S3 proxy, utilities, and historical backend docs. |

## Frontend source (`frontend/lib`)

### Entry, models, services, and utility

| Path | Purpose |
| --- | --- |
| `main.dart` | Runs `MyApp`; configures `MaterialApp` with the shared Material 3 theme and opens `SplashScreen`. |
| `theme/app_theme.dart` | Defines brand colors/spacing and the shared light Material 3 `ThemeData`, component defaults, and minimum icon-button target. |
| `models/user_model.dart` | Lightweight user data model (`name`, `email`, optional role/id). |
| `models/notice_model.dart` | Notice data model and JSON factory. |
| `services/api_service.dart` | Explicit mock API: development token, mock request responses, sample notices, filtering, and pagination. No HTTP client call to the backend. |
| `services/auth_service.dart` | Mock login/register/logout and current-user holder. |
| `services/notices_service.dart` | Notice service facade; delegates loads to mock `ApiService`, creates transient mock records, and contains an unused/incorrectly keyed sort helper. |
| `services/storage_service.dart` | Calls the platform file picker and returns simulated upload URL/key; deletion is also simulated. |
| `utils/helpers.dart` | Duplicate sort helper operating on a `fecha` key not present in sample notice objects. |

### Screens

| Path | Purpose / current behavior |
| --- | --- |
| `screens/splash_screen.dart` | Timer-driven loading screen, then replaces itself with login. |
| `screens/login_screen.dart` | Development login bypass that enters the shell as a superuser. |
| `screens/register_screen.dart` | Registration form calling mock `AuthService.register`. |
| `screens/anuncios_screen.dart` | Main shell, mock notice feed, category/sort callbacks, pagination/refresh, support route, and admin action menu. |
| `screens/contact_screen.dart` | Local sample contacts, name search, copy contact fields/all details. |
| `screens/opportunities_screen.dart` | Reads bundled career-logo assets and navigates to category opportunity examples. |
| `screens/oppscontent_screen.dart` | Hard-coded scholarship/course/job example cards and opportunity detail sheet. |
| `screens/school_processes_screen.dart` | Calendar, FAQ, and enrollment-process UI; actions are placeholders. |
| `screens/user_info_screen.dart` | Hard-coded profile/schedule UI, clipboard actions, and navigation to login on sign-out. |
| `screens/support_screen.dart` | Support options and explanatory copy; actions are placeholders. |
| `screens/crear_anuncio_screen.dart` | Notice composer, local validation, group/category selectors, and mock attachment picker flow. |
| `screens/createopps_screen.dart` | Opportunity composer; optional create callback is not wired by the shell. |
| `screens/newmsg_screen.dart` | Message composer; optional send callback is not wired by the shell. |

### Shared widgets

| Path | Purpose |
| --- | --- |
| `widgets/navbar.dart` | Five-destination navigation: Inicio, Contactos, Oportunidades, Procesos, Cuenta. |
| `widgets/actions_buttons.dart` | Home-only admin create-notice/message/opportunity floating action menu; expanded actions have distinct Hero tags. |
| `widgets/notice_card.dart` | Notice summary card and an additional reusable list widget (`NoticesContent`). |
| `widgets/notice_detail.dart` | Draggable modal with notice text and an external attachment link action. |
| `widgets/notices_filter.dart` | Horizontal category chips and sort/filter popup. The selected sort is not applied to data. |
| `widgets/notice_tags.dart` | Category tag and attachment icon widgets. |
| `widgets/opportunities_detail.dart` | Draggable opportunity detail modal and attachment/link actions. |

## Frontend assets and Android files

| Path | Purpose |
| --- | --- |
| `frontend/assets/Megafonito.svg` | Vector product mark used in splash/login. |
| `frontend/assets/LogoMegafon.png`, `LogoMegafon_V2.png` | Raster logo variations; V2 is used by registration. |
| `frontend/assets/GoogleIcon.png` | Google sign-in graphic; no active Google sign-in flow is shown in the reviewed screens. |
| `frontend/assets/Imag1.png`, `Imag2.png`, `Reins_1.png`, `Reins_2.png`, `Reins_3.png` | Product/design images; usage should be confirmed before removal. |
| `frontend/assets/icons/` | SVG icons: `bug_icon.svg`, `calendario-escolar_icon.svg`, `contactos_icon.svg`, `contactov2_icon.svg`, `copiar_icon.svg`, `cuenta_icon.svg`, `horario_icon.svg`, `inicio_icon.svg`, `newopp_icon.svg`, `nuevoanuncio_icon.svg`, `nuevomensaje_icon.svg`, `opciones_icon.svg`, `oportunidades_icon.svg`, `procesos_icon.svg`, `search-contacts_icon.svg`, `soporte_icon.svg`, `super_user_icon.svg`. These serve navigation, action, and utility UI. |
| `frontend/assets/logos_carreras/` | Bundled logos: `ing_admin_logo.png`, `ing_agricola_logo.png`, `ing_alimentarias_logo.png`, `ing_civil_logo.png`, `ing_electronica_logo.png`, `ing_industrial_logo.png`, `ing_mecanica_logo.png`, `ing_mecatronica_logo.png`, `ing_sistemas_logo.png`, and `itsu_logo.png`; the opportunities screen discovers these via the Flutter asset manifest. |
| `frontend/assets/test_images/` | Illustrative/test data: `BMW_logo.png`, `Beca_movilidad.jpeg`, `Beca_santander.png`, `Cisco_logo.png`, `Dela_Ousi.jpg`, `Python_logo.png`, `Supabase_logo.png`. Several are used by mock opportunity cards. |
| `frontend/android/app/src/main/AndroidManifest.xml` | Android app manifest and plugin/process-text query declarations. |
| `frontend/android/app/src/main/kotlin/com/example/flutter_megafonito/MainActivity.kt` | Android Flutter activity entry point. |
| `frontend/android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java` | Generated plugin registration. |
| `frontend/android/app/build.gradle`, `frontend/android/build.gradle` | Android app/root Gradle configuration. |
| `frontend/android/settings.gradle` | Android Gradle settings/plugin management; currently pins AGP 9.1.0 and Kotlin Gradle Plugin 2.4.0 for Flutter 3.47 compatibility. The app module uses AGP built-in Kotlin. |
| `frontend/android/gradle/wrapper/gradle-wrapper.properties` | Tracked Gradle wrapper distribution pin (Gradle 9.3.1); wrapper scripts/JAR remain generated by Flutter tooling. |
| `frontend/android/gradle.properties` | Gradle/Android build properties. |
| `frontend/android/app/src/main/res/drawable/launch_background.xml`, `drawable-v21/launch_background.xml` | Native launch-screen drawable resources. |
| `frontend/android/app/src/main/res/values/styles.xml`, `values-night/styles.xml` | Android launch/normal theme resources. |
| `frontend/android/app/src/main/res/mipmap-{hdpi,mdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png` | Density-specific Android launcher icons. |
| `frontend/android/.gitignore`, `frontend/.gitignore` | Android and Flutter ignore rules. The frontend ignore excludes generated/cache/platform folders but now explicitly tracks the project test suite and Gradle wrapper properties. |
| `frontend/.metadata` | Flutter project metadata. |
| `frontend/analysis_options.yaml` | Dart/Flutter lint configuration. |
| `frontend/pubspec.yaml` | Package name, SDK constraint, dependencies, assets, and Flutter configuration. |
| `frontend/pubspec.lock` | Resolved Dart package versions (tracked). |
| `frontend/README.md` | Frontend setup notes; now requests Flutter 3.44+ and Android Studio/JDK 17, though other sections remain historical/unfinished. |
| `frontend/test/ui_smoke_test.dart` | Tracked widget tests for the Material 3 theme, compact/wide navigation and current destinations, notice rendering, filter interaction, large-text/touch target behavior, keyboard-constrained composer layout, and action-menu Hero tags. |

## Backend source (`backend`)

| Path | Purpose |
| --- | --- |
| `main.ts` | Creates Oak application, starts a non-awaited DB connectivity check, registers health/error test routes, middleware, routes, and listens on port 8000. |
| `main_test.ts` | Small active assertion/utility tests plus commented examples; imports DB-dependent modules. |
| `deno.json` | Deno tasks and import map for Oak, standard packages, logging, and JOSE. |
| `deno.lock` | Local lockfile is ignored/not tracked; no committed dependency lock for the backend. |
| `routes/routesMod.ts` | Barrel exporting user and notice routers. |
| `routes/userRoutes.ts` | Login, user list/get/create/update/delete route declarations and guards. |
| `routes/noticeRoutes.ts` | Notice CRUD/list and S3 route declarations/guards. |
| `controllers/controllersMod.ts` | Barrel exporting user and notice handlers. |
| `controllers/userController.ts` | User route handlers and role-level mapping; login issues a JWT after control-number lookup without password verification. |
| `controllers/noticeController.ts` | Notice CRUD/list handlers, role checks, filter parsing, and response shaping. |
| `auth/authMod.ts` | Barrel exporting JWT setup, middleware, and roles. |
| `auth/authSetup.ts` | Reads JWT secret from `.env`, signs and verifies HS256 JWTs. |
| `auth/authMiddleware.ts` | Reads Bearer token, verifies it, adds user identity/role to Oak state, and provides `requireRole`. |
| `auth/userRoles.ts` | Role enum and JWT claims interface; claim shape does not fully match the login payload as currently constructed. |
| `models/modelsMod.ts` | Barrel exporting notice and user models. |
| `models/userModel.ts` | User queries and transactional user/group/role creation/update operations. |
| `models/noticeModel.ts` | Notice queries, filtering/pagination, CRUD, and dynamic update statement construction. |
| `db/dbMod.ts` | Barrel exporting PostgreSQL client/query helpers and safe-query wrappers. |
| `db/safeQueries.ts` | Synchronous wrapper helpers that rethrow as `AppError`; their signatures do not model the active async query helpers well. |
| `db/postgres/client.ts` | Loads DB environment, initializes `npm:postgres` connection pool, connectivity check, and close function. |
| `db/postgres/dbQueries.ts` | Async SQL execution/query/transaction/pagination helpers using `sql.unsafe`. |
| `db/migrations/01_schema.sql` | Creates roles, groups, users, associations, classes, notices, polls/responses, and resources tables. |
| `db/migrations/02_indexes.sql` | Indexes common user, notice, poll, and resource query fields. |
| `db/migrations/03_seed.sql` | Idempotent seed statements for roles, groups, and development users; do not copy its sensitive-looking sample values into docs. |
| `db/DB_flowchart.svg` | Exported database relationship diagram. |
| `proxy/proxyMod.ts` | Barrel exporting S3 configuration/service/handlers. |
| `proxy/s3config.ts` | Loads required S3 credentials and hard-coded region/bucket/prefix configuration during module initialization. |
| `proxy/s3service.ts` | S3 client wrapper for upload, presigned URLs, delete, list, and extension-to-content-type mapping. |
| `proxy/s3uploadHandler.ts` | Multipart upload and delete handlers. |
| `proxy/s3fetchHandler.ts` | File fetch/presigned URL redirect and list handlers. |
| `utils/utilsMod.ts` | Barrel exporting types, logging/error handling, validation, response helpers, and rate limiter. |
| `utils/types.ts` | Log/response interfaces, `AppError`, and error conversion helper. |
| `utils/validation.ts` | Validation middleware for user/notice creation; user validation is commented out at its route, and notice validation expects fields that differ from some controller semantics. |
| `utils/responseUtils.ts` | `isEmptyObject` helper. |
| `utils/errorHandling.ts` | User-existence helpers and error-response formatter; several older helpers are commented out. |
| `utils/logging.ts` | Oak request/error middleware and Deno standard logger setup. |
| `utils/rateLimiter.ts` | Process-local per-IP 100-request/15-minute limiter with an in-memory lock/queue. |
| `dependencies/deps.ts` | Re-exports Deno dotenv loader. |
| `dependencies/depsMod.ts` | Barrel for dependency exports. |
| `backend/readme.md` | Backend technology outline with setup/API sections still marked pending. |
| `backend/API_flow.md` | Brief RBAC notes that do not enumerate every current guard. |
| `backend/roadmap-ish.md` | Historical database/product roadmap and older SQLite migration instructions; not the current backend setup guide. |
| `backend/docs.md` | Tracked Markdown-named file could not be decoded/read as normal text in this inspection; its contents are not relied on here. |
| `backend/.gitignore` | Backend ignore patterns. |
| `backend/.vscode/settings.json` | Editor workspace settings. |

## UX reference files

See [UX reference inventory](../references/ux-assets.md) for each PDF/PNG and the rule that current code behavior is the interaction baseline for this update.

## Local-only state noted during inspection

The workspace had ignored `.env`, Deno cache, upload, SQLite-named, and generated Flutter artifacts. Their existence can affect local runs, but they are not treated as committed source or reproduced in this inventory. Environment values were not inspected or copied.
