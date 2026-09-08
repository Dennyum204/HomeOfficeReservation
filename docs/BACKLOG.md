# Backlog de execução

Gerado de [backlog.json](backlog.json). Não editar diretamente.

Os IDs HO não são números de issues/PRs. URLs remotos só são preenchidos após criação real.

Cada linha é um pacote de trabalho delimitado. Pode ser dividido em novos IDs/PRs antes de implementar, mantendo dependências e critérios; não implica um PR gigante por pacote.

| ID | Tarefa | Release | Área | Estado | Depende de |
|---|---|---|---|---|---|
| HO-000 | Repositório, documentação e tracking GitHub | v1.0 | docs | Concluído | — |
| HO-001 | Core autónomo, autenticação própria e Outlook opcional | v1.0 | docs | Concluído | HO-000 |
| HO-002 | Monorepo compilável, contratos e CI | v1.0 | foundation | Em curso | HO-000, HO-001 |
| HO-003 | Autenticação, membros e autorização | v1.0 | backend | Planeado | HO-002 |
| HO-004 | Planeamento e aprovação transacional na API | v1.0 | backend | Planeado | HO-003 |
| HO-005 | Calendário Web e fluxos de pedido/decisão | v1.0 | web | Planeado | HO-004 |
| HO-006 | Presenças, resolução de conflitos e tarefas | v1.0 | fullstack | Planeado | HO-004 |
| HO-007 | Notificações duráveis e infraestrutura push | v1.0 | backend | Planeado | HO-004 |
| HO-008 | Outlook opcional: publicar dias confirmados | outlook-publish | integration | Planeado | HO-012 |
| HO-009 | Importação Outlook, webhooks e divergências | outlook-sync | integration | Planeado | HO-008 |
| HO-010 | Mobile: calendário e pedidos para ambos os papéis | v1.0 | mobile | Planeado | HO-004 |
| HO-011 | Integração das interfaces e testes de aceitação | v1.0 | fullstack | Planeado | HO-005, HO-006, HO-007, HO-010 |
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

Release: v1.0 · Área: foundation · Estado: Em curso

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

Release: v1.0 · Área: backend · Estado: Planeado

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

PR: ainda não criado.

## HO-004 — Planeamento e aprovação transacional na API

Release: v1.0 · Área: backend · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-003

Funcionalidades: FEAT-003, FEAT-004, FEAT-009, FEAT-010

Critérios de aceitação:

- Rascunhos, submissão, retirada e decisões por subconjunto de dias funcionam.
- Revisões/contrapropostas preservam datas já aprovadas até decisão final.
- PlanDay distingue localização, disponibilidade, origem e versão.
- Concorrência por colaborador e idempotência verificadas com PostgreSQL.
- Auditoria e outbox gravadas na mesma transação; comentários têm contexto e autor.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/5

PR: ainda não criado.

## HO-005 — Calendário Web e fluxos de pedido/decisão

Release: v1.0 · Área: web · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-004

Funcionalidades: FEAT-002, FEAT-003, FEAT-004, FEAT-010

Critérios de aceitação:

- Calendário mês/semana e dashboard mostram padrão base, confirmado e pendente de forma distinta.
- Colaborador submete cinco dias e chefe aprova três através da Web.
- Estados loading/erro/versão antiga mantêm rascunhos e recuperam corretamente.
- Marcação manual de indisponibilidade não sobrescreve datas aprovadas.
- Fluxo principal funciona por teclado e em largura reduzida.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/6

PR: ainda não criado.

## HO-006 — Presenças, resolução de conflitos e tarefas

Release: v1.0 · Área: fullstack · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-004

Funcionalidades: FEAT-005, FEAT-006

Critérios de aceitação:

- Chefe cria presença com motivo, máquina/projeto e datas; colaborador confirma leitura da revisão.
- Sobreposição com remoto aprovado gera NeedsResolution e preserva aprovação.
- Resolução explícita atualiza presenças/plano atomicamente; corrida concorrente tem teste.
- Tarefas têm responsável, prazo, estado e RequiresOnsite sem impor presença automaticamente.
- API e Web expõem fluxo completo; contrato permite a implementação mobile.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/7

PR: ainda não criado.

## HO-007 — Notificações duráveis e infraestrutura push

Release: v1.0 · Área: backend · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-004

Funcionalidades: FEAT-007

Critérios de aceitação:

- Submissão, decisão, mudança, presença e atribuição geram notificação para o destinatário correto.
- Outbox e notificações internas deduplicam por evento/destinatário.
- Registo/rotação/remoção de dispositivos e estado lido são autorizados.
- Push contém resumo mínimo e deep link; não executa aprovações.
- Falha do fornecedor push não perde notificação interna; adaptador real escolhido e documentado.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/8

PR: ainda não criado.

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

## HO-010 — Mobile: calendário e pedidos para ambos os papéis

Release: v1.0 · Área: mobile · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-004

Funcionalidades: FEAT-002, FEAT-003, FEAT-004, FEAT-010

Critérios de aceitação:

- Android/iOS apresentam mês compacto, agenda e detalhe do pedido.
- Colaborador submete e chefe aprova parte dos dias no mobile.
- Dados vêm do cliente gerado e convergem com a Web/API.
- Sem rede ou com sessão expirada, a aplicação não apresenta escritas como confirmadas.
- UI tem estados de erro/pendente e mantém datas em Lisboa/Zurique.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/11

PR: ainda não criado.

## HO-011 — Integração das interfaces e testes de aceitação

Release: v1.0 · Área: fullstack · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-005, HO-006, HO-007, HO-010

Funcionalidades: FEAT-005, FEAT-006, FEAT-007, FEAT-009

Critérios de aceitação:

- Web e mobile completam calendário próprio, presença/motivo, conflito, tarefa e notificações para ambos os papéis com contas locais, sem Microsoft.
- Push real abre detalhe autenticado; permissão recusada mantém caixa interna.
- Cenário cruzado: pedido Web, decisão mobile e mesmos dias confirmados no calendário interno, sem conector configurado.
- Autorização negativa, concorrência, datas Lisboa/Zurique/DST, retries, recuperação de sessão e alterações de aprovação têm evidência.
- Capturas/execuções e builds demonstram comportamento real do core; Graph/probe não são gates de aceitação.

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
