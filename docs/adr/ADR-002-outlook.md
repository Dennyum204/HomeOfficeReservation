# ADR-002 — Identidade e sincronização Outlook

Estado atual: proposta detalhada, bloqueada em validação real de HO-001 (2026-09-08). Proposta original: 2026-09-07, preservada abaixo.

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

## Revisão HO-001 — 2026-09-08

O [estudo e fontes datadas](../HO-001-MICROSOFT-OUTLOOK-STUDY.md) revê a proposta original após confirmação explícita de Fernando: **o alvo é Outlook.com pessoal (MSA)**. O endereço indicado fica privado; registo e consentimento ainda não estão preparados. A hipótese Microsoft 365 empresarial é substituída, mantendo-se acima como histórico. Escolher audiência pessoal e authority consumers; não confundir diretório do registo com tenant da mailbox. A admissão dos membros e papéis fica na aplicação; a conta do gestor ainda precisa de confirmação. [Microsoft: account types e limites](https://learn.microsoft.com/en-us/entra/identity-platform/supported-accounts-validation), consultado em 2026-09-08.

Decisões de desenho propostas, sem aplicação implementada:

- Separar registos API/BFF, Flutter público e conector confidencial. Login Web por BFF/cookie; mobile com code + PKCE pede token da nossa API; conector obtém consentimento delegado Graph apenas quando o utilizador liga calendário. Não usar ID token ou Graph token na API. Vincular consentimento a `(tid, oid)` da sessão/membro.
- Flutter: `flutter_appauth`/AppAuth com browser do sistema e armazenamento seguro é o caminho concreto para OIDC comum. Caso IT exija broker/Intune, avaliar ponte nativa MSAL Android/iOS e respetivo SDK; AppAuth não prova esse suporte. Viabilidade ainda condicionada às políticas e a ensaio nos dispositivos. [Mantenedor Flutter AppAuth](https://pub.dev/packages/flutter_appauth), [Microsoft broker](https://learn.microsoft.com/en-us/entra/identity-platform/mobile-sso-support-overview), consultados em 2026-09-08.
- Cache MSAL delegada persistente e cifrada no backend, chave fora da base de dados; renovar com a biblioteca. Consentimento inválido/interação exigida suspende sync e pede reconexão. Logout não prova revogação. Calendars.ReadWrite delegado é mais amplo do que eventos próprios; consentimento IT continua condicionado à política real.
- Manter calendário principal, datas locais all-day, delta de janela fixa, eventos mapeados e outbox. Subscrições básicas com expiração real, renovação antecipada, lifecycle e delta periódico; entrega exige endpoint HTTPS público e fila durável ainda inexistentes.

Evidência obtida: 19 testes do [probe](../../scripts/outlook_probe/README.md) passaram com Graph simulado, incluindo binding MSA explícito, ciclo CRUD/delta, DST, propriedade, paginação e recusa de dados/URLs indevidos. Preparado ensaio local MSAL Python, configuração segura e limpeza por journal. **Nenhuma chamada Graph real, nenhuma conta autenticada, nenhum evento real ou webhook testado.** O probe não demonstra login de produção Web/Flutter nem persistência de tokens do backend.

Limitações impeditivas: acesso ao diretório de registo por verificar, registo/configuração ausentes, conta dedicada e consentimento de teste ainda não confirmados. Ainda falta evidência CRUD/datas/delta/paginação/recorrência Graph; revogação/reconexão e precondições ETag têm de ser observadas ou limitadas explicitamente. O estudo contém a matriz de evidência e o plano de recuperação. Este ADR **não passa a aceite** e a issue permanece aberta; completar HO-001 antes de declarar a integração validada. Se surgir uma conta empresarial, reabrir validação IT/tenant/broker; consentimento pessoal não autoriza IT.
