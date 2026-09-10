# Estado do projeto

Atualizado: 2026-09-10.

HO-000 a HO-007 integrados; [histórico/evidência anterior](HO-011-status-before-reconciliation.md).

HO-010 concluído: [PR #35](https://github.com/Dennyum204/HomeOfficeReservation/pull/35) integrado em main em 2026-09-10T17:17:47Z, commit `96cf3c3e06a6f753c29e3295875593a5370101da`, pertencente ao histórico remoto obtido por fetch. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34507336388) e [integração core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34507336432) concluídas com os quatro checks verdes. A evidência da implementação HO-010 permanece histórica, sem substituir ensaios dos fluxos alterados em HO-011.

HO-011 implementado, em `review` no [PR #36](https://github.com/Dennyum204/HomeOfficeReservation/pull/36), branch `feat/ho-011-core-integration`, [issue #12](https://github.com/Dennyum204/HomeOfficeReservation/issues/12). Dependências HO-005/006/007/010 verificadas. Presenças/tarefas Android e navegação completas; [matriz, capturas e percurso](../HO-011-CORE-ACCEPTANCE.md). A passagem real Web/Android passou (cinco/três/dois, leitura sem mudança, resolução e tarefa/progresso). Localmente: 34 testes Flutter, 47 PostgreSQL + 4 API, contratos idênticos em 172 ficheiros, Web estática/unit/build e browser. Recusa real de permissão, FCM foreground de presença/tarefa, tarefa background, presença cold start e mudança de conta passaram no emulador selecionado. O [recibo de CI](https://github.com/Dennyum204/HomeOfficeReservation/pull/36#issuecomment-5623557694) regista o SHA final e os quatro checks remotos; draft só é retirado após os quatro verdes e ausência de conflitos. A issue permanece aberta e o item não é `done` antes de merge humano e integração verificada.

Dados, contas, configuração Firebase e emuladores existentes preservados. iOS, Outlook, deployment e HO-012 fora do âmbito. Sem merge/auto-merge.

PostgreSQL, API, Web e app Android normal foram mantidos disponíveis localmente; o bundle com contas privadas de teste foi substituído pelo entrypoint normal. Próximo trabalho, apenas após merge verificado: **HO-012 — hosting, operational readiness and pilot preparation**.
