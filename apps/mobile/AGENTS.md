# Mobile area

Read root AGENTS.md and docs/UX.md.

- Flutter/Dart for Android and iOS. Separate views/viewmodels from repositories/services.
- Consume generated API client; keep authoritative approval/conflict rules in the backend.
- Both employee and manager can complete V1 flows on mobile, including partial approvals.
- Core login uses the ASP.NET Core Identity API over HTTPS; handle its opaque bearer/refresh tokens through maintained HTTP and platform secure-storage libraries (ADR-004). No Microsoft login, OAuth server or custom token protocol is required. Optional calendar consent uses a separate browser flow later.
- Store app auth material in platform secure storage. Graph tokens remain server-side.
- A push opens the authenticated detail screen and never performs approval directly. Handle permission denied, token rotation and revoked sessions.
- Writes require network in V1; label cached reads as stale. Do not imply offline decisions were submitted.
- Do not commit signing keys. Record actual supported targets and distribution validation.
- Add pinned Flutter SDK and exact analyze/test/build commands in HO-002. No mobile project/build has been created yet.
