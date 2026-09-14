# Instalação Android privada

HO-017 selecionada para instalação USB no telemóvel do responsável, ligada ao piloto HTTPS. Ícone baseado no monograma da Web; assinatura privada. Não equivale a validação de todos os percursos físicos ou push. [Procedimento](docs/HO-017-PHONE.md).

HO-021 integrada por PR #52, bda687c, com quatro checks de integração verdes (34790177193/34790177165). Histórico abaixo preservado.

# Estado do projeto

Atualizado: 2026-09-14.

HO-021 em `review`, [PR #52](https://github.com/Dennyum204/HomeOfficeReservation/pull/52), [issue #50](https://github.com/Dennyum204/HomeOfficeReservation/issues/50): PT/EN/DE na Web e Android, preferência persistente por dispositivo e formatos regionais. [Implementação e limites](docs/HO-021-LANGUAGES-PLAN.md), [34 capturas reais](docs/evidence/ho021/README.md). Verificação local: 18 unitários Web, 58 Flutter, 36 E2E existentes e 4 de idiomas; ensaio nativo com 18 capturas; 178 contratos sem divergência. Os quatro checks remotos do head final e ausência de conflitos são obrigatórios antes de retirar draft. Emails/push do servidor continuam em português; os eventos da caixa de notificações são traduzidos. Sem deployment.

HO-020 concluída por merge humano do [PR #51](https://github.com/Dennyum204/HomeOfficeReservation/pull/51), commit `e00bd1c3eb5b638a4e8dab35378ee47fd16ad8e0`, confirmado na história de origin/main. Aceitação manual comunicada pelo responsável; os quatro checks de integração passaram nos runs [34784701259](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34784701259) e [34784701252](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34784701252). [Evidência HO-020](docs/HO-020-UI-NOTIFICATIONS.md).

HO-016 concluída por merge humano do PR #45 em main (`f07c3dd7185743c62f5c47d15c4b8a5198d92cbb`) e CI de integração verificados. PR #37, piloto Pi, configuração privada e ambientes habituais preservados. O estado operacional mais recente de HO-012 permanece na sua branch, não no histórico abaixo.

## Evidência anterior

# Estado do projeto

Atualizado: 2026-09-11.

HO-016 em `review`, [PR #45](https://github.com/Dennyum204/HomeOfficeReservation/pull/45), issue #41, branch `codex/ho-016-claude-visual-theme`, worktree separado de `origin/main` atualizado. [Histórico anterior](docs/history/HO-016-status-before-reconciliation.md).

HO-015 concluída: teste manual aprovado pelo responsável e merge humano do [PR #44](https://github.com/Dennyum204/HomeOfficeReservation/pull/44) em 2026-09-11T11:00:36Z. Commit `dcda6e2cceef570b3f8ab6dc5d5905d6af6212ec` confirmado por fetch/ancestralidade. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34591956785) e [integração core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34591956766) passaram: project-docs, backend-contracts, web e flutter-android. Dependência HO-011 já integrada e evidência preservada no backlog.

HO-016 adapta Claude + à Web/Android e verifica hierarquia, contraste, acessibilidade e regressão funcional. Ambiente sintético separado; contas, configuração privada, bases e emuladores habituais preservados. Evidência visual concluída: [84 capturas reais](docs/evidence/ho016/README.md). Backend 73 testes e 178 contratos sem divergência; Web 38 E2E; Android 51 testes e 14 capturas reais passaram localmente. Os [checks remotos do PR](https://github.com/Dennyum204/HomeOfficeReservation/pull/45/checks) são a fonte da verificação do head final. A entrega só fica pronta após project-docs, backend-contracts, web e flutter-android verdes e ausência de conflitos; HO-016 continua review até merge humano.

HO-012 continua incompleta no [PR draft #37](https://github.com/Dennyum204/HomeOfficeReservation/pull/37), sem alterações. NAS DS218+, Celeron J3355, 2 GB, Docker: apenas conectividade Cloudflare Tunnel reportada; aplicação não instalada nem medida. Sem alojamento contratado, deployment, DNS, emails reais, distribuição, merge ou auto-merge. Administração Android, iOS e Outlook continuam adiados.

Refinamento solicitado no mesmo PR #45: painel de conta e AppBar Android removidos; títulos acompanham o scroll, com colaborador contextual e Conta e sessão em Definições. Scroll por conta evita herdar a posição de outra identidade. Web e contratos inalterados. Análise/format e 52 testes Flutter passaram; ensaio com API/PostgreSQL reais verificou ações de sessão/troca de conta e exportou [26 novas capturas claro/escuro](docs/evidence/ho016/android-header/README.md). A entrega revista exige os quatro checks remotos novamente verdes no head final; PR/issue continuam em revisão até merge humano.
