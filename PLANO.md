# Plano — HomeOfficeReservation

Atualizado: 2026-09-10. Direção confirmada: core autónomo, Outlook opcional. [ADR-004](docs/adr/ADR-004-independent-core.md) substitui os pressupostos Microsoft anteriores. HO-012 permanece draft; domínio ferbatech.com escolhido, alojamento por aprovar. [Proposta corrente](docs/HO-012-PILOT.md) e [acesso privado por convite](docs/HO-012-PRIVATE-ACCESS.md).

## Core V1

Calendário próprio autoritativo, com remoto Portugal, presencial Suíça, pedidos pendentes e períodos presenciais obrigatórios. Contas Employee/Manager da aplicação, autenticação independente, relação de gestão configurada e autorização no backend.

Pedidos/rascunhos, aprovação parcial/rejeição, comentários, revisões, conflitos preservando aprovações, motivos de presença e tarefas atribuídas pelo gestor. Notificações internas e push mobile continuam core. Indisponibilidade manual não transforma trabalho remoto em ausência. Web e mobile usam o mesmo backend.

## Stack

.NET 10/ASP.NET Core, EF Core/PostgreSQL, ASP.NET Core Identity, React/TypeScript e Flutter Android. iOS adiado para HO-306, sem data; código e validações históricas preservados. OpenAPI com clientes gerados. Monólito modular e outbox/worker durável para notificações; sem serviço de identidade externo ou protocolos de autenticação próprios.

HO-002 prepara projetos/SDKs/lockfiles/CI/contratos e PostgreSQL local. HO-003 implementa login e autorização. Alojamento, assinatura e distribuição são definidos em HO-012; nenhum ambiente foi lançado.

## Marcos separados

| Marco | Âmbito / gate |
|---|---|
| Core v1.0 | HO-000 a HO-007, HO-010 a HO-015; contas locais por convite, titular administrador/colaborador e piloto de duas semanas, sem Microsoft |
| ui-refresh | HO-016: Claude +, claro/escuro e hierarquia Web/Android, só quando selecionado; sem gate do piloto |
| outlook-publish | HO-008 após core: ligar opcionalmente em Definições, publicar dias explícitos confirmados como livres, eventos próprios, sem convites |
| outlook-sync | HO-009 após publicação: disponibilidade, delta/páginas/recorrência, webhooks/lifecycle e reconciliação externa |
| v1.1 | Lembretes/resumo semanal, exportação e preferências após piloto core |
| v1.2 | Recorrência de pedidos, meios dias/viagens e planeamento flexível |
| v2.0 | Expansão por necessidade: equipa, calendários adicionais, Google, anexos e offline |

Outlook não decide aprovações nem condiciona lançamento. Onboarding Microsoft foi interrompido; a validação real foi adiada, nunca declarada aprovada. Pesquisa/probe ficam como referência opcional. O [backlog](docs/BACKLOG.md) conserva os IDs originais e histórico e acrescenta novas tarefas sem renumeração, com milestones independentes; datas não são promessas.

## Continuidade

Histórico: PR #27 integrou documentação/decisões e tracking; HO-002 entregou fundações no [PR #28](https://github.com/Dennyum204/HomeOfficeReservation/pull/28), seguido por HO-003 e pelos fluxos core. Estado atual e evidência de integração até HO-011 em [STATUS](STATUS.md). HO-012 continua no PR draft #37: decidir alojamento; HO-013/014/015 registam lacunas de acesso por convite em tarefas próprias e HO-016 a melhoria visual futura. Nenhuma implementação destes novos itens foi iniciada. Fernando revê e faz merge; Codex não integra nem ativa auto-merge. Consultar [DEVELOPMENT](docs/DEVELOPMENT.md) e os [prompts](docs/CODEX_TASKS.md); não iniciar outro item sem pedido.
