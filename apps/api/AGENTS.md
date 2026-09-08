# Backend area

Read root AGENTS.md, docs/DOMAIN.md and docs/adr/ADR-004-independent-core.md first. Read docs/OUTLOOK.md only for optional integration work.

- Own business rules, authorization, transaction boundaries and API contracts here. Core login/calendar use ASP.NET Core Identity and PostgreSQL without Microsoft credentials or Graph calls.
- Domain must not reference EF Core, HTTP, Graph SDK or UI libraries.
- Application defines use cases and adapter interfaces; Infrastructure implements persistence and external delivery.
- Prefer explicit feature-focused use cases. Do not add a generic repository/unit-of-work framework over EF Core without a demonstrated need.
- Validate object ownership and reporting relationship for every read/write. API DTOs do not expose token caches or imported private calendar payloads.
- Coordinate approval/presence conflicts through employee planning version and a transaction. An ETag on one aggregate alone is insufficient.
- Keep Graph calls outside the business transaction; use durable outbox, idempotency and reconciliation.
- Integration tests use PostgreSQL for relational/concurrency behavior; an in-memory EF provider does not verify these properties.
- HO-002 must add exact restore/build/test/format commands and compatible SDK/package pins. No backend project or build command exists yet in this directory.
