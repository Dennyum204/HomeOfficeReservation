# Estado do projeto

Atualizado: 2026-09-09.

HO-000 a HO-004 integrados; histórico/evidência preservados em [estado anterior](docs/history/HO-005-status-before-reconciliation.md). Graph real continua adiado, não validado. Web/Android ativos; iOS adiado HO-306, sem gates ou execução nesta tarefa.

**HO-005 concluído:** [PR #32](https://github.com/Dennyum204/HomeOfficeReservation/pull/32) integrado por humano em main em 2026-09-09T18:29:20Z, commit `aeb4f38ab258b8bb8845e4887737f3697795cf81`, confirmado no histórico de origin/main após fetch. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34389305274) e [integração core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34389305405) concluídas com sucesso: project-docs, backend-contracts, web, flutter-android. Issue encerrada pelo merge, não substitui esta evidência.

**HO-006 em revisão**, [PR #33](https://github.com/Dennyum204/HomeOfficeReservation/pull/33), branch `feat/ho-006-onsite-conflicts-tasks`, [issue #7](https://github.com/Dennyum204/HomeOfficeReservation/issues/7). Dependências HO-004/HO-005 verificadas. API/Web: presenças com preview, leitura por revisão, resolução explícita transacional e tarefas ligadas com progresso protegido. [Guia](docs/HO-006-ONSITE-TASKS.md), [ADR-008](docs/adr/ADR-008-onsite-and-tasks.md), [capturas reais](docs/evidence/ho-006/README.md).

Verificação local de 2026-09-09: build/format .NET, **4 testes de domínio/API + 32 de integração PostgreSQL**, sem skips; contratos coincidentes (**144 ficheiros**). Web format/typecheck/lint/build, **13 Vitest simulados**, **4 E2E Identity + 16 E2E planeamento/presenças/tarefas/shell** com Chromium desktop/estreito e API/PostgreSQL reais. Os 4 novos E2E HO-006 incluem criação pelo calendário, leitura, conflito preservado em ambas as contas, contraproposta/aceitação/decisão, tarefa ligada/progresso, 412, nova autenticação conservando texto e replay após perda da resposta injetada depois do commit real.

Dart analyze e date-only body/query/response simulados em Lisbon/Zurich; Flutter analyze + **6 testes**; APK Release local (49,4 MB). Smoke real de API/DB: readiness 200 com PostgreSQL disponível; smoke gerado Dart e readiness 503 com DB deliberadamente inacessível. Configuração nativa Android validada. Nada foi silenciosamente ignorado. A evidência de UI nativa Android do último head é o check flutter-android do PR; não se afirma execução iOS/Graph.

Foi criado backup privado antes de aplicar a migração aditiva `20260909184158_OnsiteRequirementsAndTasks`; contas e planeamento anteriores conservados, sem provisionamento/reset. API local 5080 e Web 5173 mantidas para teste manual. Android continua autenticação/conectividade; interfaces de calendário/tarefas pertencem a HO-010/011.

[Checks do PR #33](https://github.com/Dennyum204/HomeOfficeReservation/pull/33/checks) é a fonte do último head e da CI remota. O PR mantém draft durante a verificação; só passa a pronto com project-docs, backend-contracts, web e flutter-android verdes nesse head, sem conflitos. O resultado de entrega fica também registado na issue #7 e na descrição do PR. Um PR aberto permanece review. Nenhum merge, auto-merge, deployment, Outlook, iOS ou entrega de notificações. Próximo item recomendado após integração humana: HO-007, ainda não iniciado.
