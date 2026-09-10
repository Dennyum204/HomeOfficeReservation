# Backlog de execução

Gerado de [backlog.json](backlog.json). Não editar diretamente.

Os IDs HO não são números de issues/PRs. URLs remotos só são preenchidos após criação real.

Cada linha é um pacote de trabalho delimitado. Pode ser dividido em novos IDs/PRs antes de implementar, mantendo dependências e critérios; não implica um PR gigante por pacote.

| ID | Tarefa | Release | Área | Estado | Depende de |
|---|---|---|---|---|---|
| HO-000 | Repositório, documentação e tracking GitHub | v1.0 | docs | Concluído | — |
| HO-001 | Core autónomo, autenticação própria e Outlook opcional | v1.0 | docs | Concluído | HO-000 |
| HO-002 | Monorepo compilável, contratos e CI | v1.0 | foundation | Concluído | HO-000, HO-001 |
| HO-003 | Autenticação, membros e autorização | v1.0 | backend | Concluído | HO-002 |
| HO-004 | Planeamento e aprovação transacional na API | v1.0 | backend | Concluído | HO-003 |
| HO-005 | Calendário Web e fluxos de pedido/decisão | v1.0 | web | Concluído | HO-004 |
| HO-006 | Presenças, resolução de conflitos e tarefas | v1.0 | fullstack | Concluído | HO-004, HO-005 |
| HO-007 | Notificações duráveis e infraestrutura push | v1.0 | fullstack | Concluído | HO-004, HO-005, HO-006 |
| HO-008 | Outlook opcional: publicar dias confirmados | outlook-publish | integration | Planeado | HO-012 |
| HO-009 | Importação Outlook, webhooks e divergências | outlook-sync | integration | Planeado | HO-008 |
| HO-010 | Android: calendário e pedidos para ambos os papéis | v1.0 | mobile | Concluído | HO-004, HO-005, HO-007 |
| HO-011 | Integração das interfaces e testes de aceitação | v1.0 | fullstack | Em curso | HO-005, HO-006, HO-007, HO-010 |
| HO-012 | Staging, distribuição privada e piloto V1 | v1.0 | operations | Planeado | HO-011 |
| HO-101 | Lembretes e resumo semanal por email | v1.1 | fullstack | Planeado | HO-012 |
| HO-102 | Exportação e resumos mensais | v1.1 | fullstack | Planeado | HO-012 |
| HO-103 | Preferências de notificação e idiomas | v1.1 | fullstack | Planeado | HO-012 |
| HO-201 | Pedidos recorrentes | v1.2 | fullstack | Planeado | HO-101, HO-102, HO-103 |
| HO-202 | Meios dias, horários e deslocações | v1.2 | fullstack | Planeado | HO-101, HO-102, HO-103 |
| HO-203 | Viagens reservadas e planeamento flexível | v1.2 | fullstack | Planeado | HO-101, HO-102, HO-103 |
| HO-301 | Equipa maior e substituição de aprovador | v2.0 | fullstack | Planeado | HO-201, HO-202, HO-203 |
| HO-302 | Calendários Outlook adicionais e partilhados | v2.0 | integration | Planeado | HO-201, HO-202, HO-203, HO-009 |
| HO-303 | Google Calendar | v2.0 | integration | Planeado | HO-201, HO-202, HO-203 |
| HO-304 | Anexos e tarefas avançadas | v2.0 | fullstack | Planeado | HO-201, HO-202, HO-203 |
| HO-305 | Funcionamento offline | v2.0 | mobile | Planeado | HO-201, HO-202, HO-203 |
| HO-306 | Reativação futura de iOS | ios-reactivation | mobile | Em espera | HO-012 |

## HO-000 — Repositório, documentação e tracking GitHub

Release: v1.0 · Área: docs · Estado: Concluído

Responsável pelo trabalho: Fernando + Codex.

Dependências: Nenhuma.

Funcionalidades: Preparação/fundação da release.

Critérios de aceitação:

