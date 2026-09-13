# Roadmap

Gerado a partir de [docs/backlog.json](docs/backlog.json). Não editar diretamente.

Atualizado: 2026-09-13.

Core Web/Android integrado. HO-012: Pi instalado e HTTPS Cloudflare publicado; percurso titular → chefe → calendário/notificações aceite pelo responsável no browser do telemóvel em 2026-09-13. Aceitação parcial, PR #37 draft. Backup R2 cifrado/restauro novo e recuperação Bitwarden no PC verificados; timers diários 7/6 e leitura semanal ativos, disparos agendados/alertas externos pendentes. SMTP real, monitorização externa dos backups, Android físico/distribuição e aceitação final pendentes. NAS/Hetzner históricos; iOS/Outlook adiados. Monitorização Healthchecks.io Hobbyist ativada em 2026-09-13, três checks gratuitos e destinatário aprovado guardado privadamente. Ensaio isolado real confirmou falha, ausência de sinal e duas recuperações; responsável confirmou quatro emails recebidos. Rehearsal pausado ignorando pings. Hooks instalados no Pi; backup e leitura integral iniciais MANUAIS terminaram com success reconhecido (cerca de 81 s e 75 s). Timers ativos; LastTrigger 16:25:13 UTC não correlacionado com operação concluída, não prova execução agendada. Próximos prazos locais 14/09 03:23:13 UTC e 20/09 06:09:36 UTC. Ciclos realmente agendados permanecem por comprovar. docs/HO-012-BACKUP-MONITORING.md. SMTP real preparado para revisão: Brevo Free proposto, remetente no-reply@notificacoes.ferbatech.com, manifesto DNS dependente dos valores reais do fornecedor. Cinco DNS existentes consultados e preservados. Sem conta/credenciais/publicação/envio ou alteração no Pi/backups. docs/HO-012-SMTP.md. Brevo Free e remetente aprovados; sessão da conta confirmada e registos reais obtidos no fluxo manual em 2026-09-13. Manifesto guardado fora do Git para revisão; nenhum DNS publicado. Painel pede verificação de telefone antes de envio. SMTP key não criada/obtida; remetente ainda não confirmado. DMARC sugerido pelo fornecedor inclui rua para Brevo, sujeito a decisão distinta. Pi/backups/envios preservados. Publicação DNS autorizada em 2026-09-13: quatro registos adicionados, TTL Auto/DNS only, DMARC v=DMARC1; p=none; adkim=r; aspf=r sem rua/ruf. Releitura API confirmou nove registos e preservação exata dos cinco anteriores. DNS público devolve CNAME corretos. Brevo reconhece código, mas DKIM/DMARC ainda pendentes; autenticação não declarada concluída. Nenhum SMTP/envio/Pi/backup alterado. DMARC rua=mailto:rua@dmarc.brevo.com acrescentado por autorização explícita em 2026-09-13, preservando p=none/adkim=r/aspf=r. DNS público confirmado; Brevo reconheceu os quatro registos e apresentou Your domain has been authenticated. Autenticação DNS concluída, não equivale a envio SMTP. Sem alteração no Pi/backups ou mensagens da aplicação; chave SMTP e verificação de telefone continuam pendentes. Preparação SMTP concluída no fornecedor: verificação de telefone reportada pelo responsável e aviso removido; remetente HomeOffice <no-reply@notificacoes.ferbatech.com> Verified. Chave HomeOffice Pi SMTP criada pelo responsável, Active, expira em 2027-09-13 (também após 90 dias de inatividade segundo painel). Login/chave guardados apenas na pasta privada do PC com ACL restrita, transferência cifrada e releitura validada. Cópia Bitwarden ainda por confirmar. Sem aplicação ao Pi, autenticação SMTP ou envio de teste; estes continuam pendentes de autorização. Ensaio SMTP isolado autorizado em 2026-09-13: Python 3.13.5 no host Pi, STARTTLS com validação pública, autenticação Brevo e uma única mensagem sintética aceite pelo relay; destinatário autorizado e recibo mantidos privados. Exit 0 e recibo descarregado no PC. Receção inbox/spam e cabeçalhos DKIM/DMARC ainda por confirmar. Não valida MailKit nem rede do contentor: configuração da aplicação e backups/timers não alterados, nenhum convite/conta criado.

Cada funcionalidade tem uma release e pelo menos uma tarefa. Mudanças de âmbito/versão exigem um PR com motivo; ideias canceladas mantêm o ID e o histórico.

A sequência detalhada e os critérios estão em [docs/BACKLOG.md](docs/BACKLOG.md).

## v1.0 — Core V1 autónomo

**Quando:** Após implementação e aceitação do core; piloto de duas semanas, sem depender de Microsoft.

**Gate:** HO-000 a HO-007 e HO-010 a HO-015 integrados; acesso privado por convite, titular administrador/colaborador e chefe associado, duas contas autorizadas e gates core de QUALITY.md cumpridos. HO-008/HO-009/HO-016 não são gates. Alvos atuais Web/Android; iOS/HO-306 excluídos.

**Reavaliar:** Em cada entrega do core e na retrospetiva do piloto.

