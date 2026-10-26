# Build and tests

## CI

`.github/workflows/flutter-ci.yml` is triggered by pushes to `main` affecting `frontend/**`, or manually. It installs the current stable Flutter channel, generates missing Flutter files, fetches packages, builds `flutter build apk --release`, and uploads the APK. It does not currently run formatter checks, `flutter analyze`, `flutter test`, Deno checks, or backend tests.

## Frontend baseline and current result

Local Flutter at inspection time: **3.47.7 stable** with **Dart 3.13.5**. Resolving packages on this SDK changed 14 transitive entries within existing dependency constraints; no direct dependencies or UI libraries were added. The updated `pubspec.lock` matches the tested graph, and `flutter pub get --enforce-lockfile --offline` succeeds.

Baseline `flutter analyze` before the UI work reported **116 diagnostics**. Those lint and async-context issues were addressed during the update; current `flutter analyze --no-pub` reports **no issues**.

The repository previously ignored `frontend/test/` and had an untracked generated counter example there. The counter test did not match this application and was removed; the ignore rules now allow the project-specific `frontend/test/ui_smoke_test.dart` suite to be tracked.

Current widget suite: **9 passing tests**. It covers Material 3 activation, five-destination navigation and Support on compact/wide layouts, navigation through the current destinations, notice metadata/tap behavior, category-chip selection/clear, large-text contact layout and 48dp copy target, keyboard-constrained notice composer scrolling, opportunity image containment/peek of the next card, distinct expanded action Hero tags, and animated action-menu open/close behavior. The test runner prints non-fatal `flutter_svg` warnings for embedded `<font>`, `<style>`, and `<metadata>` elements in the current logo SVG.

The Android toolchain was aligned to Gradle 8.14, Android Gradle Plugin 8.11.1, Kotlin Gradle Plugin 2.2.20, and Flutter's `minSdkVersion` value. Both `flutter build apk --debug --no-pub` and `flutter build apk --release --no-pub` passed. Flutter 3.47.7 warns that these Gradle/AGP/Kotlin versions will be unsupported in a future release; they are the current non-AGP-9 combination that builds this project with its existing Kotlin Gradle plugins. The Flutter migrator added `android.builtInKotlin=false` and `android.newDsl=false`. No Android emulator was connected, so manual Android screenshot review was unavailable.

## Backend baseline

`backend/main_test.ts` includes a trivial assertion and `isEmptyObject` tests. It also imports database-dependent modules and contains commented-out proposed tests. There is no comprehensive route/model/integration test suite. Because DB setup loads environment at module import time, tests can require local configuration even when test bodies do not use the database.

No backend checks or DB-backed API calls are included in the Flutter workflow. Database/S3 credentials and services are needed to run the server; do not treat compilation alone as validation of authorization, schema application, or cloud storage.

## UI modernization verification

The approved checks and acceptance criteria are listed in [Modernization plan](../ui/modernization-plan.md). Widget coverage exercises narrow and wide window constraints, text scaling, touch-target sizing, keyboard insets, selected navigation, and overlay actions. Device-level focus/contrast/screenshot checks still require a connected Android device/emulator.