- Starter integrado na raiz a partir da história real; commit bootstrap vazio apenas se o GitHub não tiver commits; branch docs/ho-000-project-foundation.
- README e .gitignore descrevem o setup real e protegem outputs, configuração local, segredos e chaves sem excluir lockfiles, migrações ou exemplos seguros.
- Stack .NET 10/PostgreSQL/EF Core/React/Flutter confirmada. Histórico HO-000 exigia Outlook V1; requisito substituído pela decisão de core autónomo em HO-001/ADR-004, sem alterar a evidência do merge original.
- Os 24 trabalhos, incluindo releases futuras, têm issues reais sem duplicados, critérios de aceitação, dependências, labels de release/área e milestones onde suportados; URLs no JSON.
- AGENTS.md atribui branches, commits, issues e preparação de PRs ao Codex; exige evidência de merge e reconciliação de estados antes de verificar dependências; Fernando revê e faz merge, sem auto-merge.
- Validação documental passa e documentos derivados estão atualizados; PR real registado, sem draft, CI relevante verde no último commit e sem conflitos.
- Proteções documentadas da main configuradas e verificadas onde permitido, com nomes reais de checks e sem aprovação independente obrigatória para mantenedor único.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/1

PR: https://github.com/Dennyum204/HomeOfficeReservation/pull/25

## HO-001 — Core autónomo, autenticação própria e Outlook opcional

Release: v1.0 · Área: docs · Estado: Concluído

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-000

Funcionalidades: FEAT-001

Critérios de aceitação:

- Produto define calendário próprio autoritativo e todos os fluxos core Web/Mobile sem conta Microsoft ou ligação Outlook.
- Autenticação própria ASP.NET Core Identity definida para React/Flutter, com sessões, recuperação, autorização e limitações; sem protocolos criptográficos próprios.
- Outlook opcional em Definições publica apenas dias explícitos confirmados, showAs=free, eventos próprios e sem convites; importação/delta/webhooks/reconciliação em marco posterior.
- Estudo/probe preservados como referência opcional; onboarding suspenso e validação Graph real adiada, nunca apresentada como aprovada. Sem credenciais/Graph nos checks normais.
- ADRs com histórico, README/STATUS/produto/arquitetura e backlog/issues/milestones alinhados; dependências core sem gates Microsoft.
- Documentos derivados regenerados, checks relevantes verdes no último commit e PR #27 sem conflitos, pronto para revisão do âmbito documental revisto.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/2

PR: https://github.com/Dennyum204/HomeOfficeReservation/pull/27

## HO-002 — Monorepo compilável, contratos e CI

Release: v1.0 · Área: foundation · Estado: Concluído

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-000, HO-001

Funcionalidades: Preparação/fundação da release.

Critérios de aceitação:

- Projetos .NET, React e Flutter compilam com versões/lockfiles fixados.
- Ambiente PostgreSQL local e configuração de exemplo sem segredos disponíveis.
- OpenAPI e geração TypeScript/Dart reproduzíveis com verificação de diff.
- CI de cada stack executa checks reais; não aceita código existente com jobs silenciosamente ignorados.
- Comandos de setup/build/test estão documentados nas áreas correspondentes.
- Setup e CI do core funcionam sem conta Microsoft, tenant, tokens Graph ou probe; decisões de ADR-004 orientam scaffold, autenticação funcional fica em HO-003.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/3

PR: https://github.com/Dennyum204/HomeOfficeReservation/pull/28

## HO-003 — Autenticação, membros e autorização

Release: v1.0 · Área: backend · Estado: Concluído

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-002

Funcionalidades: FEAT-001, FEAT-009

Critérios de aceitação:

- ASP.NET Core Identity/EF Core/PostgreSQL com email/password: Web usa cookie Secure/HttpOnly e CSRF; Flutter usa bearer/refresh opacos do framework, conforme ADR-004.
- Colaborador/chefe pertencem a uma relação configurada; autoaprovação é negada.
- Reads/writes por ID verificam organização, papel e relação, incluindo casos de negação.
- Bootstrap de admin não permite atribuição livre de papéis pelo utilizador.
- Login válido e sessão expirada demonstrados nas duas interfaces base.
- Ativação/recuperação usam mecanismos Identity, rate limits e lockout; não há autoatribuição de papéis nem exigência de email Microsoft.
- Sessão/refresh expirados, logout, conta desativada, security stamp e armazenamento seguro mobile têm testes; nenhuma dependência de Entra/Graph.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/4

