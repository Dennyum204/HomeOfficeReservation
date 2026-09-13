# ADR-022 — Prazos externos para backups e integridade

2026-09-13. Estado: integração preparada; fornecedor/destinatário e ativação aguardam aprovação. Complementa ADR-021, preservando prova manual e ausência de disparo agendado observado.

Um logger no Pi não avisa quando este está desligado. Propõe-se Healthchecks.io alojado Hobbyist, três checks (daily, weekly, rehearsal) e email a escolher. Sem infraestrutura própria nem PC como monitor. Agendas UTC iguais aos timers; grace 3 h/5 h cobre jitter/limites dos jobs. POST vazio; URLs root-only. [Runbook, custo e condições](../HO-012-BACKUP-MONITORING.md).

Hooks systemd deixam o backup correr se start não chegar; success exige etapas completas e recibo novo; fail usa OnFailure separado. Falha de envio não apaga prova técnica; ausência expira no fornecedor. Checks e recibos de falha independentes. Rehearsal testa ausência/falha/recuperação sem interromper jobs ou fingir sucesso real. Simulações não validam serviço externo; execução manual não valida timer.

Sem conta/alerta antes de aprovação e destinatário escolhido. Não se promete SLA gratuito. Integridade do repositório cabe ao restic; o monitor apenas recebe sinais e deteta prazos. Recuperar ou reemitir URLs pelo kit privado após perda total do Pi.
