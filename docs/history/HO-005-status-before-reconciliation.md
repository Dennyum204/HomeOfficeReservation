# Registo histórico HO-005

Estado corrente em [STATUS](../../STATUS.md). Texto anterior preservado.

# Estado do projeto

Atualizado: 2026-09-09.

## Base e direção verificadas

HO-000/001/002/003 integrados e reconciliados nas entregas anteriores; histórico em [registo HO-004](../history/HO-004-status-before-reconciliation.md). Graph real continua adiado, não validado.

**HO-004 concluído**: [PR #30](https://github.com/Dennyum204/HomeOfficeReservation/pull/30), merge humano em main em 2026-09-09T16:50:33Z, commit `22eed41d52bf8d423f76d79fddbb7b6565486ea3`, confirmado no histórico após fetch. [Integração core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34379248170): backend-contracts, web e flutter-android passaram; [documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34379248204) passou. O job iOS restante foi cancelado por instrução de adiamento em HO-005; não se alega sucesso desse job. A evidência iOS verde do head final do PR #30 é histórica e preservada.

Direção atual do responsável: **Web e Android apenas**. iOS adiado, código/histórico mantidos, sem execução/debug nos trabalhos core e sem data. [HO-306](https://github.com/Dennyum204/HomeOfficeReservation/issues/31) regista a futura reativação, não iniciada. Proteções lidas antes/depois: apenas flutter-ios removido, quatro checks restantes/strict/PR/conversas/admins/histórico linear/proibição de force-push e eliminação preservados. Zero aprovações independentes; nenhum ruleset adicional.

## Trabalho atual

**HO-005 em revisão**, branch `feat/ho-005-web-calendar`, [PR #32](https://github.com/Dennyum204/HomeOfficeReservation/pull/32), [issue #6](https://github.com/Dennyum204/HomeOfficeReservation/issues/6) aberta até integração humana. Calendário mês/semana e workflows Web reais: rascunhos, seleção/intervalos, aprovação/rejeição parcial, retirada, revisões/cancelamento, contrapropostas, disponibilidade manual e comentários/histórico. [Guia e limitações](../HO-005-WEB.md), [ADR-007](../adr/ADR-007-web-planning-and-active-platforms.md), [capturas reais](../evidence/ho-005/README.md).

Verificação local de 2026-09-09: build/format .NET; **4 API + 20 PostgreSQL**, sem skips; contratos regenerados sem diferenças (**110 ficheiros**); Web format/typecheck/lint/build, **13 Vitest** simulados; **4 E2E de Identity + 12 E2E de planeamento/shell** com Chromium desktop/estreito e API/PostgreSQL reais. E2E cobre 5→3+2→retirada dos 2, revisão preservando aprovação até decisão, 412 real/texto conservado, 409 manual, 403, contraproposta/cancelamento/rejeição e teclado. Perda da resposta é injetada após commit real; replay não duplica o efeito.

Dart analyze; Flutter analyze + **6 testes**; APK Release compilado localmente (49,2 MB, sem deployment). Smoke real de startup/workspace/cliente Dart: readiness 200 com PostgreSQL disponível e 503 com base deliberadamente inacessível. Validador documental: 24 funcionalidades, 25 itens. Scan de credenciais privadas sem correspondências versionadas. Não houve validação iOS/Graph nem auditoria completa com leitores de ecrã.

O PR começa draft durante a CI remota. A evidência do **último head** e o estado pronto/draft ficam no [PR #32](https://github.com/Dennyum204/HomeOfficeReservation/pull/32): retirar draft só com os quatro checks verdes e sem conflitos. Um PR aberto permanece `review`; a próxima tarefa deve verificar merge/integration e reconciliar. Nenhum merge, auto-merge ou deployment.

Usar PostgreSQL e contas sintéticas privados já existentes, sem reset. Android mantém autenticação/conectividade; calendário Android pertence a HO-010. Presenças/tarefas, notificações e Outlook não são implementados nesta entrega. Próximo item recomendado após HO-005 integrado: HO-006; não iniciado.