PR: https://github.com/Dennyum204/HomeOfficeReservation/pull/29

## HO-004 — Planeamento e aprovação transacional na API

Release: v1.0 · Área: backend · Estado: Concluído

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-003

Funcionalidades: FEAT-003, FEAT-004, FEAT-009, FEAT-010

Critérios de aceitação:

- Rascunhos, submissão, retirada e decisões por subconjunto de dias funcionam.
- Revisões/contrapropostas preservam datas já aprovadas até decisão final.
- PlanDay distingue localização, disponibilidade, origem e versão.
- Concorrência por colaborador e idempotência verificadas com PostgreSQL.
- Auditoria e outbox gravadas na mesma transação; comentários têm contexto e autor.
- Padrão semanal por vigência, DateOnly/date, calendário limitado e propostas separadas; sem materializar dias inferidos.
- Versões esperadas e idempotência durável por ator/operação, com rollback integral e testes por ligações PostgreSQL distintas.
- Demonstração local repetível com contas sintéticas privadas; sem UI de calendário, entrega de notificações, presenças ou Outlook.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/5

PR: https://github.com/Dennyum204/HomeOfficeReservation/pull/30

## HO-005 — Calendário Web e fluxos de pedido/decisão

Release: v1.0 · Área: web · Estado: Concluído

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-004

Funcionalidades: FEAT-002, FEAT-003, FEAT-004, FEAT-010

Critérios de aceitação:

- Calendário Web mês/semana ligado à API, navegação/Hoje/seleção, detalhe do dia, legenda acessível e resumos reais com período/unidade; plano efetivo separado de pendentes e padrão inferido.
- Colaborador cria/edita/submete rascunhos por datas/intervalo pré-visualizado, filtra/lista pedidos, retira apenas pendentes, propõe revisões/cancelamentos e disponibilidade manual, aceita contrapropostas exatas.
- Gestor seleciona apenas colaboradores autorizados, decide subconjuntos com revisão de motivo/datas, cria/revê contrapropostas e consulta comentários/histórico; sem poderes implícitos de administração.
- Clientes gerados, Identity/CSRF, datas date-only, tratamento de falhas, texto preservado, revisão humana após versão antiga, recuperação persistente do mesmo comando incerto, bloqueio de duplicados e isolamento entre contas/respostas atrasadas.
- E2E browser/API/PostgreSQL: cinco submetidos, três aprovados/dois pendentes nas duas contas, retirada dos dois preserva três, revisão mantém aprovado até decisão; conflitos manuais, stale, duplicado, autorização, teclado e largura estreita.
- Capturas reais sintéticas, documentação/contratos/backend/Web/Flutter-Dart/Android verdes; Android calendário permanece HO-010 e nenhuma funcionalidade futura fictícia.
- Web/Android são alvos atuais; iOS fonte/histórico preservados, sem CI automático ou check obrigatório; apenas check iOS removido e restantes proteções verificadas. Reativação futura HO-306, sem data.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/6

PR: https://github.com/Dennyum204/HomeOfficeReservation/pull/32

## HO-006 — Presenças, resolução de conflitos e tarefas

Release: v1.0 · Área: fullstack · Estado: Concluído

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-004, HO-005

Funcionalidades: FEAT-005, FEAT-006

Critérios de aceitação:

- Chefe cria presença com motivo, máquina/projeto e datas; colaborador confirma leitura da revisão.
- Sobreposição com remoto aprovado gera NeedsResolution e preserva aprovação.
- Resolução explícita atualiza presenças/plano atomicamente; corrida concorrente tem teste.
- Tarefas têm responsável, prazo, estado e RequiresOnsite sem impor presença automaticamente.
- API e Web expõem fluxo completo; contrato permite a implementação mobile.
- Presenças editáveis/canceláveis com histórico e leitura por revisão; revalidar disponibilidade manual, pedidos pendentes e outras presenças sem sobrescrita silenciosa.
- PlanningProfile/CalendarVersion, idempotência e auditoria/outbox transacionais partilhados; proteção também nos endpoints de revisão/decisão existentes.
- Tarefas com campos protegidos, progresso limitado ao colaborador, ligação autorizada e histórico preservado após edição/cancelamento da presença.
- Web com listas/filtros/formulários/detalhes, preview do servidor, criação pelo calendário, leitura distinta de acordo, resolução explícita e recuperação de erros/versões/resultados incertos.
- Migração aditiva, contratos TypeScript/Dart regenerados, PostgreSQL concorrência/rollback e E2E Web/API reais desktop/estreito com capturas; Android autenticação preservada, iOS/Outlook/entregas excluídos.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/7

