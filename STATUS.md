# Estado do projeto

Atualizado: 2026-09-09.

HO-000 a HO-005 integrados; [evidência anterior](docs/history/HO-006-status-before-reconciliation.md).

HO-006: [PR #33](https://github.com/Dennyum204/HomeOfficeReservation/pull/33) integrado em main por humano em 2026-09-09T20:10:44Z, commit `73dc2f2337eeee30b228d63e8ae6fcd0fc4641d4`, pertencente ao histórico obtido por fetch. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34399468093) e backend/Web verdes; [CI core de integração](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34399468040) concluída com os quatro checks verdes. HO-006 concluído.

HO-007 na branch `feat/ho-007-notifications`, [issue #8](https://github.com/Dennyum204/HomeOfficeReservation/issues/8). Dependências HO-004/005/006 integradas/verificadas. Implementação interna concluída e preparação de PR draft; entrega FCM real pendente. [Guia de configuração, duas contas e recuperação](docs/HO-007-NOTIFICATIONS.md), [ADR-009](docs/adr/ADR-009-durable-notifications.md).

Worker PostgreSQL durável, claims/leases/retries, deduplicação, commit inbox/intenção/outbox, histórico sem alertas antigos, APIs autorizadas e caixas Web/Android funcionam sem credenciais externas. Web abre o contexto atual. Android mostra detalhe e referência com fallback honesto para a Web; calendário/tarefas completos continuam HO-010/011. FCM Admin/FlutterFire implementados; simulação local e entrega real são estados diferentes.

## Validação local executada — 2026-09-09

- `check_project.py --write`/validador, `check_native_config.py`, restore .NET locked, `dotnet format --verify-no-changes`, builds Debug/Release sem erros/avisos .NET.
- `dotnet test apps/api/HomeOffice.slnx --no-build --logger trx`: **4 testes API + 46 PostgreSQL**, zero falhas/skip. Inclui 14 testes novos de worker/notificações/migração: concorrência, crashes, dedupe, atomicidade, destinatários, retry, leases, dispositivo/revogação, leitura e histórico. PostgreSQL real em bases descartáveis; não alteram as contas locais.
- `generate_contracts.py --check`: **172 ficheiros gerados coincidem**, OpenAPI e clientes TypeScript/Dart.
- Web: format/typecheck/lint/build, **13 testes unitários + 22 E2E** (4 autenticação, 18 workflows/shell em desktop/ecrã estreito). API/worker/PostgreSQL reais; capturas sintéticas em `apps/web/test-results`, sem credenciais. Testes de notificações verificam pedido→chefia, decisão→colaborador, presenças/tarefas, contexto e leitura sem decisão.
- Flutter: analyze sem issues e **11 testes**, incluindo simulações de recusa, rotação, logout offline, registo atrasado e limpeza de estado. Android debug e release unsigned compilados.
- **Android Emulator API 37**: teste nativo de autenticação/restauro/expiração/logout e teste novo de inbox contra API/worker/PostgreSQL passaram, usando contas sintéticas privadas. Teste de expiração pausa atividade Android da caixa; iOS não foi executado nem alterado.
- `check_fcm_build.py`: recursos nativos FCM compilam com configuração inventada temporária fora do repo; **não instalado, sem envio**. Não prova configuração de projeto real nem receção FCM.
- `smoke_api.py --database`, sem DB e `--dart-client`: arranque/API reais, readiness **200 com DB e 503 sem DB**, cliente Dart real. Windows usa PostgreSQL portátil; Compose fica na CI.

## Gate externo e continuidade

**Não houve envio/aceitação/receção FCM real.** Falta projeto Firebase de teste autorizado, app Android com package `dev.homeoffice.homeoffice_mobile`, API FCM V1/credencial ADC autorizada, ficheiro Android externo correspondente e seleção/consentimento de dispositivo Google Play services. Depois: observar foreground/background/cold start, sessão, recusa, rotação/reconexão e logout/troca de conta; guardar apenas evidência sanitizada. Setup guiado um passo de cada vez; não pedir chaves no chat. Issue #8 aberta e PR draft até satisfazer o gate. Avisos atuais de migração Kotlin em plugins Firebase são documentados; compilação passou. Sem loja/assinatura/dispositivo físico validado.

CI exigida no head final: `project-docs`, `backend-contracts`, `web`, `flutter-android`; resultados e links reais na PR. Nenhum gate iOS/Outlook. Próximo item recomendado: **HO-010 — Calendário e pedidos Android**, apenas após tratar o gate/revisão/merge de HO-007 e verificar integração; não iniciado.

Contas e dados locais preservados. Outlook/email de produto/iOS fora do âmbito. Sem merge, auto-merge, deployment ou outro item iniciado.
