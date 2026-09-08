# Estado do projeto

Atualizado: 2026-09-08.

## Situação verificável

- **HO-000 concluído e integrado** pelo [PR #25](https://github.com/Dennyum204/HomeOfficeReservation/pull/25), merge humano em 2026-09-08 às 18:39:50Z, SHA `7257a7b0c88f456b4322da396d45bd4c0aa0e862`. Fetch confirmou o commit em `origin/main`; [CI de integração](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34264376475) passou com `project-docs`. Backlog reconciliado antes de verificar a dependência de HO-001.
- **HO-001 bloqueado parcialmente** na branch `docs/ho-001-microsoft-outlook-study`, criada de main atualizada. [Issue #2](https://github.com/Dennyum204/HomeOfficeReservation/issues/2) permanece aberta; [PR #27](https://github.com/Dennyum204/HomeOfficeReservation/pull/27) permanece draft até cumprir os critérios. Estudo/probe preparados; ensaio Microsoft real não executado.
- Fernando confirmou **Outlook.com pessoal (MSA)**. O endereço indicado permanece privado; informou que nada estava preparado. Registo de teste, configuração, consentimento e confirmação de mailbox dedicada continuam em falta. O diretório que aloja o registo da aplicação é distinto do tenant consumer da mailbox.
- [Estudo HO-001](docs/HO-001-MICROSOFT-OUTLOOK-STUDY.md) e [ADR-002](docs/adr/ADR-002-outlook.md) documentam login BFF, Flutter AppAuth/PKCE com token da API, conector de consentimento separado, cache Graph apenas no backend e desenho de delta/subscrições/recuperação. ADR continua proposto; preserva a hipótese empresarial anterior como histórico.
- [Probe isolado](scripts/outlook_probe/README.md) preparado com MSAL Python, configuração sintética, binding explícito da conta, eventos próprios e limpeza recuperável. **19 testes passaram com Graph simulado**. Plano offline confirmou seis fixtures e dias DST de 23/25 horas em Lisboa/Zurique; zero chamadas Microsoft. `pip check` e validador documental passam; CI do PR deve verificar `project-docs` e `outlook-probe-tests` no último SHA.
- Nenhuma autenticação Microsoft, chamada Graph real, evento real, subscrição ou webhook executado. Login de produção Web/Flutter, armazenamento durável de tokens e infraestrutura não foram implementados. Suporte real a ETag/412, aliases de timezone, delta/paginação, recorrência e revogação/reconexão permanece sem evidência.
- Repositório [público](https://github.com/Dennyum204/HomeOfficeReservation), stack preservada: .NET 10/ASP.NET Core, PostgreSQL/EF Core, React/TypeScript, Flutter Android/iOS; Outlook obrigatório na V1. HO-002 não iniciado. Não existem projetos compiláveis, migrações ou ambiente PostgreSQL.
- Tracking existente preservado: [24 issues](https://github.com/Dennyum204/HomeOfficeReservation/issues), [labels](https://github.com/Dennyum204/HomeOfficeReservation/labels) e [quatro milestones](https://github.com/Dennyum204/HomeOfficeReservation/milestones), com URLs reais no backlog. GitHub CLI autenticado e acesso Git/API operacional.
- Proteções documentadas de main preservadas: PR obrigatório, check estrito `project-docs`, conversas resolvidas, histórico linear, enforcement para admins e zero aprovações independentes obrigatórias. Force-push/deletion proibidos; apenas squash; auto-merge desativado. [Detalhes](docs/DEVELOPMENT.md).

## Próxima ação — continuar HO-001

Fernando prepara acesso a registo Entra para MSA, client ID e mailbox dedicada; confirma consentimento e execução do ensaio. Seguir o [guia](scripts/outlook_probe/README.md), guardar configuração privada fora do Git e executar binding/CRUD/delta/limpeza apenas após essa confirmação. Não enviar tokens, passwords, endereços ou conteúdo do calendário para GitHub.

Depois, completar a matriz de evidência de HO-001, validar fluxos reais/limitações, atualizar ADR/issue e só retirar draft se todos os critérios estiverem satisfeitos, CI verde no último SHA e sem conflitos. **Não iniciar HO-002 nem outro trabalho.** Fernando revê e faz merge; o Codex não integra PRs nem ativa auto-merge.

## Decisões e pressupostos pendentes

| Tema | Estado | Quem resolve / quando |
|---|---|---|
| Outlook | MSA/Outlook.com pessoal confirmado; ensaio real pendente | Fernando, continuação HO-001 |
| Registo de aplicações | Acesso ao diretório/portal e client IDs ainda não preparados | Fernando, continuação HO-001 |
| Segundo participante | Conta do gestor e admissão explícita por confirmar | Fernando, antes do piloto |
| Identidade empresarial futura | Requer nova validação IT/consentimento/broker; não autorizada pela conta pessoal | Se esse cenário surgir |
| Mobile | Android/iOS confirmados; assinatura/distribuição privada por decidir | Fernando, HO-002/HO-012 |
| Localização inicial | Dias úteis presumidos presenciais com etiqueta de padrão base | Fernando e chefe, HO-003 |
| Idioma | PT-PT inicialmente; estrutura para outros idiomas | Fernando, HO-005 |
| Alojamento | Linux/PostgreSQL, fornecedor/região/domínio por decidir | Fernando, HO-012 |

## Regra de continuidade

Cada PR atualiza o estado real. Verificar merge e CI antes de reconciliar backlog e avaliar dependências; regenerar ROADMAP.md e docs/BACKLOG.md. `done` exige integração verificada; entrega parcial mantém `blocked` com motivo e PR draft. Não guardar segredos nem detalhes privados Outlook no tracking público.