PR: https://github.com/Dennyum204/HomeOfficeReservation/pull/33

## HO-007 — Notificações duráveis e infraestrutura push

Release: v1.0 · Área: fullstack · Estado: Concluído

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-004, HO-005, HO-006

Funcionalidades: FEAT-007

Critérios de aceitação:

- Submissão/revisão, decisões, retirada, contrapropostas, presenças criadas/alteradas/canceladas e tarefas atribuídas/alteradas notificam destinatários resolvidos pelo servidor, sem alertar o ator.
- Worker PostgreSQL com claims/leases, recuperação após crash, concorrência, lotes/tentativas limitados e falhas permanentes observáveis; inbox e intenções push deduplicadas e atomicamente persistidas com a outbox.
- Migração aditiva preserva dados/outbox; histórico é arquivado sem push em massa, e contextos removidos ou acesso revogado são tratados explicitamente.
- API paginada, contagem de não lidas, leitura e dispositivos autorizados por conta/organização/relação atual; ler não aprova, aceita ou reconhece negócios.
- Web dispõe de caixa, filtros, badge, leitura e links atuais para pedidos/presenças/tarefas; polling limitado, pausa ao ocultar, sessão/erro/loading, PT-PT e ecrã estreito.
- Android usa o mesmo contrato e sessão para caixa real; permissão explícita, registo/rotação/remoção/logout/troca de conta seguros, links validados e fallback honesto até HO-010/011.
- FCM real implementado com bibliotecas mantidas, configuração privada separada, texto mínimo e abertura foreground/background/cold start; validar entrega num dispositivo autorizado e registar evidência sanitizada, distinta de aceitação do fornecedor e simulação.
- Core/CI sem credenciais push; adaptador local explicitamente simulado; falha externa não perde notificações internas.
- Testes PostgreSQL/worker, Web/API/PostgreSQL E2E e caixa Android/API reais; quatro checks verdes, sem gates iOS; operações e recuperação documentadas.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/8

PR: https://github.com/Dennyum204/HomeOfficeReservation/pull/34

## HO-008 — Outlook opcional: publicar dias confirmados

Release: outlook-publish · Área: integration · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-012

Funcionalidades: FEAT-023

Critérios de aceitação:

- Ligação opcional em Definições, desligada por defeito, com consentimento delegado associado ao MemberId local; login e calendário core funcionam sem Microsoft.
- Tokens Graph só no backend; um registo conector não substitui autenticação da aplicação. Conta Outlook inicial pessoal; outros tipos exigem estudo próprio.
- Publicação unidirecional só de dias explícitos confirmados, all-day local, showAs=free por defeito, sem attendees/convites; pendentes/padrão base não geram eventos.
- CRUD real autorizado e limpeza de eventos próprios, DST Lisboa/Zurique, idempotência/timeout e precondições de escrita verificados; limitações e evidência sanitizada registadas.
- Atualização/remoção exige mapeamento/propriedade na conta ligada; erro ou edição concorrente não altera plano nem causa escrita cega. Sem importação de disponibilidade, delta, webhook ou reconciliação de alterações externas.
- Outbox/worker publica versões atuais; desligar/revogar para apenas a publicação e preserva core. Estado de publicação e erros apresentados sem tokens; eventos existentes ficam por defeito.
- Web e mobile permitem ligar/desligar e consultar publicação sem transferir tokens Graph aos clientes; ligação explícita impede troca de conta/cross-member.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/9

PR: ainda não criado.

Motivo: Adiado por decisão de produto para marco opcional após core. Estudo HO-001 não validou Graph real.

## HO-009 — Importação Outlook, webhooks e divergências

Release: outlook-sync · Área: integration · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-008

