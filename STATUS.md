# Estado do projeto

Atualizado: 2026-09-10.

HO-000 a HO-007 integrados; [histórico/evidência anterior](docs/history/HO-011-status-before-reconciliation.md).

HO-010 concluído: [PR #35](https://github.com/Dennyum204/HomeOfficeReservation/pull/35) integrado em main em 2026-09-10T17:17:47Z, commit `96cf3c3e06a6f753c29e3295875593a5370101da`, pertencente ao histórico remoto obtido por fetch. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34507336388) e [integração core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34507336432) concluídas com os quatro checks verdes. A evidência da implementação HO-010 permanece histórica, sem substituir ensaios dos fluxos alterados em HO-011.

HO-011 em implementação na branch `feat/ho-011-core-integration`, [issue #12](https://github.com/Dennyum204/HomeOfficeReservation/issues/12). Dependências HO-005/006/007/010 verificadas. Presenças/tarefas Android e navegação implementadas; [matriz de aceitação e percurso](docs/HO-011-CORE-ACCEPTANCE.md). A passagem real Web/Android passou (cinco/três/dois, leitura sem mudança, resolução e tarefa/progresso). Localmente: 33 testes Flutter, 47 PostgreSQL + 4 API, geração/diff de 172 ficheiros. Recusa de permissão e FCM foreground de presença/tarefa passaram no emulador autorizado. Background/cold start atual e CI do commit final ainda precisam de evidência antes de retirar draft.

Dados, contas, configuração Firebase e emuladores existentes preservados. iOS, Outlook, deployment e HO-012 fora do âmbito. Sem merge/auto-merge.
