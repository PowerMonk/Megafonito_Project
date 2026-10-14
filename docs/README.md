# Megafonito documentation

This documentation records the repository as it exists, then describes the approved visual modernization work. It is an **as-built record**, not a claim that every feature is ready for production.

## Contents

### As-built record

- [Project overview](as-built/overview.md) — product intent, current status, and major boundaries.
- [Repository map](as-built/repository-map.md) — purpose of tracked folders and files, including assets and delivery configuration.
- [Frontend](as-built/frontend.md) — Flutter structure, screens, widgets, services, and actual UI behavior.
- [Frontend flows](as-built/frontend-flows.md) — navigation and mock-data flows.
- [Backend](as-built/backend.md) — Deno/Oak startup, middleware, code layers, and current implementation status.
- [API reference](as-built/api-reference.md) — routes, observed guards, and request/response behavior.
- [Data model](as-built/data-model.md) — SQL tables, migrations, and implemented persistence paths.
- [Configuration and deployment](as-built/configuration-and-deployment.md) — runtime requirements and discrepancies in local/container setup.
- [Build and tests](as-built/build-and-tests.md) — repository checks and test coverage as observed.
- [Known gaps](as-built/known-gaps.md) — evidence-based defects, risks, and unfinished capabilities.

### UI work

- [UI audit](ui/audit.md) — current visual/interaction baseline and UI-specific findings.
- [Modernization plan](ui/modernization-plan.md) — the agreed design direction, scope, sequence, and acceptance criteria.
- [UX reference inventory](references/ux-assets.md) — existing design assets and how they are treated in this work.

## Status vocabulary

- **Implemented** — code exists and provides the described local or server behavior.
- **Mock-only** — an interface or service simulates behavior and does not use the real backend/storage.
- **Partially implemented** — some paths work, but the feature is incomplete or has a known broken path.
- **Currently broken** — source evidence indicates the path cannot behave as intended.
- **Schema-only** — represented in SQL but not backed by an active API/model flow.
- **Planned / historical note** — described in a roadmap or design artifact, not assumed to exist in code.

## Accuracy and safety notes

The Flutter app and Deno API are documented as separate components: the active Flutter services do not call this backend. Endpoint behavior is described from the route/controller implementation, not copied from the READMEs. Local secrets, ignored environment values, and personal data in examples or local configuration are intentionally omitted. The SQL seed includes credentials/identity-like data; those values are not reproduced here.

The inventory focuses on tracked project files. Local ignored state (for example, environment files, caches, an SQLite-named artifact, uploaded files, and generated Flutter targets) is described only in broad terms where it affects reproducibility or configuration.
