# Codex project instructions

## Purpose and current phase

Build a shared Switzerland/Portugal work-location planner for an employee and their manager. The core V1 has its own authoritative calendar and ASP.NET Core Identity accounts; it must work and ship without Microsoft. Outlook is optional: one-way publication first (HO-008), imports/delta/webhooks/external-edit reconciliation later (HO-009). HO-002 provides runnable API/Web/Flutter foundations; HO-003 implements Identity authentication and authorization. Business flows are later tasks. The requested development model is Codex Astra; select it in the development environment. Do not hard-code a model identifier or make the product depend on an OpenAI API.

User instructions and applicable higher-priority instructions take precedence. These project conventions do not create new approval requirements for already-authorized work.

## Start every task

1. Read README.md, STATUS.md, ROADMAP.md and the selected item in docs/BACKLOG.md.
2. Read docs/PRODUCT.md and relevant architecture/ADR files; then the closest AGENTS.md for the area being edited.
3. Inspect Git status, current branch and repository remote. Preserve unrelated work.
4. Fetch the real remote and check verified merge evidence before evaluating dependencies. For items still marked `review` or `in_progress`, inspect their real PRs: confirm GitHub reports a merge into `main`, the merge commit belongs to the fetched base history (including squash/rebase merges), and relevant integration CI passed. Reconcile stale backlog/STATUS states on the task branch and regenerate derived documents. An issue being closed or a PR merely existing is not merge evidence. Record the actual PR URL and evidence; unresolved evidence stays explicit.
5. Only then check the selected item's dependencies against that reconciled base. Work on one explicitly selected item using a scoped, short-lived branch. Report any genuinely incomplete dependency; do not start another task without authorization or invent completion.
6. Re-read source files before editing. Do not depend on conversation memory for repository state.

## Standing GitHub workflow

- Repository: https://github.com/Dennyum204/HomeOfficeReservation (public). Preserve visibility and keep examples synthetic.
- Codex owns scoped branches, commits, pushes, issue updates and PR preparation for the authorized task. Do not repeatedly ask for authorization already given.
- Every change uses a scoped branch from the verified current base. The one empty initial commit on `main` only establishes a PR base; subsequent development goes through PRs.
- Search existing issues by stable HO ID before creating anything. Keep the real issue URL, acceptance criteria, dependencies, release milestone and release/area labels aligned with `docs/backlog.json`.
- PRs link real issues. Use `Closes #N` only when the PR fulfills the whole issue. Record actual PR URLs in the backlog and keep unmerged work in `review`.
- Completed implementation is handed off in an **undrafted PR**, with relevant CI green on its latest commit and no merge conflicts. Verify the latest head SHA after final pushes. Partial or blocked work remains clearly marked, with a draft PR and concrete remaining criteria.
- Fernando reviews and merges. **Do not merge PRs or enable auto-merge.** After a human merge, the next task verifies merge/integration evidence and reconciles stale statuses before checking dependencies.
- Require PRs, actual stable CI check names and resolved conversations on `main`; prevent force pushes and deletion. For a sole maintainer, require zero independent approving reviewers so Fernando can review and merge his own Codex-authored PRs. Record actual settings and any permission limitation in `docs/DEVELOPMENT.md`.

## Architecture boundaries

- Backend: .NET 10, ASP.NET Core, EF Core and PostgreSQL. Modular monolith; durable outbox/worker in the same host initially.
- Web: React/TypeScript. Mobile: Flutter/Dart. Business authorization, approval transitions and conflict rules are authoritative in the API.
- HTTP contract: OpenAPI with reproducibly generated TypeScript/Dart clients. Do not copy server DTOs manually between clients.
- App authentication uses ASP.NET Core Identity with EF Core/PostgreSQL: browser cookies and framework-issued opaque bearer/refresh tokens for Flutter (ADR-004). No custom cryptography or external identity infrastructure is needed. Optional Microsoft login is a future provider; calendar consent is separate and Graph tokens stay on the backend.
- Infrastructure dependencies point inward toward application/domain abstractions. Do not introduce services, patterns or dependencies without a concrete need.

## Product invariants

- Remote work is not absence. Work location, approval status, availability and conflicts are distinct concepts.
- A manager can decide only for assigned employees. Deny self-approval and cross-organization object access.
- Approved dates survive pending change requests until a replacement is explicitly resolved.
- A presence requirement or Outlook edit cannot silently overwrite approved home office.
- Serialize conflicting decisions for the same employee, re-check current calendar state in the transaction and reject stale writes.
- Planning dates are date-only. Timed events preserve instant and timezone. Never convert an all-day date through UTC midnight.
- Optional Outlook publication targets the connected user's primary calendar: explicit confirmed location days only, availability free by default, app-owned events, no invitations. Imports/delta/webhooks/external-edit reconciliation are deferred and never core release gates.
- External effects use a transactional outbox and idempotent consumers. Never call Graph inside the approval transaction.
- Core availability/conflicts come from the authoritative app calendar. Any future imported private calendar details must not become visible to the manager. Microsoft registration/live-probe onboarding is stopped; resume only within an explicitly selected optional integration task.

## Working conventions

- IDs in docs/backlog.json are stable. It is the canonical release/work-item inventory. ROADMAP.md and docs/BACKLOG.md are generated from it.
- User-facing copy and product docs: European Portuguese initially. Code identifiers: English. Externalize UI strings for later localization.
- Prefer small vertical slices including their contract and tests. Keep unrelated refactoring separate.
- Add tests for state transitions, authorization, concurrency, date semantics, synchronization and critical user journeys; avoid tests that only mirror getters or styling.
- Do not manually edit generated clients or generated backlog documents. Update sources and regenerate.
- Use supported stable dependencies; pin actual SDK versions and lockfiles when scaffolding. Consult official docs for evolving APIs.
- Never commit secrets, calendar payload dumps or production data. Use synthetic fixtures.

## Commands available now

```bash
python3 scripts/check_project.py
python3 scripts/check_project.py --write
```

The second command only regenerates the roadmap/backlog from JSON. Build/test/start commands are in apps/api/README.md, apps/web/README.md and apps/mobile/README.md. Use pinned SDKs and locked restores. Run scripts/generate_contracts.py --check for contract drift. PostgreSQL integration tests require HO_TEST_DATABASE and fail rather than silently skip when it is missing. Optional Outlook reference tests are outside normal core CI. Report local versus remote/platform validation accurately.

## Before handing off a PR

- Run appropriate checks and report exact outcomes, including checks that could not run.
- Inspect the final diff for unrelated edits and credentials.
- Update docs/backlog.json and STATUS.md. An open PR is `review`, not `done`; integration verification closes the work item.
- Add architectural changes as a new ADR, preserving superseded decisions.
- Include scope, acceptance evidence, API/migration impact and recovery notes in the PR.
- Use real issue/PR URLs once available. HO-001 is a work-item ID, not GitHub issue #1.
- Follow existing authorization for remote actions. Do not merge, publish or use production data merely because a template mentions those steps.
- Finish with what changed, what was verified and the next concrete task. Never claim unperformed deployments or remote protection settings.
