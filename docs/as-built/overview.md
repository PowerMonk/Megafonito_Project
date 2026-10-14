# As-built project overview

## Product intent

Megafonito is intended to keep school announcements and related institutional communication in a dedicated application rather than mixing it into personal messaging applications. The domain can also extend to other organizations with the same announcement-clutter problem. The repository contains a Flutter client prototype, a separately implemented Deno/Oak API, SQL schema/migrations, and UX reference material.

## Current state at a glance

| Area | Observed state |
| --- | --- |
| Mobile UI | Flutter app with Spanish-language screens and five persistent destinations. Android is the documented primary target. |
| Home feed | **Mock-only.** `ApiService` returns sample notices; the Flutter client does not make HTTP calls to the API. |
| Login and registration | **Mock-only / development bypass.** Login enters a hard-coded development flow; credentials are not sent to the backend. |
| Notice creation | Form and callback exist, but current mock creation is transient and is lost when the mock dataset is rebuilt. |
| Attachments | Picker UI is wired, but `StorageService` generates mock URLs instead of uploading bytes. |
| Other screens | Contacts, opportunities, processes, profile, and support have local example content; several actions are placeholders. |
| Backend | Separate Deno/Oak service with route/controller/model/database layers, JWT helpers, PostgreSQL query code, and S3 proxy code. Not verified as a deployable integrated service. |
| Database | PostgreSQL migrations define roles, groups, classes, users, notices, polls, and resources. Startup does not apply migrations. Poll/resource APIs are absent. |
| Delivery checks | CI builds an Android release APK on selected pushes; it does not run Flutter analysis/tests or backend checks. |

## Architectural boundary

The intended product can be thought of as a mobile client, API, PostgreSQL database, and object storage. The current runtime boundary is different: the Flutter UI calls mock services and local assets; the backend is an independent server. Do not treat the README's feature list as proof of end-to-end behavior.

```text
Current Flutter prototype
  screens -> widgets -> mock/local services -> in-memory sample data/assets

Separate backend implementation
  Oak routes -> controllers -> models -> PostgreSQL query helpers
                         \-> S3 handlers -> S3 service
```

## Strengths worth preserving

- Frontend folders distinguish screens, shared widgets, models, services, and utilities.
- Backend folders distinguish routes, controllers, models, auth, database code, storage proxy, and utilities.
- The SQL schema and migrations are separate from application code and include several useful relational foundations.
- The home shell uses an indexed content stack and a dedicated navigation widget; the UI has reusable notice/detail widgets.
- UX PDFs, a database diagram, API-flow notes, a roadmap, and a Flutter build workflow provide useful historical context.

## Current risks and interpretation

The most important gaps are not cosmetic: the client is disconnected from the API; login is not credential authentication; the backend has authorization and audience-filtering defects; persistence, migrations, and container setup are incomplete. These are catalogued in [Known gaps](known-gaps.md) and kept distinct from the UI-only modernization scope.

## Naming and language

The code uses Spanish names for many screens/actions (for example, `AnunciosScreen`) alongside English names for other screens and layers. This document preserves code identifiers when naming symbols and uses English prose for cross-project documentation. Renaming identifiers is not part of the visual refresh.
