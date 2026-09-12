# HO-012 — Reconciliação de integração em 2026-09-11

Fetch de origin/main e gh pr view confirmaram MERGED, base main e cada merge como ancestral de f07c3dd7185743c62f5c47d15c4b8a5198d92cbb. Issues fechadas, por si, não foram usadas como prova.

| Item | Merge humano | SHA | Documentação | Core integrado |
|---|---|---|---|---|
| HO-013 | [PR #42](https://github.com/Dennyum204/HomeOfficeReservation/pull/42) | `f62408eaab4bd47bdf039d53b210a7798fc76dc3` | [verde](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34539320219) | [3 checks verdes](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34539320227) |
| HO-014 | [PR #43](https://github.com/Dennyum204/HomeOfficeReservation/pull/43) | `e12d5ccafaa8a2e336743eacf6f2b1ef5a1ee8e9` | [verde](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34576735019) | [3 checks verdes](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34576735065) |
| HO-015 | [PR #44](https://github.com/Dennyum204/HomeOfficeReservation/pull/44) | `dcda6e2cceef570b3f8ab6dc5d5905d6af6212ec` | [verde](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34591956785) | [3 checks verdes](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34591956766) |
| HO-016 | [PR #45](https://github.com/Dennyum204/HomeOfficeReservation/pull/45) | `f07c3dd7185743c62f5c47d15c4b8a5198d92cbb` | [verde](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34605827077) | [3 checks verdes](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34605827090) |

Em todos: project-docs, backend-contracts, web e flutter-android success. O Android de HO-013 tem o retry histórico preservado no guia da tarefa; não se substitui CI remota por execução local. HO-016 concluiu a integração durante esta sessão. iOS/Outlook adiados.

Os estados done significam implementação integrada e testes manuais aprovados pelo responsável, não deployment ou ensaio NAS. PR #37 continua draft e HO-012 review/incompleta. [Estado anterior](history/HO-012-resume-before-reconciliation.md).
