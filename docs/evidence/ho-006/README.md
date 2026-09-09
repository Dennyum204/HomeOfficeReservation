# Evidência Web HO-006

Capturas em 2026-09-09 de Chromium/React, API ASP.NET Core e PostgreSQL reais, com contas e datas sintéticas. Os ensaios procuram datas livres e preservam dados existentes. Não existem credenciais, tokens ou dados Outlook nestas imagens. O histórico inclui ensaios anteriores preservados.

| Vista | Desktop | Ecrã estreito |
|---|---|---|
| Colaborador: remoto confirmado + presença por resolver | [Captura](desktop-employee-conflict.png) | [Captura](small-screen-employee-conflict.png) |
| Gestor: mesma aprovação preservada e conflito | [Captura](desktop-manager-conflict.png) | [Captura](small-screen-manager-conflict.png) |
| Tarefa ligada e progresso do colaborador | [Captura](desktop-task.png) | [Captura](small-screen-task.png) |
| Resolução proposta, distinta de leitura | — | [Diálogo utilizável](small-screen-resolution-dialog.png) |

Foi corrigido o overflow causado por cinco separadores na navegação estreita; as ações do diálogo funcionam sem clicks forçados. Testes usam a largura real do documento, teclado/controlos nativos e interações Playwright. Capturas foram inspecionadas visualmente. Isto não é uma auditoria completa com leitores de ecrã nem evidência de UI Android/iOS.

O percurso também verifica 412 real com texto conservado, interrupção real da sessão por logout da API e nova autenticação, e perda de resposta injetada depois de um commit PostgreSQL real. Apenas a perda de transporte é simulada; o replay usa a mesma chave/payload e confirma uma única presença persistida.

Resultados e limites: [guia HO-006](../../HO-006-ONSITE-TASKS.md) e [STATUS](../../../STATUS.md). Eventos persistidos na outbox; nenhuma notificação entregue. Nenhum acesso Microsoft/Graph foi usado.
