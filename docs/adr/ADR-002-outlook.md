# ADR-002 — Identidade e sincronização Outlook

Estado: proposta, dependente de HO-001. Data: 2026-09-07.

## Contexto

Outlook pertence à primeira versão. Alterações livres num calendário não podem contornar a aprovação do chefe. O tipo de conta e políticas de IT ainda não foram confirmados.

## Decisão proposta

Assumir Microsoft 365/Exchange Online e Entra ID até validação. Aplicação é fonte das decisões; Graph publica planeamento e importa disponibilidade do calendário principal. Usar consentimento delegado do próprio utilizador, tokens no backend, outbox, delta, webhooks e reconciliação periódica.

## Alternativas

- Exportação ICS é mais simples, mas não oferece a sincronização e recuperação pretendidas; não substitui este requisito sem decisão explícita.
- Escrita/leitura arbitrária nos dois sentidos cria ambiguidades de aprovação; limitada a fluxos de divergência reconhecidos.
- Permissões application para todas as mailboxes são excessivas para a V1 de dois utilizadores.

## Consequências

É necessário validar consentimento/tenant antes do desenvolvimento principal. O utilizador pode desligar a integração mantendo o plano. Edições de eventos geridos no Outlook exigem resolução explícita. Metadados privados são reduzidos.

## Resultado esperado de HO-001

Registar tipo de conta e limitações sem segredos; demonstrar evento de teste, fluxo de identidade, delta e reconexão; atualizar este ADR para aceite ou propor alternativa com impacto no âmbito. Fonte técnica: [calendário Microsoft Graph](https://learn.microsoft.com/en-us/graph/outlook-calendar-concept-overview).
