# ADR-008 — Presenças, resolução explícita e tarefas

Data: 2026-09-09. Tarefa: [HO-006 / issue #7](https://github.com/Dennyum204/HomeOfficeReservation/issues/7). Implementação em revisão. Concretiza ADR-006/007, sem alterar Identity nem reativar iOS/Outlook.

## Decisão

OnsiteRequirement guarda intervalo inclusivo, motivo, local, referência de máquina/projeto, Revision de conteúdo e Version de concorrência. Edição avança ambos; leitura avança Version e grava um recibo por RequirementId/Revision. Alterar conteúdo invalida a leitura anterior, que permanece no histórico. Cancelamento é terminal e também avança Revision. Um recibo de leitura nunca altera PlanDay nem aceita uma contraproposta.

PlanningService mantém casos de uso explícitos em ficheiros por funcionalidade, no mesmo módulo/transação. O lock PlanningProfile, autorização relida após o lock, CalendarVersion, recibos idempotentes, auditoria e outbox do ADR-006 são reutilizados. Não se acrescenta mediator, repository genérico, serviço distribuído ou worker.

Presenças não escrevem PlanDay. Uma presença Active é projetada sobre o padrão inferido como OfficeSwitzerland/Working, incluindo fins de semana explicitamente abrangidos. Uma decisão OfficeSwitzerland/Working já existente mantém origem, versão e histórico. CalendarView devolve também a camada Requirements, pelo que o consumidor distingue obrigação, aprovação e leitura. Editar/cancelar remove apenas essa obrigação: o plano resulta das decisões e do padrão atuais e de quaisquer outras presenças ativas. Nunca se restaura uma cópia antiga do calendário.

## Tratamento de sobreposições

| Situação atual | Criação/edição da presença | Decisão posterior |
|---|---|---|
| Remoto explícito aprovado | NeedsResolution, aprovação preservada | Só revisão/decisão explícita muda o plano |
| Leave/Unavailable aprovado | NeedsResolution, disponibilidade preservada | Rever aprovação de planeamento; não representa autorização de RH |
| Pedido Submitted/Pending | Aviso no preview; pedido conservado; presença pode ficar Active | Remote/Leave/Unavailable incompatível com Active é recusado com 409 |
| Rascunho privado | Não reserva datas nem é revelado ao gestor | Conflitos revalidados na decisão |
| Outra presença no mesmo local | Compatíveis; ambas conservadas | Cancelar uma não retira a outra |
| Outra Active num local diferente | Nova/alterada fica NeedsResolution | Alterar/cancelar a obrigação incompatível explicitamente |
| Padrão semanal remoto/neutro | Active prevalece enquanto aplicável | Não transforma padrão em aprovação; reaparece o padrão vigente após cancelamento |

Comparação de locais: texto aparado, ordinal sem distinguir maiúsculas/minúsculas. V1 não inclui catálogo/geocodificação; o gestor deve usar o mesmo nome para o mesmo local. Intervalos são inteiros: uma sobreposição impeditiva deixa a obrigação inteira NeedsResolution, sem ativação parcial implícita.

Após decisão ou alteração de presença, dentro da mesma transação, a API relê factos atuais e recalcula os estados. Presenças existentes ativas mantêm prioridade; outras candidatas são avaliadas por CreatedAt/Id. Pedidos e obrigações não são silenciosamente cancelados. Revalidação grava mudança de estado no histórico com o mesmo CalendarVersion/evento transacional. O preview é apenas informação de um snapshot; a escrita repete a avaliação sob lock.

## Resolver o plano

O gestor propõe uma substituição OfficeSwitzerland/Working através de ChangeProposal sobre cada pedido aprovado afetado, com BaseDayId/BasePlanVersion atuais. Uma proposta ligada à presença inclui RequirementId/RequirementRevision. O colaborador aceita essa alternativa específica; a API cria uma nova revisão Submitted, mantendo o plano original. Na decisão final, a API verifica a revisão da presença e o reconhecimento da proposta e substitui os dias explicitamente. A mudança do plano e a eventual ativação da presença têm o mesmo commit/rollback. Se subsistem outras aprovações incompatíveis, a presença continua NeedsResolution; cada pedido afetado tem o seu processo explícito.

Uma edição/cancelamento da presença invalida uma resolução ligada à revisão antiga, mesmo que já aceite: 412/409, sem efeitos parciais. Rever a contraproposta sobre as decisões atuais e obter nova aceitação, ou retirar os dias ainda pendentes. O colaborador também pode iniciar a revisão do próprio plano, segundo ADR-006. Toda aprovação, incluindo revisões e contrapropostas genéricas anteriores, verifica presenças Active; não existe endpoint alternativo que contorne essa regra. Cancelar explicitamente um PlanDay não elimina uma presença ativa.

## Tarefas e histórico

AssignedTask tem título, descrição, colaborador atribuído, Deadline date-only, Todo/InProgress/Done/Cancelled, RequiresOnsite, ligação opcional e nota de progresso. O gestor gere os campos e pode reabrir uma tarefa. O colaborador pode passar Todo/InProgress para Todo/InProgress/Done e alterar apenas a nota de progresso; Done/Cancelled são terminais para ele. O DTO de progresso não contém campos de atribuição/local e rejeita propriedades desconhecidas.

O colaborador da tarefa é imutável no recurso. Para transferir trabalho, o gestor cancela a tarefa original e atribui outra ao colaborador autorizado; histórico não é transferido entre pessoas. Novos prazos/alterações de prazo seguem o horizonte normal; uma tarefa vencida continua atualizável mantendo o prazo antigo.

RequiresOnsite é estritamente informativo, mesmo sem ligação. Ligar uma presença exige o mesmo colaborador/organização. Não se pode criar uma ligação nova a uma presença cancelada; uma ligação existente permanece visível, com estado e revisão atuais. Editar/cancelar presença não altera título, prazo, progresso ou estado da tarefa. Uma ação explícita permite atribuir tarefa a partir da presença.

WorkEntry conserva snapshots de conteúdo/revisões/estados e comentários append-only, com chaves estrangeiras de contexto/organização/colaborador. Reutiliza a autorização, lock, idempotência, auditoria e outbox existentes; tabela separada evita enfraquecer o contexto obrigatório PlanningComment.RequestId do histórico anterior. Leituras paginadas (25 por defeito, máximo 100) exigem acesso atual; nenhum histórico privado é exposto a outros colaboradores/organizações.

## Limites e recuperação

Mesmas regras de datas/horizonte do ADR-006. Criar/editar/cancelar intervalos já iniciados não é uma correção retroativa: o comando normal exige todas as datas a partir de hoje da organização. Presenças históricas e recibos continuam consultáveis. Correções administrativas de dias passados permanecem fora do âmbito.

Migração aditiva `20260909184158_OnsiteRequirementsAndTasks`: quatro tabelas e dois campos opcionais em ChangeProposals, sem apagar contas/pedidos/dias existentes. Aplicação explícita, backup privado e recuperação no [guia HO-006](../HO-006-ONSITE-TASKS.md). Rollback de aplicação pode manter o esquema aditivo; não executar Down num ambiente com histórico novo.

Web conserva campos locais em sessionStorage, separados por conta/colaborador/contexto, até sucesso ou logout explícito; após nova autenticação na mesma conta, reabrir o mesmo formulário para recuperar o texto. Versões e preview precisam de nova revisão. Troca de conta apaga os rascunhos. Comandos incertos usam o journal wire gerado do ADR-007, incluindo a chave original. Não há escrita offline nem tokens no armazenamento da Web.

Outbox é persistida, DeliveredAt nulo: nenhuma notificação foi entregue por HO-006. Android recebe apenas o contrato regenerado; interfaces de calendário/tarefas continuam HO-010/011. iOS/HO-306 e Graph não foram executados.

## Fontes oficiais consultadas em 2026-09-09

- [PostgreSQL 18 — locks de linha](https://www.postgresql.org/docs/18/explicit-locking.html): exclusão dos escritores durante a transação.
- [EF Core — transações](https://learn.microsoft.com/en-us/ef/core/saving/transactions): vários saves sob uma transação explícita.
- [EF Core — gerir migrações](https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/managing): rever alterações geradas e preservar dados existentes.
- [React — efeitos e cancelamento de leituras](https://react.dev/reference/react/useEffect): respostas antigas não devem substituir dados do âmbito atual.

Os testes executados e os resultados remotos pertencem a STATUS/PR, não são inferidos destas fontes.
