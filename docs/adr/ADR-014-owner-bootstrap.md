# ADR-014 — Titular com administração e colaboração na mesma identidade

Data: 2026-09-11. Estado: implementado em HO-013, sujeito a revisão/merge humano. [Issue #38](https://github.com/Dennyum204/HomeOfficeReservation/issues/38).

## Contexto e continuidade

ADR-004/005 mantêm ASP.NET Core Identity, membros separados das credenciais, cookie Web e bearer/refresh opacos Android. O bootstrap original cria apenas um administrador, que não pode editar os próprios papéis pela API. O responsável precisa de planear como colaborador com a mesma conta e ter um chefe distinto. A lacuna foi registada no [contexto de acesso privado do PR #37](https://github.com/Dennyum204/HomeOfficeReservation/blob/600238d6d65131cf981b5313b19547bc66f39cb6/docs/HO-012-PRIVATE-ACCESS.md).

Este ADR complementa, não apaga, ADR-005. ADR-013 está reservado à proposta operacional no PR #37, ainda draft; o salto numérico evita uma colisão. Não incorpora essa proposta nem decide alojamento.

## Decisão

- Manter `--bootstrap-admin` e o seu JSON: administrador apenas, organização nova, ativação Identity e recusa de organização existente.
- Acrescentar `--bootstrap-owner`: escolha explícita do operador para criar uma única Identity e membro ativo com `IsAccountAdministrator=true`, `IsEmployee=true`, `IsManager=false`. Sem password inicial, registo público ou login automático.
- Acrescentar `--enable-admin-employee`: seleção obrigatória por UUID da organização **e** membro, motivo obrigatório até 500 caracteres, membro existente/ativo/administrador e Identity válida. A única propriedade alterada é `IsEmployee`. Sem reativação, recuperação de password, alteração de security stamp ou atribuição de gestão implícitas.
- Repetir o bootstrap de titular só é aceite se a organização, identidade/email, nome do membro, papéis esperados e auditoria original coincidirem. Nunca converte o bootstrap antigo por inferência. Repetir a extensão de colaborador devolve `already_employee`, sem escrita ou nova auditoria. Novos comandos recusam campos JSON desconhecidos e comandos de manutenção misturados.
- A fronteira do operador é acesso ao processo/ficheiro privado e credenciais de manutenção da base. O dispatcher termina antes de Kestrel servir pedidos; não se acrescenta endpoint HTTP de elevação. A auditoria `operator` não pretende identificar um utilizador humano: o operador conserva também o registo de acesso ao host/execução e o motivo. Nunca se inventa um ator de aplicação.

## Transações, concorrência e auditoria

Todos os escritores administrativos existentes (criação, alteração de papéis/estado e associação de gestor) adquirem `FOR NO KEY UPDATE` na organização e **voltam a consultar a autoridade do ator depois do lock**. A atualização do membro volta a ler o alvo. A transação serializa duas desativações/despromoções recíprocas: depois da primeira, o segundo ator perdeu autoridade. A verificação explícita de outro administrador ativo é adicional à recusa de autoedição. Não basta contar administradores fora da transação.

Antes de existir uma linha de organização, o bootstrap usa `pg_advisory_xact_lock(hashtextextended(nome, 0))`; a constraint única de nome continua ativa. Colisões de hash apenas serializam criações adicionais. Ordem: lock de nome quando aplicável → organização → membros/Identity/auditoria → commit. `NO KEY UPDATE` permite os locks `KEY SHARE` de FKs das transações de planeamento, evitando um ciclo desnecessário organização/perfil/membro. Mantêm-se os locks e regras de negócio de HO-004; não se adquire um lock de calendário nesta manutenção.

`AccessAudit` reutiliza DbContext, transação e padrão de auditoria JSON do planeamento: IDs da organização/alvo/ator, origem, ação, instante, motivo e estados mínimos antes/depois. Não contém password, email de entrega, token, código ou payload de calendário. A auditoria de planeamento tem FK ao perfil e unicidade por versão de calendário; acrescentar-lhe uma falsa decisão alteraria dados que este procedimento deve preservar. Por isso a tabela estreita `AccessAudits` tem vida própria, FKs compostas por organização, índice cronológico e constraint origem/ator. Não existe framework genérico novo nem API de edição de auditoria.

Criação e alterações administrativas efetivas são auditadas na mesma transação; no-ops e recusas não inventam uma alteração persistida. A entrega de ativação existente ocorre depois do commit, fora do lock. Falhar a entrega não elimina a conta: reparar o canal e pedir novo código no fluxo Identity existente. Repetir bootstrap não reenvia. A durabilidade/reenvio de convites é HO-014.

## Consequências e alternativas

Não criar segunda conta do titular, endpoint público de recuperação, autoatribuição de papéis, novo protocolo Identity ou privilégios de gestor derivados de administração. O chefe é outro membro com papel gestor e relação explícita, pelos endpoints administrativos já existentes. Autoaprovação continua sempre proibida, mesmo com os três papéis. API self-role edit continua proibida.

Migration `20260910214756_AccessAudit` só acrescenta tabela/índices/FKs; não reescreve contas, hashes, ativação, sessões, perfis, relações, planos ou notificações. Aplicá-la explicitamente antes de executar a versão nova. Reverter o código é possível mantendo a tabela aditiva; executar `Down` após utilização apagaria a auditoria. Restaurar só por procedimento de backup validado, sem reprovisionar contas. O lock protege os escritores da aplicação; SQL manual com credenciais privilegiadas pode violar invariantes e não é um mecanismo de produto suportado.

A recuperação permitida é acrescentar colaboração ao administrador ativo inequivocamente identificado. Uma organização legada já sem administrador ativo é recusada; exige investigação/restauro controlado pelo operador, não reativação ou promoção silenciosa deste comando. HO-014 trata convites; HO-015 a interface administrativa; HO-016 o tema. iOS/Outlook permanecem adiados.

## Evidência e fontes

`OwnerBootstrapTests` executa o dispatcher real sobre PostgreSQL isolado: bootstrap concorrente e replay, extensão do legado, preservação de ativação/password/stamps/calendário/relações/sessões, falha simulada de entrega e recuperação Identity, pedido por cookie e decisão pelo chefe via bearer, negações e dois escritores concorrentes bloqueados no servidor PostgreSQL. Asserções com hashes de estado não imprimem dados privados. Os testes de email capturam mensagens em memória; não provam SMTP real. Regressão browser/emulador e quatro checks remotos são registados no PR, sem transformar testes API em testes de interface.

Fontes oficiais consultadas em 2026-09-10, decisão registada em 2026-09-11:

- [PostgreSQL 18: locks explícitos, conflitos de row locks e advisory locks](https://www.postgresql.org/docs/18/explicit-locking.html).
- [EF Core: transações e atomicidade de SaveChanges](https://learn.microsoft.com/en-us/ef/core/saving/transactions).
