# ADR-004 — Core autónomo, autenticação própria e Outlook opcional

Estado: **decisão de produto confirmada pelo responsável**, documentada em HO-001/PR #27 em 2026-09-08; implementação futura. Substitui [ADR-002](ADR-002-outlook.md) quanto à identidade obrigatória, âmbito V1 e sequência de integração. Stack de ADR-001 e workflow de ADR-003 mantêm-se.

> Atualização de implementação em 2026-09-09: [ADR-005](ADR-005-identity-implementation.md) concretiza esta decisão em HO-003. O texto abaixo preserva o contexto e as propostas de HO-001; rotas e limites efetivos constam do novo ADR.

## Contexto e decisão

O responsável retirou explicitamente Outlook dos requisitos de login, planeamento e lançamento. A aplicação possui o calendário autoritativo em PostgreSQL: remoto Portugal, presencial Suíça, pedidos/decisões/revisões, presenças obrigatórias com motivo, conflitos, tarefas e notificações. React e Flutter usam o mesmo backend. Duas contas locais Employee/Manager percorrem todos os fluxos sem Microsoft. Organização e relação de gestão são dados locais; não representam um tenant Entra.

HO-001 passa a fechar esta decisão documental e o tracking, sem aplicação implementada. O estudo Microsoft já realizado mantém valor de pesquisa; ensaios Graph reais foram **adiados, não passaram**. Não exigir construir os futuros clientes para concluir este estudo. A mudança não elimina o trabalho de integração: HO-008 e HO-009 mantêm IDs e issues, em milestones opcionais após o core.

## Autenticação simples para os nossos clientes

Escolher **ASP.NET Core Identity**, stores EF Core/PostgreSQL, email/password e identificador local estável. Identity gere hashing, validação de credenciais, lockout e tokens de ativação/recuperação. Não construir criptografia, JWT/refresh próprios, protocolo OAuth ou servidor de identidade. React/Flutter são clientes diretos da mesma API, não clientes de um ecossistema OAuth aberto. [Identity](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/identity?view=aspnetcore-10.0), consultado em 2026-09-08.

| Cliente | Fluxo a implementar em HO-003 | Persistência |
|---|---|---|
| React Web | Login Identity com `useCookies=true`; mesma origem HTTPS; cookie Secure/HttpOnly e anti-CSRF em mutações, login e logout | Cookie gerido pelo browser; sem token em localStorage |
| Flutter Android/iOS | Login Identity com `useCookies=false`; access token opaco em `Authorization: Bearer`; endpoint `/refresh` do framework quando expira | Refresh token em armazenamento seguro; access token preferencialmente em memória; nunca guardar password |
| API | Handlers Identity, membro local ativo e autorização por objeto/relação em cada pedido | IdentityUserId associado ao MemberId; papéis controlados pelo servidor |

Os tokens da opção nativa Identity **não são JWT nem tokens OAuth/OIDC**. São protegidos/interpretados pelo framework e adequados a este serviço com clientes próprios; Flutter apenas transporta as strings por HTTPS. Não validar audiences/scopes JWT inexistentes nem usar estes tokens no Graph. Esta opção não é um fornecedor de identidade completo. [Identity API para SPAs e clientes sem cookies](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/identity-api-authorization?view=aspnetcore-10.0), consultado em 2026-09-08.

