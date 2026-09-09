# ADR-006 — Planeamento transacional por colaborador

Estado: implementação HO-004, 2026-09-09, sujeita a revisão humana. Issue [#5](https://github.com/Dennyum204/HomeOfficeReservation/issues/5). Concretiza DOMAIN.md e preserva ADR-004/ADR-005.

## Decisão

PlanningProfile é a unidade de serialização do calendário. Cada comando abre uma transação PostgreSQL Read Committed, cria o perfil se ainda não existir com `INSERT ... ON CONFLICT DO NOTHING`, adquire `SELECT ... FOR UPDATE` e só depois relê autoridade, versões, dias efetivos e reservas pendentes. CalendarVersion é incrementada uma vez por comando bem-sucedido. Rascunhos, comentários e alterações do padrão também seguem esta ordem simples; podem invalidar uma versão de calendário obtida por outro cliente.

A autoridade é relida depois do lock: membro ativo, mesma organização, papel e relação atribuída, sem autoaprovação ou acesso administrativo implícito ao planeamento. Membros são bloqueados para leitura em ordem de ID e a relação existente também é protegida até ao commit. Uma atualização administrativa concorrente espera ou é observada antes da autorização. Leituras compostas usam um snapshot Repeatable Read, com autorização e CalendarVersion no mesmo snapshot; não afirmam refletir uma alteração posterior ao início dessa leitura.

Unicidade efetiva em PlanDay(EmployeeId, LocalDate); índice único parcial de RequestedDay(EmployeeId, LocalDate) onde ReservesDate impede duas propostas submetidas concorrentes para a mesma data. Rascunhos não reservam datas. Chaves estrangeiras compostas incluem organização/colaborador, além das validações explícitas da API. HO-006 deve adquirir o mesmo perfil antes de consultar/criar presenças e resolver conflitos. **Não existem tabelas de presenças nem teste de corrida com presenças em HO-004.**

## Plano, revisões e histórico

Localização, disponibilidade, decisão por dia, origem e versão são distintos. Working exige OfficeSwitzerland ou RemotePortugal; Leave/Unavailable exigem Unplanned. Férias/indisponibilidade são propostas manuais decididas pelo gestor para planeamento, sem alegar aprovação de RH. Dias confirmados só mudam por revisão explícita com BaseDayId e BasePlanVersion atuais. Uma alteração/cancelamento pendente, rejeitado ou retirado mantém o plano anterior. Cancelar com aprovação remove o PlanDay explícito, tornando novamente visível o padrão; a decisão cancelada fica no histórico.

A submissão congela o conteúdo de uma revisão. Editar um rascunho substitui os seus dias; a auditoria retém IDs/transições removidas. Uma revisão ligada pode substituir reservas Pending do seu pai nas mesmas datas, marcando-as Superseded; outras datas pendentes do pai mantêm-se. Não permite substituir reservas de outro pedido. Alterações de datas já aprovadas indicam explicitamente cada cancelamento/substituição; mudar para outra data requer incluir o cancelamento da original e a nova data, com decisões por dia explícitas.

Uma seleção de decisão/retirada é validada integralmente antes de alterar dias. Se algum ID, estado, versão ou base estiver inválido, toda a transação é recusada. A retirada aceita apenas Pending, nunca cancela Approved. O estado agregado é derivado; aprovação parcial não elimina estados individuais. As versões do pedido e dos dias mudam com decisões, sem voltar um dia decidido a Pending nessa revisão.

Contrapropostas guardam uma alternativa imutável por revisão, razão obrigatória, autor e versões dos dias afetados. Criar não altera o pedido/plano. Aceitar guarda reconhecimento ligado ao ID/revisão e cria uma nova revisão Submitted; o gestor ainda tem de decidir. Alterar uma contraproposta cria outro ID no mesmo grupo, marca a anterior Superseded e exige novo reconhecimento. Se a anterior já foi aceite mas todos os seus dias continuam Pending, estes são superseded; o reconhecimento antigo não autoriza a nova alternativa. Se algum desses dias já foi resolvido, a alteração é recusada: criar uma nova proposta sobre as decisões atuais. O histórico/ack antigo permanece consultável.

## Datas e padrão

DateOnly, coluna `date`, JSON `YYYY-MM-DD`. A zona de planeamento da organização é Europe/Zurich por defeito, incluindo organizações existentes na migração. O operador configura outra zona suportada; não há UI administrativa de zonas neste âmbito. «Hoje» é calculado nessa zona, não em UTC. Escritas normais aceitam hoje até hoje + 730 dias, no máximo 366 datas distintas num intervalo de 366 dias. Intervalos de preview são inclusivos e excluem fins de semana por defeito; arrays explícitos podem incluí-los.

O padrão implícito é presencial em dias úteis e neutro ao fim de semana (Unplanned, disponibilidade nula). WeeklyPattern guarda sete localizações, segunda a domingo, por EffectiveFrom. Mudanças são append-only com vigência crescente, nunca retroativa; substituir uma vigência existente não é suportado nesta entrega. Datas anteriores mantêm o padrão anterior. PlanDays explícitos prevalecem. Não materializamos dias inferidos nem os apresentamos como aprovados. Um padrão de remoto é inferido, não autorização de um pedido nem candidato a publicação Outlook.

Calendário: máximo 366 dias, dentro de hoje - 365 a hoje + 730; EffectiveDays e PendingDays separados. Contrapropostas abertas são consultadas no contexto do pedido, não reservam datas. Listas têm offset 0–10000 e limite 1–100 (default 25), ordenação estável por timestamp/ID; inserções entre páginas podem deslocar offsets, pelo que os clientes atualizam a lista ao receber nova CalendarVersion. Adequado ao piloto; keyset pagination fica para necessidade demonstrada.

## Retry, auditoria e outbox

Todos os comandos exigem Idempotency-Key, 8–128 caracteres ASCII alfanuméricos, ponto, hífen ou underscore. Recibo único por ator/operação, hash SHA-256 do payload tipado, contexto e colaborador. O mesmo comando devolve o recibo original mesmo depois de a versão avançar; payload diferente falha. Ordem de arrays faz parte do comando. Autoridade atual é verificada também no replay. Não há expiração/limpeza automática dos recibos nesta entrega; definir retenção no alojamento sem eliminar garantias de retries ativos.

ExpectedCalendarVersion e versões específicas são precondições no corpo JSON: 428 se faltar, 412 se desatualizada. Não se implementa um ETag alternativo com semântica concorrente. 409 representa conflito de negócio ou chave idempotente incompatível; 400 dados inválidos. Problem Details inclui `code`; contratos usam enums textuais e números JSON estritos, sem versões em strings. IDs são gerados no servidor. Após 412/409 o cliente relê calendário/pedido e pede nova seleção, usando nova chave; nunca repete uma decisão silenciosamente com versões substituídas.

Cada comando persiste alteração, auditoria e outbox na mesma transação, incluindo saves intermédios necessários para libertar reservas/índices. Auditoria mínima: ator/contexto/ação/instante/CalendarVersion e IDs/transições/versões dos dias; conteúdo completo permanece no pedido/contexto autorizado. Ao substituir uma aprovação preservamos autor, instante e razão da aprovação original. Outbox tem ID estável partilhado com a auditoria e payload versão 1 com IDs/contexto/CalendarVersion, sem passwords, comentários, emails ou detalhes de calendário. Unicidade por colaborador/CalendarVersion e recibos evitam duplicação em retries concorrentes.

DeliveredAt permanece nulo. Não há worker, entregas, push ou Graph em HO-004. HO-007 definirá leases/retries/consumidores idempotentes e filtrará ações privadas de rascunho; não deve enviar notificações ao gestor sobre rascunhos privados. Falhas de transporte depois do commit são resolvidas pelo mesmo recibo; falhas no insert da outbox revertem também plano/auditoria/CalendarVersion.

## Fontes oficiais consultadas em 2026-09-09

- [PostgreSQL 18, locks explícitos](https://www.postgresql.org/docs/18/explicit-locking.html): bloqueio por linha e duração transacional.
- [EF Core, transações](https://learn.microsoft.com/en-us/ef/core/saving/transactions): transação explícita abrangendo vários saves.
- [EF Core, SQL parametrizado](https://learn.microsoft.com/en-us/ef/core/querying/sql-queries): interpolação parametrizada; sem IDs/SQL construídos de texto do cliente.
- [Npgsql, mapeamentos](https://www.npgsql.org/efcore/mapping/general.html): tipos de persistência PostgreSQL.
- [OpenAPI Generator 7.25.0, templates Dart](https://github.com/OpenAPITools/openapi-generator/tree/v7.25.0/modules/openapi-generator/src/main/resources/dart2): ajuste restrito do template de queries `format: date`; sem edição manual de clientes. Ensaios de serialização simulados não substituem HTTP real.

Evidência concreta, limites e comandos: [guia HO-004](../HO-004-PLANNING.md) e STATUS/PR. Web/mobile continuam a mostrar áreas de negócio em preparação; o calendário UI pertence a HO-005/HO-010.
