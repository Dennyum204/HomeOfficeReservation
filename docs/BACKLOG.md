# Backlog de execução

Gerado de [backlog.json](backlog.json). Não editar diretamente.

Os IDs HO não são números de issues/PRs. URLs remotos só são preenchidos após criação real.

Cada linha é um pacote de trabalho delimitado. Pode ser dividido em novos IDs/PRs antes de implementar, mantendo dependências e critérios; não implica um PR gigante por pacote.

| ID | Tarefa | Release | Área | Estado | Depende de |
|---|---|---|---|---|---|
| HO-000 | Repositório, documentação e tracking GitHub | v1.0 | docs | Em curso | — |
| HO-001 | Estudo de identidade Microsoft e Outlook | v1.0 | integration | Planeado | HO-000 |
| HO-002 | Monorepo compilável, contratos e CI | v1.0 | foundation | Planeado | HO-000 |
| HO-003 | Autenticação, membros e autorização | v1.0 | backend | Planeado | HO-001, HO-002 |
| HO-004 | Planeamento e aprovação transacional na API | v1.0 | backend | Planeado | HO-003 |
| HO-005 | Calendário Web e fluxos de pedido/decisão | v1.0 | web | Planeado | HO-004 |
| HO-006 | Presenças, resolução de conflitos e tarefas | v1.0 | fullstack | Planeado | HO-004 |
| HO-007 | Notificações duráveis e infraestrutura push | v1.0 | backend | Planeado | HO-004 |
| HO-008 | Publicação de datas confirmadas no Outlook | v1.0 | integration | Planeado | HO-001, HO-004, HO-007 |
| HO-009 | Importação Outlook, webhooks e divergências | v1.0 | integration | Planeado | HO-008 |
| HO-010 | Mobile: calendário e pedidos para ambos os papéis | v1.0 | mobile | Planeado | HO-004 |
| HO-011 | Integração das interfaces e testes de aceitação | v1.0 | fullstack | Planeado | HO-005, HO-006, HO-007, HO-009, HO-010 |
| HO-012 | Staging, distribuição privada e piloto V1 | v1.0 | operations | Planeado | HO-011 |
| HO-101 | Lembretes e resumo semanal por email | v1.1 | fullstack | Planeado | HO-012 |
| HO-102 | Exportação e resumos mensais | v1.1 | fullstack | Planeado | HO-012 |
| HO-103 | Preferências de notificação e idiomas | v1.1 | fullstack | Planeado | HO-012 |
| HO-201 | Pedidos recorrentes | v1.2 | fullstack | Planeado | HO-101, HO-102, HO-103 |
| HO-202 | Meios dias, horários e deslocações | v1.2 | fullstack | Planeado | HO-101, HO-102, HO-103 |
| HO-203 | Viagens reservadas e planeamento flexível | v1.2 | fullstack | Planeado | HO-101, HO-102, HO-103 |
| HO-301 | Equipa maior e substituição de aprovador | v2.0 | fullstack | Planeado | HO-201, HO-202, HO-203 |
| HO-302 | Calendários Outlook adicionais e partilhados | v2.0 | integration | Planeado | HO-201, HO-202, HO-203 |
| HO-303 | Google Calendar | v2.0 | integration | Planeado | HO-201, HO-202, HO-203 |
| HO-304 | Anexos e tarefas avançadas | v2.0 | fullstack | Planeado | HO-201, HO-202, HO-203 |
| HO-305 | Funcionamento offline | v2.0 | mobile | Planeado | HO-201, HO-202, HO-203 |

## HO-000 — Repositório, documentação e tracking GitHub

Release: v1.0 · Área: docs · Estado: Em curso

Responsável pelo trabalho: Fernando + Codex.

Dependências: Nenhuma.

Funcionalidades: Preparação/fundação da release.

Critérios de aceitação:

- Starter integrado na raiz a partir da história real; commit bootstrap vazio apenas se o GitHub não tiver commits; branch docs/ho-000-project-foundation.
- README e .gitignore descrevem o setup real e protegem outputs, configuração local, segredos e chaves sem excluir lockfiles, migrações ou exemplos seguros.
- Documentos confirmam ASP.NET Core/.NET 10, PostgreSQL/EF Core, React/TypeScript e Flutter Android/iOS; Outlook obrigatório na V1; conta Microsoft e alojamento permanecem por validar.
- Os 24 trabalhos, incluindo releases futuras, têm issues reais sem duplicados, critérios de aceitação, dependências, labels de release/área e milestones onde suportados; URLs no JSON.
- AGENTS.md atribui branches, commits, issues e preparação de PRs ao Codex; exige evidência de merge e reconciliação de estados antes de verificar dependências; Fernando revê e faz merge, sem auto-merge.
- Validação documental passa e documentos derivados estão atualizados; PR real registado, sem draft, CI relevante verde no último commit e sem conflitos.
- Proteções documentadas da main configuradas e verificadas onde permitido, com nomes reais de checks e sem aprovação independente obrigatória para mantenedor único.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/1

