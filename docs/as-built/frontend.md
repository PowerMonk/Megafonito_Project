# Frontend as built

## Runtime and app entry

`frontend/lib/main.dart` creates `MyApp`, a `MaterialApp`, and opens `SplashScreen`. The app now uses a shared light Material 3 theme from `frontend/lib/theme/app_theme.dart`; the previous theme was minimal (black scaffold/background defaults and a small text override), while screens independently set many colors, dimensions, and component styles. The dependency list includes Flutter Material, SVG, file picker, Firebase/Google Sign-In, networking, URL launching, and platform HTTP packages; their presence does not mean the active app flow uses them.

The current coded shell is the source of truth for behavior: Home (`AnunciosScreen`), Contacts, Opportunities, Processes, and Account. Support is opened from the app bar, not a bottom destination. The pages are retained in an `IndexedStack` for the non-feed sections. Compact windows use a Material 3 `NavigationBar`; windows at least 600 logical pixels wide use a `NavigationRail`, with the same destinations and index state.

## Screen inventory and behavior

| Screen | Current behavior |
| --- | --- |
| Splash | Shows the logo and a timer-driven progress bar, then navigates to Login. It is not a real initialization/progress check. |
| Login | Presents a development-mode bypass; calls `AuthService.login` with a fixed dev identity and always enters the shell with superuser UI enabled. |
| Register | Validates nonempty name/email/password and calls a mock registration service. It is not connected to API login/registration. |
| Home / announcements | Loads five notices per page through `NoticesService` -> `ApiService`, offers category chips, pull-to-refresh, pagination, notice detail, a support app-bar action, and a superuser create menu. |
| Contacts | Filters a hardcoded sample contact list by name and copies single fields or the whole contact to clipboard. |
| Opportunities | Discovers career logos from assets, displays local categories, and opens mock opportunity listings/details. |
| Opportunity content | Shows generated sample scholarship/course/job items; detail content and expiry data are hardcoded. |
| Processes | Shows a calendar card, FAQ questions, and an enrollment-process card. Current taps show placeholder feedback or do nothing meaningful. |
| Account | Shows hardcoded profile information, clipboard controls, a placeholder schedule card, and routes to login on sign-out. The sign-out path does not call `AuthService.logout`. |
| Support | Shows bug report/suggestion/contact options; their actions are placeholders. |
| Notice composer | Validates that title/content are nonempty, provides category/group selection and mock attachment selection, then calls the shell callback. |
| Opportunity composer | Presents a form and optional create callback; the shell does not supply the callback. |
| Message composer | Presents a form and optional send callback; the shell does not supply the callback. |

## Home feed data flow

1. `AnunciosScreen._loadNotices` calls `NoticesService.loadNotices(page, limit: 5, category)`.
2. `NoticesService` delegates to `ApiService.getNotices`.
3. `ApiService` delays, constructs sample notice data in memory, filters/paginates that list, and returns a JSON-like map.
4. The shell maps records to display maps and renders `NoticeCard`; tapping opens `NoticeDetail`.
5. Refresh resets the page/list; reaching the pagination footer requests the next page.

No URL/client call to `backend/` occurs in these services. The app's `authenticatedRequest` method is a mock stub; `AuthService` independently fabricates a user.

## State and data caveats

- `NoticesService.createNotice` inserts into the fresh map returned from `ApiService.getMockNotices`; subsequent reload reconstructs the sample data, so the created record is not durable.
- `StorageService` asks the native picker for a file but does not pass bytes to the API or S3. It generates fake file URLs/keys.
- The notice and opportunity composers each connect their Link field to the title controller; link input overwrites the title and is not independently submitted. This is a functional defect, not a visual-only issue.
- Notice creation forwards only the first selected attachment even though the UI list can hold multiple.
- Composer upload state is now shown while the picker/upload simulation runs; attachment previews still assume a network image.
- The feed's selected sort state is unused. Its popup choices trigger a reload, but only category is passed to the service. The sort helpers expect a `fecha` key that the sample maps do not have.
- `NoticeCard` now displays the record's `created_at`; the earlier fixed date was removed as a presentation defect.
- Notice-detail expiry falls back to a fixed display value when the sample record has no expiry; opportunity examples use hard-coded expiry dates and a hard-coded institution URL.
- Some hardcoded profile values exist in source. They are not reproduced in these docs.

## UI component boundaries

- `AppNavBar` defines the five current bottom destinations and SVG icons.
- `AppNavigationRail` presents the same five destinations on wide layouts. Both nav controls keep the existing destination order.
- `ActionButtons` owns the home create affordances/backdrop; it is only displayed for `isSuperUser`. Expanded action FAB Hero tags are unique.
- `NoticeCard`, `NoticeDetail`, `NoticeTag`, and opportunity detail widgets provide reusable feed/detail UI.
- `NoticesFilter` owns category-chip and popup selection state and reports selections through callbacks.

## Framework and visual system

The frontend `pubspec.yaml` declares Dart `>=3.3.1 <4.0.0` and its README asks for Flutter 3.19.5 or newer. The refreshed lockfile resolves to Dart `>=3.8.0` / Flutter `>=3.27.0`, so the README/pubspec/lockfile minimums are not aligned; local verification used Flutter 3.47.7 / Dart 3.13.5. Material 3 is available from Flutter 3.10 and defaults on from Flutter 3.16, but app code explicitly selects it. No third-party Material component library is required for the refresh.

## UI implementation outcome

The home create-action menu now transitions with a short fade/slide and uses a lightweight dim overlay instead of a full-screen blur filter. The notice composer uses the full page surface with borderless, transparent fields rather than a detached card. Opportunity artwork is contained within smaller square image windows; the horizontal cards intentionally reveal part of the next item. The approved design, interaction boundaries, accessibility checks, and implementation sequence are recorded in [the modernization plan](../ui/modernization-plan.md). The refresh does not imply that the mock services, auth, or storage have become production integrations. Current widget-test coverage is indexed in [Build and tests](build-and-tests.md).