Usar uma biblioteca mantida para armazenamento mobile, proposta `flutter_secure_storage` (Keychain no iOS e armazenamento protegido no Android); fixar versão/backup/entitlements compatíveis na implementação, sem inventar compatibilidade já testada. [Documentação do mantenedor](https://pub.dev/packages/flutter_secure_storage), consultada em 2026-09-08. Não é necessário AppAuth ou browser Microsoft para login core.

## Contas, recuperação e limites de sessão

Admissão controlada pelo administrador para o piloto: usar UserManager/SignInManager e mecanismos Identity. Não expor o `/register` do exemplo como registo público irrestrito; proteger a criação/ativação de contas e nunca aceitar papéis enviados pelo utilizador. Bootstrap administrativo de utilização controlada, configurado fora do Git. Não deixar password padrão ou endpoint de bootstrap aberto em produção.

Ativação/recuperação usam os tokens e validação de Identity, entrega de email independente de Microsoft e respostas que não revelem existência de contas. Em desenvolvimento, adaptador local seguro de email; no piloto, configurar entrega e testar recuperação. A password não é enviada por email. Rate limits, política de password/lockout e verificação de endereços são definidos/testados em HO-003. [Confirmação e recuperação oficiais](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/accconfirm?view=aspnetcore-10.0), consultadas em 2026-09-08.

Proposta inicial do projeto: access bearer de 15 minutos e refresh de sete dias; cookie de oito horas sem renovação deslizante no piloto. São escolhas a configurar/testar, não defaults alegados do framework. Sessão expirada permite novo login preservando rascunho; um refresh falhado não entra em loop. Logout Web encerra cookie; logout mobile remove material local. Um bearer copiado pode continuar válido até expirar: não prometer revogação imediata ou refresh de utilização única sem suporte demonstrado. Security stamp invalida renovação quando aplicável; testar password reset e logout global conforme o handler. Consultar membro ativo e permissões atuais no servidor em cada operação sensível permite negar de imediato contas desativadas/papéis removidos, independentemente do token antigo. Se revogação por dispositivo ou SSO delegado se tornar requisito, criar nova decisão antes de acrescentar infraestrutura.

Cookies e tokens dependem de ASP.NET Core Data Protection. Persistir keyring com nome de aplicação/ambiente estável, acesso restrito e cifragem explícita em repouso; partilhar apenas entre instâncias do mesmo ambiente. Não usar chaves efémeras que invalidem sessões a cada restart nem partilhar chaves dev/produção. Um volume protegido e certificado provisionado fora do repo é suficiente para o host Linux inicial; Azure Key Vault não é obrigatório. [Data Protection](https://learn.microsoft.com/en-us/aspnet/core/security/data-protection/configuration/overview?view=aspnetcore-10.0), consultado em 2026-09-08.

## Outlook por fases opcionais

1. **Core v1.0:** sem conector, registos Microsoft, credenciais Graph ou probe. Ausência de configuração externa não falha startup, CI ou calendário. Notificações internas e push planeado permanecem core; email para recuperação de conta é independente dos resumos de produto futuros.
2. **HO-008 / outlook-publish:** opção em Definições após o core, desligada por defeito. Consentimento delegado próprio e cache Graph só no backend, vinculados ao MemberId autenticado; a conta ligada pode ter email diferente. Um registo de conector não substitui a identidade local. Publicar unidirecionalmente dias explícitos confirmados, all-day local, `showAs=free`, apenas eventos próprios, sem attendees/convites. Falha/desligar não interfere com decisões locais. Leituras pontuais para verificar propriedade/escrita segura não são importação de disponibilidade.
3. **HO-009 / outlook-sync:** importar disponibilidade, delta/paginação/ocorrências, webhooks/subscrições/lifecycle e reconciliação de alterações externas. Infraestrutura e evidência próprias; nenhum gate core depende desta fase.

Microsoft sign-in pode ser acrescentado como fornecedor opcional de login no futuro, por biblioteca oficial e ligação explícita a conta local já autenticada. Não vincular automaticamente contas pelo email, nem confundir consentimento de calendário com login. Essa opção não é implementada nem necessária nesta decisão.

## Alternativas e consequências

- Microsoft obrigatório: rejeitado pela nova direção; impõe acesso externo desnecessário ao calendário core.
- Keycloak, serviço SaaS de identidade ou servidor OAuth próprio: operação/custo extra sem necessidade de SSO/terceiros neste âmbito. Rever apenas quando surgir essa necessidade.
- JWT e refresh implementados manualmente: rejeitados; mecanismos do framework evitam inventar um protocolo de autenticação.

Passamos a gerir contas, entrega de recuperação e chaves de sessão. É um custo explícito e proporcional ao backend já existente no desenho. Não há migração de utilizadores a executar porque a aplicação ainda não existe. O futuro contrato OpenAPI deve documentar os endpoints e esquemas realmente implementados; o scaffold não simula autenticação completa.

## Evidência e continuidade

Foram realizados 19 testes sintéticos do probe legado e plano offline; nenhuma chamada Graph/evento/consentimento real validado. Uma mailbox de teste foi confirmada pelo utilizador; o portal Entra apresentou erro de acesso. Onboarding e configuração real foram suspensos pelo responsável. Nenhuma imagem, endereço, trace ID ou credencial entra no repositório.

Critérios antigos de HO-001 estão em `scope_history` do backlog e no histórico da issue #2. O PR #27 pode ficar pronto quando cumprir **o novo âmbito documental**, com CI verde e sem conflitos. Fecho da issue #2 pelo merge significa conclusão da reformulação, não validação de Microsoft; HO-008 e HO-009 permanecem abertos. `done` só após verificar integração do PR. Próximo trabalho: **HO-002 — scaffold .NET/React/Flutter/PostgreSQL e contratos**, numa tarefa separada após revisão/merge humano.
