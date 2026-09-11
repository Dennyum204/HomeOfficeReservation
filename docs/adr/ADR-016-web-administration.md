# ADR-016 — Administração Web e concorrência de acesso

Data: 2026-09-11. HO-015. Complementa ADR-014/015; preserva os contratos legados e as decisões Identity. Este número de ADR não é a tarefa visual HO-016.

## Decisão

Usar a lista paginada de convites como projeção administrativa de membros, ativação/entrega e chefia. A API continua autoritativa. A Web usa clientes gerados e diálogos nativos já existentes, com foco inicial/devolução, Escape, labels explícitos e largura adaptável. Não acrescentar biblioteca de estado, identidade ou design system.

Adicionar versão de acesso no Member, incrementada com a auditoria de alterações de papéis/estado/chefia, incluindo operador e cancelamento. A versão do convite mantém a sua finalidade. O lock de organização de HO-013 evita alterações concorrentes entre a verificação da versão e commit. Os PUT administrativos aceitam versão esperada e UUID de comando emparelhados; ambos obrigatórios na Web, opcionais em conjunto para compatibilidade com operadores existentes. Remoção explícita de chefia usa managerId nulo.

Reutilizar a persistência de recibos HO-014, vinculando o corpo normalizado por hash SHA-256 na operação de papéis/chefia. Não é criptografia de autenticação. Recibo exato devolve confirmação sem reaplicar, após revalidar administrador/organização. A UI recupera o mesmo envelope guardado por conta em sessionStorage e consulta o estado atual; não infere aceitação a partir da entrega. Os endpoints não devolvem códigos.

## Alternativas e consequências

Manter PUT sem versão permitiria perder uma edição administrativa. Inferir sucesso apenas por leitura permitiria confundir uma operação alheia com a intenção original. Uma tabela/outbox de administração nova é desnecessária: os efeitos externos de convites já pertencem à infraestrutura durável de HO-014. A associação e papéis não exigem email.

Migração apenas aditiva/alargamento. Operadores legados preservados, com garantia de concorrência limitada explicitamente documentada. Sem endpoint público de elevação, sem módulo de várias organizações, sem administração Android. [Guia e evidência](../HO-015-WEB-ADMINISTRATION.md).

Complemento de verificação HO-015: a CI Android revelou uma recusa ao guardar um rascunho. A janela de expiração após preflight foi reproduzida. O repository de planeamento passa a permitir uma repetição limitada após HTTP 401 explícito, com nova leitura autenticada e confirmação da mesma sessão/ator, reutilizando o corpo e chave imutáveis. Isto complementa a recuperação de ADR-011; 403 e resultados incertos continuam sem repetição automática. A CI força essa janela com atraso de transporte, tokens curtos inalterados e PostgreSQL real. Não cria protocolo de autenticação nem muda a autoridade do servidor.

Fontes oficiais consultadas em 2026-09-11: [EF Core — concurrency](https://learn.microsoft.com/en-us/ef/core/saving/concurrency) para comparação de versão e conflitos; o projeto aplica essa comparação sob o lock transacional já existente. [W3C — modal dialog](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/) e [HTML dialog/foco](https://www.w3.org/WAI/WCAG21/Techniques/html/H102) para o diálogo nativo e navegação por teclado.
