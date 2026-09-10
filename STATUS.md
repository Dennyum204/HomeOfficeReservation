# Estado do projeto

Atualizado: 2026-09-10.

HO-000 a HO-006 integrados; [estado/evidência anterior](docs/history/HO-010-status-before-reconciliation.md).

HO-007 concluído: [PR #34](https://github.com/Dennyum204/HomeOfficeReservation/pull/34) integrado em main em 2026-09-09T23:09:36Z, commit `aa5970de1ef97670858fe9c44be2c7dc63ed1d7d`, pertencente ao histórico remoto obtido por fetch. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34415655490) e [CI core de integração](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34415655520) concluídas: project-docs, backend-contracts, web e flutter-android verdes. Ensaio FCM real mantém a evidência e limitações do [guia HO-007](docs/HO-007-NOTIFICATIONS.md).

HO-010 em implementação na branch `feat/ho-010-android-calendar-requests`, [issue #11](https://github.com/Dennyum204/HomeOfficeReservation/issues/11). Dependências HO-004/005/007 integradas e verificadas. Âmbito: calendário/pedidos/decisões Android, recuperação e ligação das notificações ao pedido autorizado. Critérios finais ainda não verificados; nenhuma PR pronta presumida.

Contratos e regras existentes reutilizados. Dados, contas, PostgreSQL e configuração Firebase privada preservados. HO-011, iOS, Outlook, deployment e distribuição fora do âmbito. Sem merge/auto-merge.
