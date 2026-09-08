# ADR-005 — Implementação e limites das sessões Identity

Estado: implementado em HO-003, 2026-09-09; aguarda revisão/merge humano. Concretiza [ADR-004](ADR-004-independent-core.md), sem substituir a direção de produto. Issue [#4](https://github.com/Dennyum204/HomeOfficeReservation/issues/4).

## Contexto

O scaffold já contém .NET/EF/PostgreSQL e clientes gerados. A autenticação precisa de uma implementação pequena, controlada e verificável nos clientes próprios. Não existe requisito de OAuth para terceiros, Microsoft, MFA ou SSO nesta tarefa.

## Decisão

Manter UserManager, SignInManager, handlers Cookie/Bearer e tokens de finalidade única do ASP.NET Core Identity. Não mapear o exemplo completo `MapIdentityApi`, pois expõe registo e outras operações não autorizadas no produto. Endpoints próprios estreitos chamam os serviços do framework; o refresh reproduz as verificações oficiais de ticket, validade e security stamp antes de emitir `Results.SignIn` pelo handler Bearer. Nenhum formato de token, criptografia ou servidor OAuth criado pela aplicação.

Rotas concretas: `/api/v1/auth/web/login`, `/token/login`, `/token/refresh`, `/logout`, `/csrf`, `/activation/request`, `/activation/complete`, `/recovery/request`, `/recovery/complete`. Estes nomes substituem os nomes ilustrativos de ADR-004; a separação Web/mobile permanece. OpenAPI e ambos os clientes derivam destes endpoints. Web pede CSRF com a identidade atual antes de cada mutação autenticada por cookie; login também exige CSRF. Um cabeçalho Bearer inválido não dispensa CSRF.

Identidade técnica em AspNetUsers; autorização atual em Member/Organization/ReportingLine. Um membro por IdentityUser neste piloto. Gestor, colaborador e administrador de contas são capacidades distintas; não se interpretam claims antigos de papéis como autoridade. Relações são explícitas e limitadas pela organização também nas FKs. Administração não dá poder de aprovação. Autogestão e futura autoaprovação são negadas pelo guard comum, sem implementar pedidos.

Provisionamento inicial por CLI do operador; restantes membros por API administrativa autenticada. Contas começam sem password e exigem ativação. Apenas `--provision-dev`, em Development, pode criar as três contas sintéticas confirmadas a partir de configuração privada. Migração explícita; nada disto acontece no arranque normal.

Cookie 8 h não deslizante, bearer 15 min, refresh 7 dias renováveis e códigos de conta 1 h. `SecurityStampValidator` verifica cookies em cada pedido. O handler Bearer **não** valida stamp em cada acesso: password reset invalida cookie/refresh, mas um access token copiado pode durar mais 15 min. O refresh padrão não é de utilização única; logout local não revoga cópias nem todas as sessões. Um membro desativado perde acesso protegido e renovação imediatamente por consulta à DB. Estes limites são aceites para o slice, ficam explícitos nos [guias/testes](../HO-003-AUTHENTICATION.md) e não são apresentados como logout global.

Data Protection com keyring persistente por ambiente, cifrado por certificado privado; Windows dev também admite DPAPI. Não há dependência Azure. No gerador OpenAPI `GetDocument.Insider`, usar provider efémero isolado exclusivamente para metadata sem listener/contas: gerar contrato nunca requer credenciais ou PostgreSQL. Runtime real exige persistência configurada; produção falha startup sem certificado/diretório/SMTP.

Flutter usa `flutter_secure_storage` 11.0.0, refresh por origem API, acesso só em memória, sem passwords persistidas. iOS Keychain `unlocked_this_device`, sem App Groups e com entitlements explícitos; Android backup desativado e compile SDK 37 exigido pelo plugin. Renovação e repetição de leitura limitadas, resultados antigos não ressuscitam sessões. Web apenas cookie do browser, sem tokens em storage. UI não presume autorização a partir dos papéis apresentados.

## Alternativas e consequências

Mapear registo público do exemplo foi rejeitado pelo requisito de admissão controlada. JWT próprio, refresh próprio e servidor de identidade acrescentariam protocolos/infraestrutura sem necessidade. Revogação por dispositivo, MFA e limite absoluto de sessão exigiriam requisitos e nova decisão; não são simulados aqui. Recuperação requer serviço SMTP no alojamento; captura privada substitui apenas entrega durante desenvolvimento. Limiter por IP é local ao processo, não distribuído.

O código de reset/ativação é introduzido num formulário, evitando credenciais em query strings/logs. Requests de recuperação devolvem o mesmo status/corpo; não se promete duração constante, pois entrega e existência da conta têm custos diferentes. Sem logs de payloads, tokens ou emails; CI não publica traces/snapshots de formulários com passwords.

## Fontes oficiais consultadas em 2026-09-09

- [Identity API](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/identity-api-authorization?view=aspnetcore-10.0): handlers e tokens proprietários para clientes próprios.
- [Código Identity 10.0.11](https://github.com/dotnet/aspnetcore/blob/v10.0.11/src/Identity/Core/src/IdentityApiEndpointRouteBuilderExtensions.cs) e [BearerTokenHandler](https://github.com/dotnet/aspnetcore/blob/v10.0.11/src/Security/Authentication/BearerToken/src/BearerTokenHandler.cs): emissão, refresh e limites de stamp/signout usados nesta implementação.
- [Data Protection](https://learn.microsoft.com/en-us/aspnet/core/security/data-protection/configuration/overview?view=aspnetcore-10.0): persistência, cifragem e acesso ao keyring.
- [OpenAPI build-time](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/aspnetcore-openapi?view=aspnetcore-10.0): identificação de GetDocument.Insider para evitar dependências externas.
- [Flutter secure storage](https://pub.dev/packages/flutter_secure_storage) e [implementação Darwin do mantenedor](https://github.com/juliansteenbakker/flutter_secure_storage/tree/develop/flutter_secure_storage_darwin): capacidades, configuração e limitações; pin efetivo nos lockfiles.
- [MailKit](https://github.com/jstedfast/MailKit): SMTP/STARTTLS mantido; não desativar validação de certificados.
- [PostgreSQL Windows](https://www.postgresql.org/download/windows/) / [binários EDB](https://www.enterprisedb.com/download-postgresql-binaries) e [Homebrew PostgreSQL 18](https://formulae.brew.sh/formula/postgresql@18): preparação local e macOS CI.

Evidência local e remota é registada em STATUS/PR. TestServer com PostgreSQL, browser real e Android real em emulador são verificações distintas; relógios/respostas simulados são identificados. iOS físico, assinatura, lojas, fornecedor de email e deployment não foram ensaiados nesta tarefa. Graph continua adiado.
