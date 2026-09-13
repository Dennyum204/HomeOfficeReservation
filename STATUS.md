# Estado do projeto

HO-020 em `review`, [PR #51](https://github.com/Dennyum204/HomeOfficeReservation/pull/51): UI e leitura automática de notificações, [issue #49](https://github.com/Dennyum204/HomeOfficeReservation/issues/49). Branch `codex/ho-020-ui-notifications`, worktree separado. [Implementação e verificação](docs/HO-020-UI-NOTIFICATIONS.md), [comparações reais](docs/evidence/ho020/README.md). 73 testes backend/PostgreSQL, 54 Flutter, 36 E2E Web passaram localmente; capturas reais em claro/escuro, desktop, viewport estreito e Android. A entrega só fica pronta após os quatro checks remotos no head final e ausência de conflitos.

HO-016 concluída: merge humano do PR #45 em main (`f07c3dd7185743c62f5c47d15c4b8a5198d92cbb`) e CI de integração verificados. HO-021/issue #50 e [PR #52 draft documental](https://github.com/Dennyum204/HomeOfficeReservation/pull/52) registam o âmbito completo de idiomas, sem implementação antes da revisão de HO-020. PR #37 e piloto Pi preservados; o estado operacional mais recente de HO-012 permanece na sua branch, não no histórico abaixo.

## Evidência anterior

# Estado do projeto

Atualizado: 2026-09-11.

HO-016 em `review`, [PR #45](https://github.com/Dennyum204/HomeOfficeReservation/pull/45), issue #41, branch `codex/ho-016-claude-visual-theme`, worktree separado de `origin/main` atualizado. [Histórico anterior](docs/history/HO-016-status-before-reconciliation.md).

HO-015 concluída: teste manual aprovado pelo responsável e merge humano do [PR #44](https://github.com/Dennyum204/HomeOfficeReservation/pull/44) em 2026-09-11T11:00:36Z. Commit `dcda6e2cceef570b3f8ab6dc5d5905d6af6212ec` confirmado por fetch/ancestralidade. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34591956785) e [integração core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34591956766) passaram: project-docs, backend-contracts, web e flutter-android. Dependência HO-011 já integrada e evidência preservada no backlog.

HO-016 adapta Claude + à Web/Android e verifica hierarquia, contraste, acessibilidade e regressão funcional. Ambiente sintético separado; contas, configuração privada, bases e emuladores habituais preservados. Evidência visual concluída: [84 capturas reais](docs/evidence/ho016/README.md). Backend 73 testes e 178 contratos sem divergência; Web 38 E2E; Android 51 testes e 14 capturas reais passaram localmente. Os [checks remotos do PR](https://github.com/Dennyum204/HomeOfficeReservation/pull/45/checks) são a fonte da verificação do head final. A entrega só fica pronta após project-docs, backend-contracts, web e flutter-android verdes e ausência de conflitos; HO-016 continua review até merge humano.

HO-012 continua incompleta no [PR draft #37](https://github.com/Dennyum204/HomeOfficeReservation/pull/37), sem alterações. NAS DS218+, Celeron J3355, 2 GB, Docker: apenas conectividade Cloudflare Tunnel reportada; aplicação não instalada nem medida. Sem alojamento contratado, deployment, DNS, emails reais, distribuição, merge ou auto-merge. Administração Android, iOS e Outlook continuam adiados.

Refinamento solicitado no mesmo PR #45: painel de conta e AppBar Android removidos; títulos acompanham o scroll, com colaborador contextual e Conta e sessão em Definições. Scroll por conta evita herdar a posição de outra identidade. Web e contratos inalterados. Análise/format e 52 testes Flutter passaram; ensaio com API/PostgreSQL reais verificou ações de sessão/troca de conta e exportou [26 novas capturas claro/escuro](docs/evidence/ho016/android-header/README.md). A entrega revista exige os quatro checks remotos novamente verdes no head final; PR/issue continuam em revisão até merge humano.
