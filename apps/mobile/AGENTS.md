# Mobile area

Read root AGENTS.md and docs/UX.md.

- Flutter/Dart for Android and iOS. Separate views/viewmodels from repositories/services.
- Consume generated API client; keep authoritative approval/conflict rules in the backend.
- Both employee and manager can complete V1 flows on mobile, including partial approvals.
- Use system-browser OIDC/PKCE via a maintained integration validated in HO-001; no embedded client secret, no handwritten OAuth implementation.
- Store app auth material in platform secure storage. Graph tokens remain server-side.
- A push opens the authenticated detail screen and never performs approval directly. Handle permission denied, token rotation and revoked sessions.
- Writes require network in V1; label cached reads as stale. Do not imply offline decisions were submitted.
- Do not commit signing keys. Record actual supported targets and distribution validation.
- Add pinned Flutter SDK and exact analyze/test/build commands in HO-002. No mobile project/build has been created yet.
