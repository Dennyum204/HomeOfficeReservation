# Estado do projeto

Atualizado: 2026-09-10.

HO-000 a HO-005 integrados; [evidência anterior](docs/history/HO-006-status-before-reconciliation.md).

HO-006: [PR #33](https://github.com/Dennyum204/HomeOfficeReservation/pull/33) integrado em main por humano em 2026-09-09T20:10:44Z, commit `73dc2f2337eeee30b228d63e8ae6fcd0fc4641d4`, pertencente ao histórico obtido por fetch. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34399468093) e backend/Web verdes; [CI core de integração](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34399468040) concluída com os quatro checks verdes. HO-006 concluído.

HO-007 na branch `feat/ho-007-notifications`, [issue #8](https://github.com/Dennyum204/HomeOfficeReservation/issues/8). Dependências HO-004/005/006 integradas/verificadas. [PR #34](https://github.com/Dennyum204/HomeOfficeReservation/pull/34), estado canónico review até merge humano e integração verificada. Implementação interna e ensaio FCM real concluídos no emulador autorizado; a PR só sai de draft após CI do último head verde e ausência de conflitos. [Guia de configuração, duas contas, evidência e recuperação](docs/HO-007-NOTIFICATIONS.md), [ADR-009](docs/adr/ADR-009-durable-notifications.md), [correção Android ADR-010](docs/adr/ADR-010-android-fcm-registration.md).

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

## Correção Android e validação adicional — 2026-09-10

O responsável criou o projeto de teste e concedeu permissão Android. Configurações/credencial reais permanecem fora do repositório. O ensaio identificou e corrigiu o listener Installations fora da thread principal, o registo FID incompleto e o auto-init bloqueante no arranque normal. A ponte usa APIs oficiais de Messaging/Installations numa fila Flutter de background e callbacks na thread principal. Erro de registo permite tentar novamente sem desativar a opção de alertas.

- **FCM real**: foreground, background e cold start observados, com aceitação do fornecedor e recibo autenticado separados. Notificação genérica abre detalhe autorizado, sem decisão nem marcação automática de leitura. Nova entrega após reinício/reconexão também confirmada; primeira tentativa `UNREGISTERED` permanece registada como falha, com inbox preservada.
- `fcm_live_test.dart`: ensaio nativo opcional passou contra Firebase/API/PostgreSQL — remoção, UUID revogado recusado, reconexão, logout, troca colaborador/chefia, acesso cruzado negado e regresso ao colaborador. O teste usa o arranque normal e permissão previamente concedida; não faz parte da CI core. O runner local usa `--keep-app-running` e a app normal é reinstalada no fim.
- `flutter pub get --enforce-lockfile`, Dart format, analyze sem issues e **14 testes** passaram, incluindo falha/repetição de registo, rotação e deduplicação de callbacks simuladas. Recursos nativos, builds Android e documentação verificados novamente após a correção. Contratos/API/Web não foram alterados nesta correção.

Recusa de permissão, logout offline, falhas/crashes e callbacks atrasados permanecem evidência simulada/testes PostgreSQL, claramente separados da entrega externa. Sem validação em dispositivo físico, loja/assinatura release, fabricante/bateria ou rede de produção. Aviso de migração futura Kotlin do plugin firebase_core permanece documentado. Não há setup externo em falta para o ensaio HO-007 descrito.

CI exigida no head final: `project-docs`, `backend-contracts`, `web`, `flutter-android`; SHA e resultados reais no separador Checks e descrição da PR. Sem integração presumida por existir uma PR. Nenhum gate iOS/Outlook. Próximo item recomendado: **HO-010 — Calendário e pedidos Android**, após revisão/merge de HO-007 e verificação de integração; não iniciado.

Contas e dados locais preservados. Outlook/email de produto/iOS fora do âmbito. Sem merge, auto-merge, deployment ou outro item iniciado.
