# Fontes técnicas oficiais

Consultadas em 2026-09-07. As decisões de produto e intervalos operacionais são propostas deste projeto, não obrigações dos fornecedores. Revalidar documentação e versões quando implementar a integração.

Direção atual: fontes de ASP.NET Core Identity, Identity API, Data Protection, recuperação de conta e armazenamento seguro Flutter consultadas em **2026-09-08**, com decisões/limitações em [ADR-004](adr/ADR-004-independent-core.md). Autenticação própria escolhida; ainda não implementada.

Referência histórica opcional: fontes Microsoft Graph/MSAL/AppAuth consultadas em **2026-09-08** no [estudo HO-001](HO-001-MICROSOFT-OUTLOOK-STUDY.md). O estudo não valida Graph real e não define o login core. Onboarding interrompido, integração adiada para HO-008/HO-009.

| Tema | Fonte |
|---|---|
| .NET suportado / LTS | [Microsoft .NET releases and support](https://learn.microsoft.com/en-us/dotnet/core/releases-and-support) |
| Arquitetura Flutter | [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations) |
| Componentes React | [Thinking in React](https://react.dev/learn/thinking-in-react) |
| Identidade e PKCE | [Microsoft identity auth code flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow) |
| Calendário Outlook | [Calendar API overview](https://learn.microsoft.com/en-us/graph/outlook-calendar-concept-overview) |
| Permissões | [Microsoft Graph permissions reference](https://learn.microsoft.com/en-us/graph/permissions-reference) |
| Calendário incremental | [event: delta](https://learn.microsoft.com/en-us/graph/api/event-delta?view=graph-rest-1.0) |
| Eventos / all-day / transactionId | [event resource](https://learn.microsoft.com/en-us/graph/api/resources/event?view=graph-rest-1.0) |
| Subscrições e expiração | [Change notifications overview](https://learn.microsoft.com/en-us/graph/change-notifications-overview) |
| Validação de webhook | [Delivery through webhooks](https://learn.microsoft.com/en-us/graph/change-notifications-delivery-webhooks) |
| Throttling | [Graph throttling guidance](https://learn.microsoft.com/en-us/graph/throttling) |
| IDs imutáveis | [Outlook immutable identifiers](https://learn.microsoft.com/en-us/graph/outlook-immutable-id) |
| Instruções Codex | [AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md) |
| Proteções GitHub | [Protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches) |
| Checkout fixado no workflow documental | [Commit verificado 11bd719](https://github.com/actions/checkout/commit/11bd71901bbe5b1630ceea73d27597364c9af683) |