PR: ainda não criado.

## HO-001 — Estudo de identidade Microsoft e Outlook

Release: v1.0 · Área: integration · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-000

Funcionalidades: FEAT-008, FEAT-001

Critérios de aceitação:

- Tipo de conta/mailbox e políticas de consentimento identificados sem guardar segredos.
- Login e fluxo de tokens API/Graph definidos, incluindo viabilidade Flutter.
- Evento de teste próprio criado, alterado e removido com as permissões previstas.
- Leitura delta, datas all-day e revogação/reconexão verificadas ou limitações explicitamente registadas.
- ADR-002 atualizado com evidência; não confundir testes simulados com Graph real.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/2

PR: ainda não criado.

## HO-002 — Monorepo compilável, contratos e CI

Release: v1.0 · Área: foundation · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-000

Funcionalidades: Preparação/fundação da release.

Critérios de aceitação:

- Projetos .NET, React e Flutter compilam com versões/lockfiles fixados.
- Ambiente PostgreSQL local e configuração de exemplo sem segredos disponíveis.
- OpenAPI e geração TypeScript/Dart reproduzíveis com verificação de diff.
- CI de cada stack executa checks reais; não aceita código existente com jobs silenciosamente ignorados.
- Comandos de setup/build/test estão documentados nas áreas correspondentes.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/3

PR: ainda não criado.

## HO-003 — Autenticação, membros e autorização

Release: v1.0 · Área: backend · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-001, HO-002

Funcionalidades: FEAT-001, FEAT-009

Critérios de aceitação:

- Web usa sessão BFF com proteção CSRF; mobile obtém token destinado à API.
- Colaborador/chefe pertencem a uma relação configurada; autoaprovação é negada.
- Reads/writes por ID verificam organização, papel e relação, incluindo casos de negação.
- Bootstrap de admin não permite atribuição livre de papéis pelo utilizador.
- Login válido e sessão expirada demonstrados nas duas interfaces base.

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

## HO-008 — Publicação de datas confirmadas no Outlook

Release: v1.0 · Área: integration · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-001, HO-004, HO-007

Funcionalidades: FEAT-008

Critérios de aceitação:

- Ligação delegada ao calendário principal guarda tokens apenas no backend.
- Aprovação cria eventos só para as datas explícitas confirmadas; dias pendentes não são publicados.
- Revisão/cancelamento altera ou remove apenas eventos com mapeamento válido.
- Retry/timeout, ordenação de versões e data all-day não duplicam nem deslocam eventos.
- API expõe estado de ligação/publicação, sem expor tokens.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/9

PR: ainda não criado.

## HO-009 — Importação Outlook, webhooks e divergências

Release: v1.0 · Área: integration · Estado: Planeado

Responsável pelo trabalho: Fernando + Codex.

Dependências: HO-008

Funcionalidades: FEAT-008, FEAT-009

Critérios de aceitação:

- Delta percorre páginas e guarda cursor por janela fixa; cursor inválido recupera.
- Webhooks são validados, enfileirados e reconciliados; subscrições renovam antes de expirar.
- Reconciliação periódica recupera notificações perdidas e respeita throttling.
- Eventos privados são reduzidos a disponibilidade; próprios eventos não geram falsos conflitos.
- Edição/apagamento externo gera divergência resolúvel, sem mudar aprovação.
- Revogação e desligar suspendem sync e limpam credenciais/intervalos conforme a política.

Issue: https://github.com/Dennyum204/HomeOfficeReservation/issues/10

PR: ainda não criado.

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

Dependências: HO-005, HO-006, HO-007, HO-009, HO-010

Funcionalidades: FEAT-005, FEAT-006, FEAT-007, FEAT-008, FEAT-009

Critérios de aceitação:

- Web e mobile completam presença, conflito, tarefa, notificações e gestão Outlook.
- Push real abre o detalhe autenticado; permissão recusada mantém caixa interna.
- Cenário cruzado: pedido Web, decisão mobile e evento Outlook correto.
- Autorização negativa, concorrência, DST, retries e divergências têm evidência.
- Capturas/execuções de interfaces e builds demonstram o comportamento, não apenas mocks.

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
- Worker sempre ativo, webhooks públicos e falhas de sync observáveis.
- Apps disponibilizadas nos alvos acordados com assinatura/distribuição válidas.
- Duas contas autorizadas concluem os critérios de lançamento; release/tag v1.0 só após aceitação.

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
- Contratos e projeção Outlook evoluem com migração e testes de zonas/horário de verão.

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

Dependências: HO-201, HO-202, HO-203

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
