# Registo de decisões

Cada ADR distingue decisões confirmadas de pressupostos. HO-000 confirma a stack e o workflow GitHub; HO-001 revê produto/autenticação em ADR-004; o estudo Microsoft fica como referência adiada. Alterações posteriores preservam a decisão anterior e a evidência.

| ID | Decisão | Estado |
|---|---|---|
| [ADR-001](ADR-001-stack.md) | Monorepo, .NET, React, Flutter e PostgreSQL | Aceite em HO-000 |
| [ADR-002](ADR-002-outlook.md) | Estudo Microsoft e sincronização originalmente proposta | Substituída por ADR-004; Graph real adiado |
| [ADR-004](ADR-004-independent-core.md) | Core autónomo, Identity e fases Outlook opcionais | Decisão do responsável em HO-001; concretizada em ADR-005 |
| [ADR-003](ADR-003-workflow.md) | PRs, backlog versionado e contexto Codex | Aceite em HO-000 |

| [ADR-005](ADR-005-identity-implementation.md) | Implementação Identity, membros e limites de sessão | HO-003 integrado; CI verificada em HO-004 |
| [ADR-006](ADR-006-transactional-planning.md) | Planeamento transacional, revisões, idempotência e datas | HO-004 integrado; CI aplicável verificada em HO-005 |

| [ADR-007](ADR-007-web-planning-and-active-platforms.md) | Planeamento Web, recuperação idempotente e alvos Web/Android | HO-005 integrado; quatro checks de integração verificados em HO-006 |

| [ADR-008](ADR-008-onsite-and-tasks.md) | Presenças, leitura, resolução transacional e tarefas | HO-006 integrado pelo PR #33; quatro checks de integração verificados em HO-007 |

Novos ADRs incluem contexto, decisão, alternativas, consequências, evidência e ID da tarefa/PR. Não apagar decisões antigas; marcar como superseded e ligar a substituição.

| [ADR-009](ADR-009-durable-notifications.md) | Worker durável, caixa Web/Android e infraestrutura FCM | HO-007 integrado pelo PR #34; quatro checks de integração verificados em HO-010; registo revisto por ADR-010 |
| [ADR-010](ADR-010-android-fcm-registration.md) | Registo FCM Android oficial por FID e adaptação Flutter | HO-007; correções motivadas pelo ensaio real |

| [ADR-011](ADR-011-android-planning.md) | Calendário/pedidos Android, recuperação por conta e continuidade da base aprovada | HO-010 integrado pelo PR #35; quatro checks de integração verificados em HO-011 |

| [ADR-012](ADR-012-core-interfaces.md) | Interfaces core, journal comum e aceitação Web/Android | HO-011 integrado pelo PR #36; quatro checks de integração verificados em HO-013 |
| [ADR-014](ADR-014-owner-bootstrap.md) | Bootstrap explícito do titular, extensão idempotente e auditoria de acesso | HO-013 integrado pelo PR #42; CI de integração verificada em HO-014 |

ADR-013 está reservado à proposta operacional no [PR draft #37](https://github.com/Dennyum204/HomeOfficeReservation/pull/37); não foi importado para esta entrega.

| [ADR-015](ADR-015-access-invitations.md) | Ciclo de convite Identity, entrega durável protegida e recuperação | HO-014; critérios/CI no PR da tarefa |

- [ADR-016 — Administração Web e concorrência de acesso](ADR-016-web-administration.md) — HO-015, complementa ADR-014/015.
- [ADR-017 — Identidade visual partilhada](ADR-017-shared-visual-theme.md) — HO-016, cores Claude + adaptadas e hierarquia Web/Android.
