# Registo de decisões

Cada ADR distingue decisões confirmadas de pressupostos. HO-000 confirma a stack e o workflow GitHub; HO-001 revê produto/autenticação em ADR-004; o estudo Microsoft fica como referência adiada. Alterações posteriores preservam a decisão anterior e a evidência.

| ID | Decisão | Estado |
|---|---|---|
| [ADR-001](ADR-001-stack.md) | Monorepo, .NET, React, Flutter e PostgreSQL | Aceite em HO-000 |
| [ADR-002](ADR-002-outlook.md) | Estudo Microsoft e sincronização originalmente proposta | Substituída por ADR-004; Graph real adiado |
| [ADR-004](ADR-004-independent-core.md) | Core autónomo, Identity e fases Outlook opcionais | Decisão do responsável em HO-001; concretizada em ADR-005 |
| [ADR-003](ADR-003-workflow.md) | PRs, backlog versionado e contexto Codex | Aceite em HO-000 |

| [ADR-005](ADR-005-identity-implementation.md) | Implementação Identity, membros e limites de sessão | HO-003 integrado; CI verificada em HO-004 |
| [ADR-006](ADR-006-transactional-planning.md) | Planeamento transacional, revisões, idempotência e datas | HO-004; revisão humana pendente |

Novos ADRs incluem contexto, decisão, alternativas, consequências, evidência e ID da tarefa/PR. Não apagar decisões antigas; marcar como superseded e ligar a substituição.