Funcionalidades: FEAT-008

Critérios de aceitação:

- Delta percorre páginas e guarda cursor por janela fixa; cursor inválido recupera.
- Webhooks são validados, enfileirados e reconciliados; subscrições renovam antes de expirar.
- Reconciliação periódica recupera notificações perdidas e respeita throttling.
- Eventos privados são reduzidos a disponibilidade; próprios eventos não geram falsos conflitos.
- Edição/apagamento externo gera divergência resolúvel, sem mudar aprovação.
- Revogação e desligar suspendem sync e limpam credenciais/intervalos conforme a política.
- Retomar ensaio real de delta/all-day/recorrência/paginação/revogação, provisionar HTTPS/fila/subscrições e rever estudo histórico; não tornar o conector requisito do core.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/10

PR: ainda não criado.

Motivo: Adiado para marco posterior à publicação opcional. Critérios de delta/webhooks/edição externa preservados; nenhum resultado real alegado.

## HO-010 — Android: calendário e pedidos para ambos os papéis

Release: v1.0 · Área: mobile · Estado: Concluído

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-004, HO-005, HO-007

Funcionalidades: FEAT-002, FEAT-003, FEAT-004, FEAT-010

Critérios de aceitação:

- Calendário mensal compacto e agenda distinguem padrão, localização confirmada, pedidos pendentes, disponibilidade manual e presenças/conflitos, com legenda, seleção, Hoje e atualização.
- Colaborador seleciona dias/intervalo inclusivo, revê datas, guarda/edita/submete rascunhos e consulta filtros/páginas/detalhes; retirada de pendentes mantém aprovações.
- Colaborador propõe alterações/cancelamentos/indisponibilidade e aceita contrapropostas; o plano aprovado mantém-se até resolução final pela API.
- Chefia vê apenas colaboradores atribuídos, decide um subconjunto com resumo explícito, contrapropõe e decide revisões aceites; comentários e histórico no contexto.
- Cliente Dart gerado e autenticação existente; loading/rede/sessão/acesso/versões tratados sem perder input nem confirmar escritas antes da API. Datas mantêm-se em Lisboa/Zurique e DST.
- Resultado incerto recupera chave/payload exatos; intenção alterada tem chave nova. Input e recovery protegidos por conta; logout/troca de conta eliminam dados privados e respostas antigas não os restauram.
- Notificações de pedidos/decisões abrem detalhe atual autorizado, preservando intenção na restauração de sessão e FCM existente; presenças/tarefas conservam fallback HO-011.
- UI PT-PT externalizada, toque/back/teclado/ecrã pequeno/texto ampliado; capturas reais do emulador com dados sintéticos.
- Testes Flutter e Android/API/PostgreSQL reais: cinco dias submetidos, três aprovados, dois pendentes retirados sem perder aprovações; revisões, contrapropostas, recuperação e isolamento. Fluxo Web→Android converge; navegação por inbox e push real quando viável.
- Quatro checks obrigatórios verdes no último commit e sem conflitos. Sem iOS/Outlook/fila offline/deployment/HO-011; dados e configuração privados preservados.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/11

PR: https://github.com/Dennyum204/HomeOfficeReservation/pull/35

## HO-011 — Integração das interfaces e testes de aceitação

Release: v1.0 · Área: fullstack · Estado: Em curso

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-005, HO-006, HO-007, HO-010

Funcionalidades: FEAT-005, FEAT-006, FEAT-007, FEAT-009

Critérios de aceitação:

