# Configuration and deployment (as built)

## Backend environment expectations

The code loads `.env` from `Deno.cwd()` in the backend DB, JWT, and S3 modules. The code expects these names:

| Variable | Use |
| --- | --- |
| `DB_NAME` | PostgreSQL database name; required. |
| `DB_PASSWORD` | PostgreSQL password; required. |
| `DB_HOST` | Database host; defaults to `localhost` if unset. |
| `DB_PORT` | Database port; defaults to `5432`. |
| `DB_USER` | PostgreSQL username. |
| `SECRET_JWT` | JWT signing key. |
| `S3_ACCESS_KEY` | S3 credentials; required by the eager S3 config module. |
| `S3_SECRET_KEY` | S3 credentials; required by the eager S3 config module. |

The S3 bucket, region, and endpoint are currently constants in `backend/proxy/s3config.ts`; this is test-oriented configuration. No values from local `.env` files are included here.

## Deno tasks and permissions

`backend/deno.json` declares `dev` and `server` tasks. The `server` task grants broad network, read, and write permissions (`-N -R -W`) in addition to environment and FFI permissions. The committed `deno.lock` is absent/ignored, so dependency resolution is not pinned by a tracked lockfile. The local command may also depend on Deno version and cached dependencies.

## Docker/Compose facts

- The root Dockerfile packages the Deno API and executes `deno task server` on port 8000.
- Compose defines only an `api` service; it does not define PostgreSQL or S3.
- Compose build context is `./backend`; the tracked `.dockerignore` is at repository root and is not the ignore file for that context. Backend `.env` or other local files can therefore be at risk of being sent/copied into a build context unless an ignore file is added at the context root.
- Compose bind-mounts `./backend` to `/app`, and mounts an SQLite-named file despite the code using PostgreSQL.
- There is no automated migration step or database health dependency.
- `README.Docker.md` says cloud deployment has not been tested; this remains an appropriate status.

## Frontend toolchain and delivery

The frontend now declares Flutter 3.44+ / Dart 3.13+, Android Studio, and JDK 17, matching its file_picker 13.3 dependency and resolved lockfile. Local verification used Flutter 3.47.7 and Dart 3.13.5. Android config pins Gradle 9.3.1 and AGP 9.1.0; the app uses AGP built-in Kotlin, with KGP 2.4.0 declared apply-false for plugin resolution and the legacy DSL compatibility flag retained during migration. The app build uses `flutter.minSdkVersion`. The unused `cronet_http` adapter was removed because its transitive Cronet artifacts declared conflicting Android namespaces under AGP 9; no Dart source referenced it. CI still uses the moving Flutter `stable` channel rather than a pinned SDK and runs `flutter create .`, `flutter pub get`, then a release APK build. Android is the declared primary target. Other generated platform folders may exist in a local checkout without being tracked.

## Run/check commands

Run from each component directory:

```powershell
# frontend
flutter pub get
flutter analyze
flutter test
flutter build apk --release

# backend (configuration and PostgreSQL required)
deno check main.ts
deno test --allow-env --allow-read --allow-net main_test.ts
deno task server

# repository root
docker compose config
docker compose build api
```

The exact frontend lint and test state is documented in [Build and tests](build-and-tests.md). The lockfile now records the transitive resolution used by the verified Flutter 3.35 toolchain; do not add unrelated direct dependencies for future visual work.
