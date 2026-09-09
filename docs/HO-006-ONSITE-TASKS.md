# HO-006 — Presenças e tarefas na API/Web

Âmbito e regras: [ADR-008](adr/ADR-008-onsite-and-tasks.md). [Issue #7](https://github.com/Dennyum204/HomeOfficeReservation/issues/7) · [PR #33](https://github.com/Dennyum204/HomeOfficeReservation/pull/33). Web e Android são os alvos atuais; esta entrega implementa a interface Web e o contrato API para Android posterior. Sem notificações entregues, anexos, Outlook ou iOS.

## Atualizar um ambiente existente

Não repetir provisionamento/reset das contas. Parar a API antes de substituir os binários no Windows. Fazer backup privado PostgreSQL com `pg_dump -Fc` e registar a localização fora do Git. Guardar passwords em configuração/variáveis privadas, nunca num comando versionado. No ambiente local preparado já existe PostgreSQL portátil; não é preciso instalar Docker para continuar.

Na raiz, com os SDKs fixados disponíveis:

```sh
dotnet restore apps/api/HomeOffice.slnx --locked-mode
dotnet build apps/api/HomeOffice.slnx -c Release --no-restore
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --migrate
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build
```

Migração `20260909184158_OnsiteRequirementsAndTasks`: OnsiteRequirements, OnsiteAcknowledgement, AssignedTasks, WorkEntries e RequirementId/RequirementRevision opcionais em ChangeProposals. Sem remoção de dados antigos. Aplicar migrações duas vezes é seguro. Rever SQL antes de ambientes partilhados:

```sh
dotnet tool restore
dotnet ef migrations script --idempotent --project apps/api/src/HomeOffice.Infrastructure --startup-project apps/api/src/HomeOffice.Api --configuration Release --output .git/ho006-migrations.sql
```

Recuperação: preferir correção aditiva ou voltar à versão anterior da aplicação mantendo o esquema. A migração Down remove dados de HO-006 e não deve ser usada como rollback operacional. Restauro do backup exige interrupção planeada e confirmação do destino; não restaurar sobre dados novos sem os preservar. Nenhum restauro/deployment foi realizado nesta tarefa.

API em `http://localhost:5080`; Web:

```sh
npm --prefix apps/web ci
npm --prefix apps/web run dev
```

Abrir `http://127.0.0.1:5173`, com as contas sintéticas privadas já existentes. Android mantém o comando do [guia mobile](../apps/mobile/README.md), ligado a `http://10.0.2.2:5080`; não apresenta ainda esta interface de presenças/tarefas.

## Percurso manual

1. Gestor: escolher o colaborador atribuído. Em Calendário, selecionar datas e clicar Nova presença; ou abrir Presenças → Nova presença. Indicar motivo, intervalo inclusivo, local e máquina/projeto. Pré-visualizar conflitos e confirmar.
2. Colaborador: abrir a presença e confirmar leitura. Essa ação não altera o plano nem aceita uma revisão.
3. Gestor: criar outra presença sobre remoto aprovado. Ambos abrem o dia no calendário: o remoto continua confirmado e a presença aparece Por resolver.
4. Gestor: no detalhe da presença, Propor resolução do plano para cada aprovação afetada. Rever datas/local presencial/motivo e enviar a contraproposta. Colaborador aceita em Pedidos. Gestor decide a nova revisão; só então muda o plano e a presença pode ficar Ativa. Alternativa: alterar/cancelar a presença.
5. Gestor: Atribuir tarefa a partir da presença ou na área Tarefas. Definir título, descrição, prazo e ligação. Colaborador abre a tarefa e atualiza progresso. RequiresOnsite, por si só, não muda o calendário.
6. Abrir comentários/histórico para consultar revisões. Editar uma presença exige nova leitura; cancelar mantém as tarefas ligadas identificadas como tal.

Depois de 412/409, rever dados atualizados e confirmar explicitamente que foram revistos; conservar texto e fazer novo preview. Se o resultado de uma escrita for incerto, usar Recuperar operação antes de enviar outra. Após interrupção de sessão, entrar na mesma conta/separador e reabrir o formulário para retomar o texto. Logout explícito e troca de conta apagam estes rascunhos.

## Contrato

Base `/api/v1/planning/{employeeId}`. Todas as escritas usam `Idempotency-Key`, ExpectedCalendarVersion e, em recursos existentes, ExpectedVersion; leitura também exige Revision. 403 autorização, 404 contexto indisponível, 409 conflito, 412 desatualização, 428 versão ausente. Datas `YYYY-MM-DD`, sem passagem por UTC. Contrato completo e clientes gerados em [contracts](../contracts/README.md).

| Recurso | Operações |
|---|---|
| `GET /onsite-preview` | from/to inclusivos, location e excludes opcional; factos atuais e estado previsto |
| `/requirements` | GET paginado/estado, POST criar |
| `/requirements/{id}` | GET detalhe, PUT editar |
| `/requirements/{id}/acknowledge`, `/cancel` | POST leitura por revisão / cancelamento do gestor |
| `/tasks`, `/tasks/{id}` | GET lista/detalhe, POST atribuir, PUT gestão pelo gestor |
| `/tasks/{id}/progress` | POST pelo próprio colaborador; apenas estado permitido e nota |
| `/work/{Requirement|Task}/{id}/entries`, `/comments` | GET histórico/comentários paginados, POST comentário |
| Endpoints existentes de propostas/aceitação/decisão | Resolução explícita, com vínculo opcional à revisão da presença |

## Verificação

```sh
python scripts/check_project.py
python scripts/generate_contracts.py --check
dotnet format apps/api/HomeOffice.slnx --no-restore --verify-no-changes
dotnet test apps/api/HomeOffice.slnx -c Release --no-build
npm --prefix apps/web run format:check
npm --prefix apps/web run typecheck
npm --prefix apps/web run lint
npm --prefix apps/web test
npm --prefix apps/web run build
npm --prefix apps/web run test:e2e
```

Testes PostgreSQL exigem `HO_TEST_DATABASE`; os fixtures criam e eliminam apenas bases descartáveis `ho003_test_*`. Web E2E exige `HO_DEV_ACCOUNTS` com caminho privado, usa API real na porta 5083 e Vite 5174, e escolhe datas livres, preservando histórico. Os [guias API](../apps/api/README.md) e [Web](../apps/web/README.md) explicam a configuração segura destas variáveis. Não mostrar o conteúdo desses ficheiros.

Asserções de HTTP e PostgreSQL distinguem-se de Vitest/HTTP simulados e de falhas de rede injetadas depois de um commit real. Capturas E2E só após login, com dados sintéticos; sem traces que incluam passwords. Resultados finais e links CI em STATUS/PR. Android analysis/test/build/emulador continuam gates; iOS e probe Outlook continuam fora deles.
