# Registo histórico HO-004 — anterior à reconciliação

O estado/CI corrente encontra-se em [STATUS](../../STATUS.md). Texto abaixo preservado, não é o estado atual.

# Estado do projeto

Atualizado: 2026-09-09.

## Integração verificada

- HO-000: PR #25, merge humano `7257a7b0c88f456b4322da396d45bd4c0aa0e862`; [CI](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34264376475) verde.
- HO-001: PR #27, merge humano `7f783bf9bde5a72ac8271c42cc2916b054170d17`; [CI](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34272493270) verde. Âmbito documental concluído; Graph real adiado, não validado. Outlook permanece opcional e onboarding parado.
- HO-002: PR #28, merge humano `2fb0f416193ef37ac79c18fd0dcae00f0b80494d`; [CI core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34281298897) e [documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34281298848) verdes, iOS após repetição isolada.
- **HO-003 concluído e reconciliado em HO-004**: [PR #29](https://github.com/Dennyum204/HomeOfficeReservation/pull/29) integrado em main às 2026-09-09T14:50:29Z, commit `95027c7b8795b5b4f55e817633fe9521c32fd9ab`, confirmado como antepassado após fetch. [CI core de integração](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34366275543) e [documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34366275654) verdes, incluindo Android/iOS nativos e builds. O [estado histórico anterior](../history/HO-003-status-before-reconciliation.md) conserva as tentativas antigas; não confundir falhas anteriores com o resultado deste merge.

## Trabalho atual

**HO-004 em review**, [PR #30](https://github.com/Dennyum204/HomeOfficeReservation/pull/30) em draft até CI final verde, branch `feat/ho-004-planning-approvals`, [issue #5](https://github.com/Dennyum204/HomeOfficeReservation/issues/5). Planeamento transacional na API, padrão por vigência, pedidos/revisões/contrapropostas, decisões parciais, comentários, auditoria/outbox e idempotência. [Guia local](../HO-004-PLANNING.md), [ADR-006](../adr/ADR-006-transactional-planning.md).

Migração aditiva `20260909151115_TransactionalPlanning` aplicada à base local existente, sem alteração de contas/passwords. Verificação local: build backend e 4 testes API/domínio + 19 integrações PostgreSQL reais passaram; incluem corridas com conexões distintas, rollback com trigger de falha, revisões/contrapropostas e autorização HTTP. Cliente Dart gerado passou análise e ensaio de datas body/query/response com transporte simulado. Web: format/typecheck/lint/build, 8 testes simulados incluindo três zonas para o contrato de datas e 8 E2E reais com API/PostgreSQL, incluindo login e expiração. Flutter: análise e 6 testes simulados. Contratos regenerados sem divergência; documentação e configuração nativa verificadas. Seis testes Python do runner iOS preservados e verdes.

Demonstração HTTP real em 2026-09-09, com contas sintéticas privadas existentes: três dias submetidos, dois aprovados parcialmente, um retirado; revisão do primeiro manteve a aprovação remota até decisão final. Resultado sintético: 2026-10-09 presencial confirmado, 2026-10-12 remoto confirmado e 2026-10-13 apenas padrão inferido. Segunda execução reutilizou recibos locais sem novos comandos. API voltou a correr em 5080, readiness Healthy com PostgreSQL real. Os resultados do SHA final são registados no [PR #30/checks](https://github.com/Dennyum204/HomeOfficeReservation/pull/30/checks) e no relatório de entrega do PR. O draft só é retirado com os cinco checks verdes, critérios satisfeitos e ausência de conflitos; a CI estava pendente quando este registo foi escrito.

Revisão final: um teste HTTP com elemento nulo na seleção reproduziu HTTP 500. A validação passou a recusar elementos nulos em seleções/rascunhos com 400; o teste PostgreSQL/HTTP passou depois da correção e confirma que plano/auditoria/outbox/recibos/versão não mudam. Backend/Web/documentação do commit anterior `6ed987e` estavam verdes; a CI completa do novo SHA continua obrigatória, sem contar resultados antigos como aprovação final.

Não foi implementada UI de calendário, presenças, tarefas ou entrega de notificações. Outbox tem mensagens duráveis com DeliveredAt nulo. A corrida aprovação/presença pertence a HO-006 e não foi executada com tabelas fictícias. Web/Flutter mantêm autenticação e shell de HO-003. Docker ausente neste Windows; PostgreSQL 18.6 portátil real disponível. iOS só pode ser validado no macOS CI, não neste Windows.

Proteções main previamente verificadas: PR e cinco checks (`project-docs`, `backend-contracts`, `web`, `flutter-android`, `flutter-ios`), strict, conversas resolvidas, histórico linear/admins, zero aprovações independentes obrigatórias, sem force-push/deletion. Nenhum merge, auto-merge ou deployment pelo Codex.

## Continuidade e limites

Entregar HO-004 em PR sem draft apenas com todos os critérios aplicáveis satisfeitos, cinco checks verdes no último SHA e ausência de conflitos. Estado canónico `review` até merge humano e integração verificada. O próximo item é **HO-005 — calendário Web e interface de aprovação**; não foi iniciado.

SMTP real, alojamento/TLS/proxy, dispositivos físicos, assinatura/lojas, piloto, notificações e Graph não foram validados nesta entrega. Não existem credenciais ou dados privados de calendário no repositório público.
