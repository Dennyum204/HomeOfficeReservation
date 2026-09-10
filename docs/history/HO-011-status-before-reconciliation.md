# Estado do projeto

Atualizado: 2026-09-10.

HO-000 a HO-006 integrados; [estado/evidência anterior](../history/HO-010-status-before-reconciliation.md).

HO-007 concluído: [PR #34](https://github.com/Dennyum204/HomeOfficeReservation/pull/34) integrado em main em 2026-09-09T23:09:36Z, commit `aa5970de1ef97670858fe9c44be2c7dc63ed1d7d`, pertencente ao histórico remoto obtido por fetch. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34415655490) e [CI core de integração](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34415655520) concluídas: project-docs, backend-contracts, web e flutter-android verdes. Ensaio FCM real mantém a evidência e limitações do [guia HO-007](../HO-007-NOTIFICATIONS.md).

HO-010 em revisão no [PR #35](https://github.com/Dennyum204/HomeOfficeReservation/pull/35), branch `feat/ho-010-android-calendar-requests`, [issue #11](https://github.com/Dennyum204/HomeOfficeReservation/issues/11). Dependências HO-004/005/007 integradas e verificadas. Calendário/pedidos/decisões Android, recuperação e navegação de notificações implementados; [matriz de aceitação, resultados e capturas](../HO-010-ANDROID-PLANNING.md).

Validação local: 25 testes Flutter, 4 unitários e 47 PostgreSQL, contratos sem drift, percurso Android cinco/três/dois, Web → Android → Web, DST nativo Lisboa/Zurique e FCM foreground real. A primeira CI falhou num teste antigo de autenticação que procurava diagnósticos no calendário; agora abre Definições, sem remover asserções. O PR regista os quatro resultados remotos e SHA finais; permanece draft até todos passarem e não haver conflitos. `review` não significa integrado.

Contratos e regras existentes reutilizados. Dados, contas, PostgreSQL e configuração Firebase privada preservados. HO-011, iOS, Outlook, deployment e distribuição fora do âmbito. Sem merge/auto-merge.
