# Estado do projeto

Atualizado: 2026-09-09.

## Base e direção verificadas

HO-000/001/002/003 integrados e reconciliados nas entregas anteriores; histórico em [registo HO-004](docs/history/HO-004-status-before-reconciliation.md). Graph real continua adiado, não validado.

**HO-004 concluído**: [PR #30](https://github.com/Dennyum204/HomeOfficeReservation/pull/30), merge humano em main em 2026-09-09T16:50:33Z, commit `22eed41d52bf8d423f76d79fddbb7b6565486ea3`, confirmado no histórico após fetch. [Integração core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34379248170): backend-contracts, web e flutter-android passaram; [documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34379248204) passou. O job iOS restante foi cancelado por instrução de adiamento em HO-005; não se alega sucesso desse job. A evidência iOS verde do head final do PR #30 é histórica e preservada.

Direção atual do responsável: **Web e Android apenas**. iOS adiado, código/histórico mantidos, sem execução/debug nos trabalhos core e sem data. [HO-306](https://github.com/Dennyum204/HomeOfficeReservation/issues/31) regista a futura reativação, não iniciada. Proteções lidas antes/depois: apenas flutter-ios removido, quatro checks restantes/strict/PR/conversas/admins/histórico linear/proibição de force-push e eliminação preservados. Zero aprovações independentes; nenhum ruleset adicional.

## Trabalho atual

HO-005 em curso, branch `feat/ho-005-web-calendar`, [issue #6](https://github.com/Dennyum204/HomeOfficeReservation/issues/6). Calendário e workflows Web sobre a API HO-004. CI/documentação adaptadas à direção Web/Android; critérios/validação da implementação em curso. Nenhum merge, auto-merge ou deployment.

Usar PostgreSQL e contas sintéticas privados já existentes, sem reset. Android mantém autenticação/conectividade; calendário Android pertence a HO-010. Presenças/tarefas, notificações e Outlook não são implementados nesta entrega. Próximo item recomendado após HO-005 integrado: HO-006; não iniciado.