| ID | Funcionalidade | Tarefas |
|---|---|---|
| FEAT-001 | Contas próprias, papéis e relação colaborador/chefe | HO-001, HO-003, HO-013, HO-014, HO-015 |
| FEAT-002 | Calendário próprio autoritativo, dashboard e padrão base explícito | HO-005, HO-010 |
| FEAT-003 | Pedidos por datas, rascunhos e comentários | HO-004, HO-005, HO-010 |
| FEAT-004 | Aprovação parcial, contrapropostas e revisões | HO-004, HO-005, HO-010 |
| FEAT-005 | Compromissos presenciais, leitura e conflitos | HO-006, HO-011 |
| FEAT-006 | Tarefas simples associadas a projetos/presenças | HO-006, HO-011 |
| FEAT-007 | Notificações internas e push mobile | HO-007, HO-011 |
| FEAT-009 | Histórico, privacidade e recuperação | HO-003, HO-004, HO-011 |
| FEAT-010 | Férias/indisponibilidade manual para planeamento | HO-004, HO-005, HO-010 |

## outlook-publish — Outlook opcional: publicação unidirecional

**Quando:** Após core V1; iniciar separadamente quando houver autorização e acesso Microsoft.

**Gate:** HO-008 integrado; consentimento e CRUD de eventos próprios/all-day validados no Graph. Não condiciona releases do core.

**Reavaliar:** Depois do piloto core e quando houver acesso para o ensaio opcional.

| ID | Funcionalidade | Tarefas |
|---|---|---|
| FEAT-023 | Publicação Outlook opcional de dias confirmados | HO-008 |

## outlook-sync — Outlook opcional: disponibilidade e sincronização avançada

**Quando:** Após publicação opcional; priorização e infraestrutura próprias, sem compromisso de data.

**Gate:** HO-009 integrado; delta/paginação/recorrência, webhooks, lifecycle e reconciliação externa validados. Não condiciona o core.

**Reavaliar:** Após validar HO-008 e confirmar necessidade de importar disponibilidade.

| ID | Funcionalidade | Tarefas |
|---|---|---|
| FEAT-008 | Importação Outlook, delta, webhooks e reconciliação externa opcionais | HO-009 |

## v1.1 — Rotina e acompanhamento

**Quando:** Primeira iteração após duas semanas de utilização da V1; correções críticas têm prioridade.

**Gate:** Piloto V1 aceite e HO-101 a HO-103 integrados.

**Reavaliar:** Na retrospetiva do piloto e antes de iniciar a iteração.

| ID | Funcionalidade | Tarefas |
|---|---|---|
| FEAT-011 | Lembretes, resumo semanal e email | HO-101 |
| FEAT-012 | Exportação mensal e totais por período | HO-102 |
| FEAT-013 | Preferências de notificações e idiomas PT/EN/DE | HO-103 |

## v1.2 — Planeamento mais flexível

**Quando:** Iteração seguinte, após validar V1.1 e confirmar feedback sobre recorrência/viagens.

**Gate:** V1.1 estável e HO-201 a HO-203 integrados.

**Reavaliar:** No lançamento de V1.1.

| ID | Funcionalidade | Tarefas |
|---|---|---|
| FEAT-014 | Padrões recorrentes de pedidos | HO-201 |
| FEAT-015 | Meios dias, horários e dias de deslocação | HO-202 |
| FEAT-016 | Indicador de viagem já reservada | HO-203 |
| FEAT-017 | Planeamento provisório e datas flexíveis | HO-203 |

## v2.0 — Expansão por necessidade comprovada

**Quando:** Depois de estabilizar V1.x; selecionar o âmbito antes de iniciar cada tarefa.

**Gate:** Necessidade confirmada, ADRs de expansão e aceitação dos itens selecionados. Mudanças de âmbito exigem atualização versionada.

**Reavaliar:** No lançamento de V1.2 e em cada proposta de expansão.

| ID | Funcionalidade | Tarefas |
|---|---|---|
| FEAT-018 | Vários colaboradores e substituto do aprovador | HO-301 |
| FEAT-019 | Outlook com calendários adicionais/partilhados | HO-302 |
| FEAT-020 | Integração Google Calendar | HO-303 |
| FEAT-021 | Anexos e gestão de tarefas mais completa | HO-304 |
| FEAT-022 | Consulta e edição offline com resolução de conflitos | HO-305 |

## ios-reactivation — Reativação futura de iOS

**Quando:** Sem data; apenas após nova seleção explícita do responsável.

**Gate:** HO-306 e critérios iOS novamente acordados/verificados. Nunca gate de releases Web/Android.

**Reavaliar:** Quando houver necessidade e capacidade para retomar iOS.

| ID | Funcionalidade | Tarefas |
|---|---|---|
| FEAT-024 | Reativação iOS com validação e distribuição próprias | HO-306 |

## ui-refresh — Identidade visual Claude + — Web e Android

**Quando:** HO-016 integrado pelo PR #45 em 2026-09-11; claro/escuro e regressão verificados.

**Gate:** HO-016 integrado com regressão funcional e acessibilidade em claro/escuro; iOS permanece adiado.

**Reavaliar:** Ao selecionar o próximo trabalho visual e após feedback de utilização.

| ID | Funcionalidade | Tarefas |
|---|---|---|
| FEAT-025 | Tema Claude + e hierarquia visual acessível Web/Android | HO-016 |

## Regra de acompanhamento

Rever tarefas abertas no fecho de cada PR, o plano da release semanalmente durante o desenvolvimento e as funcionalidades futuras no marco indicado. Estes são rituais do projeto; não foi criado um lembrete automático fora da aplicação.

Uma data de lançamento só passa a compromisso quando acessos, capacidade e âmbito forem confirmados. Defeitos críticos precedem novas funcionalidades.
