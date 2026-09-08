# Plano — HomeOfficeReservation

Atualizado: 2026-09-08. Direção confirmada: core autónomo, Outlook opcional. [ADR-004](docs/adr/ADR-004-independent-core.md) substitui os pressupostos Microsoft anteriores.

## Core V1

Calendário próprio autoritativo, com remoto Portugal, presencial Suíça, pedidos pendentes e períodos presenciais obrigatórios. Contas Employee/Manager da aplicação, autenticação independente, relação de gestão configurada e autorização no backend.

Pedidos/rascunhos, aprovação parcial/rejeição, comentários, revisões, conflitos preservando aprovações, motivos de presença e tarefas atribuídas pelo gestor. Notificações internas e push mobile continuam core. Indisponibilidade manual não transforma trabalho remoto em ausência. Web e mobile usam o mesmo backend.

## Stack

.NET 10/ASP.NET Core, EF Core/PostgreSQL, ASP.NET Core Identity, React/TypeScript e Flutter Android/iOS. OpenAPI com clientes gerados. Monólito modular e outbox/worker durável para notificações; sem serviço de identidade externo ou protocolos de autenticação próprios.

HO-002 prepara projetos/SDKs/lockfiles/CI/contratos e PostgreSQL local. HO-003 implementa login e autorização. Alojamento, assinatura e distribuição são definidos em HO-012; nenhum ambiente foi lançado.

## Marcos separados

| Marco | Âmbito / gate |
|---|---|
| Core v1.0 | HO-000 a HO-007, HO-010 a HO-012; duas contas locais e piloto de duas semanas, sem Microsoft |
| outlook-publish | HO-008 após core: ligar opcionalmente em Definições, publicar dias explícitos confirmados como livres, eventos próprios, sem convites |
| outlook-sync | HO-009 após publicação: disponibilidade, delta/páginas/recorrência, webhooks/lifecycle e reconciliação externa |
| v1.1 | Lembretes/resumo semanal, exportação e preferências após piloto core |
| v1.2 | Recorrência de pedidos, meios dias/viagens e planeamento flexível |
| v2.0 | Expansão por necessidade: equipa, calendários adicionais, Google, anexos e offline |

Outlook não decide aprovações nem condiciona lançamento. Onboarding Microsoft foi interrompido; a validação real foi adiada, nunca declarada aprovada. Pesquisa/probe ficam como referência opcional. O [backlog](docs/BACKLOG.md) conserva os 24 IDs e histórico, com milestones independentes; datas não são promessas.

## Continuidade

PR #27 entrega apenas documentação/decisões e tracking. Fernando revê e faz merge; Codex não integra nem ativa auto-merge. Próxima tarefa é HO-002 numa branch própria a partir de main verificada. Consultar [STATUS](STATUS.md), [DEVELOPMENT](docs/DEVELOPMENT.md) e os [prompts](docs/CODEX_TASKS.md); não iniciar outro item sem pedido.
