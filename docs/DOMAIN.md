# Domínio, datas e transições

## Dimensões separadas

| Dimensão | Valores conceptuais |
|---|---|
| Localização | OfficeSwitzerland, RemotePortugal, Unplanned |
| Disponibilidade | Working, Leave, Unavailable |
| Pedido | Draft, Submitted, Closed, Withdrawn |
| Decisão por dia | Pending, Approved, Rejected, Superseded, Cancelled |
| Obrigação presencial | Active, NeedsResolution, Cancelled |
| Leitura | PendingAcknowledgement, Acknowledged |
| Publicação opcional (HO-008) | Disabled, Pending, Published, Error, ReconnectRequired |
| Reconciliação posterior (HO-009) | Diverged e estados de importação; ausentes do core |

`PartiallyApproved` é um resumo do conjunto de decisões por dia, não uma forma de perder as datas individuais. A UI pode mostrar uma aprovação parcial enquanto ainda existem outros dias pendentes.

## Entidades propostas

| Entidade | Campos/relações essenciais |
|---|---|
| Organization | Id, nome, zona de planeamento e configuração |
| Member | Id, OrganizationId, IdentityUserId local, papéis, idioma, zona preferida, Active |
| ReportingLine | EmployeeId, ManagerId, vigência; uma chefia decisora ativa por colaborador na V1 |
| PlanningProfile | Padrão semanal, vigência e CalendarVersion para concorrência por colaborador |
| RemoteWorkRequest | EmployeeId, Revision, ParentRevisionId, comentário, SubmittedAt, estado |
| RequestedDay | RequestRevisionId, LocalDate, localização pedida, decisão, razão e versão |
| ChangeProposal | Dias originais afetados, substituição proposta, autor, reconhecimentos e decisão |
| PlanDay | EmployeeId, LocalDate, disponibilidade/localização, origem da decisão, versão |
| OnsiteRequirement | EmployeeId, intervalo, motivo, local, MachineReference, estado e versão |
| Acknowledgement | Requirement/ProposalId, MemberId, instante e revisão reconhecida |
| TaskItem | AssigneeId, prazo, RequiresOnsite, estado, RequirementId opcional |
| Comment | ContextType/Id, autor, texto, instante |
| Notification | RecipientId, EventId, tipo, contexto, CreatedAt, ReadAt |
| DeviceRegistration | MemberId, plataforma, token cifrado, validade/último uso |
| OutlookConnection | OwnerId, identidade mailbox, consentimento, estado, cache cifrada |
| ExternalEventMap | ConnectionId, fonte local/versão, CalendarId, ImmutableEventId, hash de projeção |
| ExternalBusyInterval | ConnectionId, EventId, intervalo, disponibilidade; sem corpo/título privado |
| SyncCursor | ConnectionId, início/fim fixos, next/delta link cifrado, checkpoint |
| GraphSubscription | ConnectionId, SubscriptionId, expiração e clientState protegido |
| OutboxMessage | Id, tipo, agregado/versão, payload mínimo, lease, tentativa e entrega |
| AuditEntry | ActorId, ação, entidade/revisão, instante e mudança mínima |

OutlookConnection e ExternalEventMap pertencem apenas a HO-008. ExternalBusyInterval, SyncCursor e GraphSubscription pertencem apenas a HO-009; não são tabelas obrigatórias do core nem do scaffold. A conta da aplicação é IdentityUser; ligação Microsoft posterior é opcional, vinculada ao MemberId local, sem comparar emails como prova.

Os IDs de negócio são gerados pelo servidor. Unicidade de `PlanDay(EmployeeId, LocalDate)` impede duas localizações efetivas no mesmo dia. Constraints de associação incluem a organização; filtros globais são apoio, não substituem a autorização explícita.

## Transições principais