- Web e Android completam calendário, presenças, tarefas e notificações para colaborador/chefia com contas locais, sem Microsoft; iOS/HO-306 permanece adiado.
- Android permite lista/filtros/detalhe/histórico, preview/criação/edição/cancelamento de presença pela chefia e leitura da revisão pelo colaborador; remoto aprovado mantém-se até proposta/aceitação/decisão explícitas.
- Tarefas Android permitem atribuição/edição autorizada e progresso limitado, prazo/RequiresOnsite/comentários/histórico/ligação atual; mudar a presença ligada não altera tarefa nem aprova dias.
- Notificações de pedidos/presenças/tarefas abrem detalhe autorizado sem ação de negócio; push real foreground/background/cold start, sessão expirada, duplicados, recurso indisponível e conta alterada têm evidência; recusa mantém caixa.
- Conta autenticada e colaborador selecionado, pedido próprio e exigência da chefia são claros em PT-PT; Web estreita/desktop e Android suportam foco/teclado/voltar/scroll/erros e texto escalável, sem IDs técnicos como rótulos.
- Clientes gerados, input protegido por conta, replay de chave/corpo originais e revisão explícita após versões stale; sem escritas offline ou respostas atrasadas a repor estado de outra conta.
- Matriz real Web/Android/API/PG: cinco dias pedidos Web, três aprovados Android, dois retirados Android; revisão preservada; presença lida sem mudar plano; resolução atómica; tarefa/progresso cruzados e destino correto de notificações.
- Evidência distingue testes simulados, PG/browser/emulador e FCM real; reutiliza testes adequados de autorização/concorrência/retries/sessão/Lisboa/Zurique/DST; capturas sintéticas e quatro checks verdes no commit final.
- Guias/STATUS/backlog/issue/PR alinhados; app normal restaurada e serviços locais preservados quando possível. Sem merge, auto-merge, deployment ou início HO-012.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/12

PR: ainda não criado.

## HO-012 — Staging, distribuição privada e piloto V1

Release: v1.0 · Área: operations · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-011

Funcionalidades: Preparação/fundação da release.

Critérios de aceitação:

- Alojamento/região, domínio, retenção e plataformas de piloto definidos pelo responsável.
- Staging/produção isolados; segredos externos; migração e restauro demonstrados.
- Worker de notificações ativo, filas/falhas observáveis e chaves Data Protection persistidas/protegidas; webhook Graph e consentimento Microsoft não são requisitos de alojamento core.
- Apps disponibilizadas nos alvos acordados com assinatura/distribuição válidas.
- Duas contas locais autorizadas concluem os critérios core sem ligação Microsoft; release/tag v1.0 só após aceitação. Publicação e importação Outlook têm milestones próprios.
- Alvos atuais Web/Android; iOS adiado para HO-306, sem requisito de implementação, CI, distribuição ou data nesta entrega.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/13

PR: ainda não criado.

## HO-101 — Lembretes e resumo semanal por email

Release: v1.1 · Área: fullstack · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-012

Funcionalidades: FEAT-011

Critérios de aceitação:

- Pedidos pendentes têm lembrete configurável sem spam.
- Resumo semanal inclui datas confirmadas, pendentes e presenças.
- Email respeita destinatário, idioma/zona e preferências.
- Entregas têm deduplicação e não expõem conteúdo privado Outlook.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/14

PR: ainda não criado.

## HO-102 — Exportação e resumos mensais

Release: v1.1 · Área: fullstack · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-012

Funcionalidades: FEAT-012

Critérios de aceitação:

- Exportação mensal legível separa aprovados, pendentes, presença e indisponibilidade.
- Totais seguem as mesmas regras do calendário e distinguem padrão base de confirmação.
- Acesso ao relatório segue a relação de gestão; não inclui detalhes privados de calendário.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/15

PR: ainda não criado.

## HO-103 — Preferências de notificação e idiomas

Release: v1.1 · Área: fullstack · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-012

Funcionalidades: FEAT-013

Critérios de aceitação:

- Preferências por canal/tipo e períodos silenciosos guardadas por utilizador.
- Textos PT-PT, EN e DE cobrem fluxos essenciais sem strings misturadas.
- Formato de datas/zona é consistente nas duas interfaces e notificações.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/16

PR: ainda não criado.

## HO-201 — Pedidos recorrentes

Release: v1.2 · Área: fullstack · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-101, HO-102, HO-103

Funcionalidades: FEAT-014

Critérios de aceitação:

- Padrão semanal gera proposta com pré-visualização e horizonte limitado.
- Exceções e conflitos são visíveis antes de submeter.
- Alterar uma ocorrência não muda retroativamente todas as aprovações da série.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/17

PR: ainda não criado.

## HO-202 — Meios dias, horários e deslocações

Release: v1.2 · Área: fullstack · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-101, HO-102, HO-103

