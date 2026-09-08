# Web area

Read root AGENTS.md and docs/UX.md.

- React with strict TypeScript. Organize code by product feature.
- Consume generated OpenAPI clients; do not hand-copy DTOs or business approval rules.
- ASP.NET Core Identity session cookie for Web; CSRF on mutations including login/logout. No Microsoft account required. Never persist auth or Graph tokens in browser storage.
- Render confirmed location, pending proposals and conflicts as distinct information.
- Calendar controls support keyboard access and do not rely only on color.
- Implement loading, empty, error, stale-version and offline states for every critical flow.
- Preserve user drafts on request failure; definitive approvals wait for API success.
- Use focused interaction/E2E tests. Include screenshots when reviewing UI changes.
- Follow README.md/package.json for exact npm, lockfile and lint/typecheck/build/test commands. HO-002's shell clearly marks business features as unfinished; connectivity must use the generated client and a real API in browser smoke tests.