| Ação | Pré-condição | Efeito |
|---|---|---|
| Guardar rascunho | Próprio colaborador, Draft | Altera apenas o rascunho |
| Submeter | Dias válidos, sem sobreposição pendente incompatível | Congela revisão e cria dias Pending |
| Aprovar subconjunto | Chefe atribuído, versão atual, dias Pending | Revalida conflitos; grava PlanDay e decisões Approved |
| Rejeitar subconjunto | Chefe atribuído, dias Pending | Grava Rejected e razão |
| Retirar | Próprio colaborador | Retira só dias ainda pendentes; aprovados mantêm-se |
| Contrapropor | Chefe atribuído | Regista alternativa; original não muda automaticamente |
| Aceitar alternativa | Próprio colaborador | Cria nova revisão Submitted para decisão final |
| Alterar/cancelar aprovado | Proposta de revisão sobre dias existentes | Mantém o plano efetivo enquanto não resolvida |
| Resolver revisão | Chefe decide, reconhecimento do colaborador se proposta imposta pelo chefe, versão atual | Substitui/cancela dias explicitamente; histórico original fica |
| Criar presença sem conflito | Chefe atribuído | Cria Active; solicita confirmação de leitura |
| Criar presença sobre remoto aprovado | Chefe atribuído | Cria NeedsResolution; preserva remoto aprovado |
| Resolver conflito de presença | Revisão reconhecida e aprovada, ou compromisso alterado/cancelado | Atualiza de forma atómica os dois lados incompatíveis |

Uma decisão parcial aplica-se atomicamente ao conjunto de dias selecionados. Se um dos dias selecionados tiver entretanto mudado, toda essa operação é recusada; a UI apresenta o estado atualizado para nova seleção. Dias já decididos não regressam a Pending nessa revisão.

## Regras de integridade

- Pedidos sobrepostos pendentes são rejeitados com indicação do pedido existente, salvo revisão explicitamente ligada.
- Uma presença Active impede aprovar remoto nesses dias. Uma presença NeedsResolution permanece visível como conflito.
- Reconhecimento fica ligado à revisão; se o chefe altera datas, o reconhecimento antigo não vale para a nova revisão.
- Registo de indisponibilidade e decisões que alteram o plano usam a mesma verificação de conflitos.
- Não aceitar alterações retroativas a dias concluídos no fluxo normal; uma correção administrativa futura precisa de motivo e auditoria.
- Notificação e outbox têm chaves de deduplicação únicas. Operações idempotentes com payload diferente para a mesma chave falham.

## Concorrência

O mesmo ETag do pedido não é suficiente para detetar uma presença criada noutro agregado. Todas as mutações que afetam o plano do mesmo colaborador bloqueiam/validam a linha PlanningProfile dentro de uma transação e incrementam CalendarVersion. Depois do lock, reconsultam datas, presenças e indisponibilidades, e só então gravam o resultado.

Ordem de locks determinística se uma operação futura envolver vários colaboradores. Índices/constraints completam as validações; não confiar numa sequência de leitura seguida de escrita sem proteção. Testar a corrida entre aprovação e criação de obrigação presencial em PostgreSQL.

## Datas e zonas

- Datas de trabalho: .NET DateOnly / PostgreSQL date / JSON `YYYY-MM-DD`.
- Intervalos do produto são inclusivos no formulário. Internamente, a projeção para eventos usa fim exclusivo de forma documentada.
- Selecionar 12–14 significa três datas; um evento all-day correspondente termina às 00:00 do dia 15 na mesma zona.
- A organização tem zona de planeamento configurada, proposta Europe/Zurich. O utilizador pode ver horas em Europe/Lisbon.
- Eventos com horas guardam instantes UTC e zona original; dias inteiros nunca são deslocados através de uma conversão UTC.
- Usar mapeamento de zonas suportadas pelo Graph; não assumir que qualquer string IANA é aceite por todos os endpoints. Verificar no marco opcional HO-008; o core testa DateOnly/DST sem Graph.
- Em HO-009, uma disponibilidade Outlook importada será apenas um intervalo/aviso. O core usa indisponibilidade manual e plano interno, sem leituras de calendários externos.

## Identidade implementada em HO-003

Organization, Member e ReportingLine persistidos em PostgreSQL. Employee/Manager e administrador de contas distintos; um membro por IdentityUser. Guard exige organização, ambos ativos, papel de gestor, colaborador atribuído e IDs diferentes. API consulta estado atual por operação; não usa papéis enviados pelo cliente como autoridade. Nenhuma entidade de pedido/decisão foi implementada aqui. [Detalhes e limites](HO-003-AUTHENTICATION.md).