Funcionalidades: FEAT-015

Critérios de aceitação:

- Modelo de intervalos suporta meios dias e deslocações sem sobrepor disponibilidade incompatível.
- Aprovação e conflitos aplicam-se ao intervalo correto.
- Contratos e calendário próprio evoluem com migração e testes de zonas/horário de verão. Se o conector opcional estiver instalado, atualizar a projeção sem torná-lo dependência deste item.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/18

PR: ainda não criado.

## HO-203 — Viagens reservadas e planeamento flexível

Release: v1.2 · Área: fullstack · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-101, HO-102, HO-103

Funcionalidades: FEAT-016, FEAT-017

Critérios de aceitação:

- Período pode indicar viagem reservada com comentário, sem guardar documentos pessoais por defeito.
- Plano provisório de vários meses é claramente distinto de pedido/aprovação.
- Datas fixas/flexíveis e alternativas são apresentadas ao chefe antes de propor mudanças.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/19

PR: ainda não criado.

## HO-301 — Equipa maior e substituição de aprovador

Release: v2.0 · Área: fullstack · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-201, HO-202, HO-203

Funcionalidades: FEAT-018

Critérios de aceitação:

- Administração de colaboradores e relações mantém isolamento entre equipas.
- Substituto tem vigência definida e poderes limitados, com auditoria.
- Pedidos em curso têm encaminhamento explícito quando o aprovador está indisponível.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/20

PR: ainda não criado.

## HO-302 — Calendários Outlook adicionais e partilhados

Release: v2.0 · Área: integration · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-201, HO-202, HO-203, HO-009

Funcionalidades: FEAT-019

Critérios de aceitação:

- Estudo específico valida permissões/endpoints para calendários secundários e partilhados.
- Seleção por calendário identifica leitura/escrita e propriedade dos eventos.
- Cursores, notificações e regras de conflito não reutilizam indevidamente o fluxo do calendário principal.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/21

PR: ainda não criado.

## HO-303 — Google Calendar

Release: v2.0 · Área: integration · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-201, HO-202, HO-203

Funcionalidades: FEAT-020

Critérios de aceitação:

- Adaptador Google preserva o contrato de autoridade e privacidade do produto.
- Consentimento, retries, recuperação e calendários de teste têm validação própria.
- O utilizador distingue claramente provedores e não cria loops entre calendários.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/22

PR: ainda não criado.

## HO-304 — Anexos e tarefas avançadas

Release: v2.0 · Área: fullstack · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-201, HO-202, HO-203

Funcionalidades: FEAT-021

Critérios de aceitação:

- Necessidades de anexos/dependências são confirmadas com feedback real.
- Ficheiros têm limites, autorização e ciclo de vida próprios.
- Relatórios/tarefas adicionais não alteram automaticamente presença ou aprovações.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/23

PR: ainda não criado.

## HO-305 — Funcionamento offline

Release: v2.0 · Área: mobile · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-201, HO-202, HO-203

Funcionalidades: FEAT-022

Critérios de aceitação:

- Consulta offline identifica atualidade do cache e protege dados locais.
- Escritas pendentes têm fila e estado explícitos; só o servidor confirma decisões.
- Reconexão resolve versões/conflitos sem last-write-wins sobre aprovações.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/24

PR: ainda não criado.

## HO-306 — Reativação futura de iOS

Release: ios-reactivation · Área: mobile · Estado: Em espera

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-012

Funcionalidades: FEAT-024

Critérios de aceitação:

- Reativação selecionada explicitamente pelo responsável; rever SDK/Xcode, dependências e fonte iOS preservada antes de fixar novos alvos.
- Validar os fluxos Flutter para ambos os papéis no iOS com API/PostgreSQL, datas, autorização e armazenamento/sessões nativos; não inferir sucesso de Android.
- Definir e validar assinatura/distribuição/dispositivos quando autorizados; evidência histórica não substitui novos ensaios.
- Só repor CI/gates iOS com critérios acordados, jobs reais verdes e documentação coerente. Sem data de entrega e sem bloquear Web/Android.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/31

PR: ainda não criado.

Motivo: Adiado por decisão explícita em HO-005; sem data e sem gate core.
