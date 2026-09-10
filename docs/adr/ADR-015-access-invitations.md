# ADR-015 — Convites Identity e entrega durável

Data: 2026-09-11. HO-014, [issue #39](https://github.com/Dennyum204/HomeOfficeReservation/issues/39). Complementa ADR-005/009/014; não substitui contas, sessões, papéis ou o bootstrap legado. ADR-013 permanece reservado ao PR operacional #37, draft.

## Decisão e transições

Uma `AccessInvitation` pertence a um Member/Organization já admitido administrativamente. Guarda Pending, Accepted ou Cancelled, versão, instantes, limites e estado de entrega. A permanência do convite não expira automaticamente: **o código Identity dura uma hora**. Pending com código expirado pode receber outro código. Cancelled é terminal; não se reabre por pedido anónimo, repetição da criação ou reativação de papéis. Contas aceites são desativadas pelo mecanismo de membros existente, não pelo cancelamento de convite.

Reutilizar `UserManager.GenerateEmailConfirmationTokenAsync`, `ConfirmEmailAsync`, `AddPasswordAsync` e `UpdateSecurityStampAsync`. Reenvio roda o security stamp da identidade ainda não ativada, invalidando códigos anteriores; cancelamento faz o mesmo. Não se acrescenta formato de token, criptografia ou fornecedor de identidade. A validade registada é uma guarda adicional verificável por TimeProvider; o provider Identity também verifica finalidade, utilizador, timestamp e stamp. Aceitação e definição da password partilham a transação: uma password inválida não consome o convite. Após aceitação o código não pode repetir a operação.

Todos os comandos administrativos, pedidos anónimos de novo código e aceitação bloqueiam a organização antes de reconsultar identidade, membro e convite. A ordem de locks de HO-013 mantém-se. Aceitação, cancelamento e desativação concorrentes têm uma ordem única; um código antigo não consegue reabrir um cancelamento. Só administradores ativos podem criar/reenviar/cancelar na sua organização. O alvo é sempre resolvido no servidor; não há organização livre no corpo nem privilégios de gestão implícitos.

## Criação, repetição e auditoria

`POST /admin/members` mantém corpo e resposta 204. A intenção inicial guarda fingerprint SHA-256 do email normalizado, nome aparado e papéis, vinculada à organização e administrador. Repetir **a mesma intenção pelo mesmo administrador** devolve sucesso sem conta, membro, email ou atribuição adicional, mesmo após aceitação/cancelamento. Um corpo diferente não é uma atualização de papéis e é recusado. O administrador consulta a lista paginada para recuperar o MemberId/estado após uma resposta perdida. Um lock transacional por email normalizado serializa criações entre organizações; constraints Identity continuam ativas. Não se divulga a organização de um endereço já existente.

Reenvio/cancelamento recebem `commandId` UUID e `expectedVersion`. `InvitationCommands` conserva o recibo, vinculado ao ator, alvo, operação e versão. Repetição exata devolve 204 sem novo efeito; reutilização da chave para outro corpo/operação e versões antigas devolvem 409. Revalidar autoridade precede recuperar o recibo.

Limites persistidos: cinco emissões por convite numa janela de 24 horas, intervalo mínimo de 60 segundos; a criação inicial conta. O pedido anónimo partilha esses limites e devolve sempre 202, inclusive para contas desconhecidas, desativadas, aceites ou canceladas. Não cria Identity/Member. Criação administrativa limitada a 20 convites por organização/hora, além do limiter HTTP por IP existente. A lista expõe o próximo instante elegível para reenvio. Cancelar não emite códigos; o replay do comando é idempotente.

`AccessAudits` regista criação, reenvio, aceitação, cancelamento e alterações efetivas de membro. A constraint de origem admite `anonymous`/`worker` além das origens existentes; não se atribui uma ação anónima ao operador. Não regista códigos, passwords, emails de entrega ou conteúdo de calendário. O resultado/tentativas/erro mínimo de entrega ficam na linha durável, sem respostas SMTP privadas.

## Entrega

Gerar e proteger o código com ASP.NET Core Data Protection, finalidade própria por MemberId, dentro da transação de criação/reenvio. Só ciphertext entra em `AccessInvitations`. Reutilizar keyring persistente e cifrado por ambiente de ADR-005. A chave de proteção é infraestrutura de recuperação: perder o keyring exige corrigir configuração e reenviar; nunca imprimir material protegido para diagnóstico.

Após commit, há uma tentativa imediata limitada, preservando o uso do CLI de bootstrap sem API ativa. Falhas não fazem perder a resposta de criação. O worker HO-007 no mesmo host recupera a intenção: claim PostgreSQL `SKIP LOCKED`, lease de dois minutos, cinco tentativas no máximo, backoff 60/120/240/480 segundos. Timeout SMTP total de dez segundos; sem lock de organização durante I/O. Reconsultar destinatário antes de enviar e concluir somente a versão/lease ainda atuais. Aceitação/reenvio/cancelamento invalidam resultados tardios. Uma mensagem já em trânsito pode chegar depois do cancelamento, mas o código é inválido.

Sent significa aceitação pelo adaptador de entrega, **não leitura do email**. Development usa captura privada; produção usa SMTP STARTTLS autenticado. `LocalSmtp` é opt-in exclusivo de Development/Testing, IP loopback literal e destinatários reservados `.example`/`.invalid`; serve o ensaio local do adaptador real. Não permite relay externo, credenciais reais ou SMTP sem TLS em produção.

SMTP não oferece confirmação exatamente uma vez. Se o servidor aceitar o email e a ligação cair antes do recibo, pode haver email repetido. O retry usa o mesmo código protegido e não cria outra conta. Expiração, tentativas esgotadas ou ciphertext indisponível deixam Failed observável e recuperável por reenvio autorizado. Ciphertext é removido após envio confirmado, falha terminal, aceitação ou cancelamento. Não se promete entrega real externa a partir de uma captura local.

## Compatibilidade e limites

Migração aditiva `20260910230508_AccessInvitations`, sem reescrever utilizadores, passwords, stamps, planos ou relações existentes. Membros legados sem linha derivam Pending/Accepted de Identity e mostram entrega Unknown. Códigos legados ainda válidos podem ser aceites; reenvio explícito/anónimo cria a linha e invalida o código anterior. O upgrade de colaborador HO-013 continua a não tocar no código ou credenciais. Desativar um membro ainda não aceite cancela definitivamente o convite, inclusive legado.

Administração consulta relação de chefia atual e se continua válida; atribuição usa o endpoint existente. Nem convite com todos os papéis nem administração concedem autoaprovação. Web/Android conservam aceitação por código/password, com atalho explícito para código recebido. Não há UI de administração nova: HO-015. Sem redesign HO-016, Microsoft, iOS, deployment, DNS ou distribuição.

## Evidência e fontes oficiais

Testes PostgreSQL descartáveis cobrem transições, limites, idempotência, concorrência, isolamento e regressão HO-013. MailKit contra SMTP loopback cobre resposta 451 e perda de acknowledgement; simulações em memória cobrem abandono de lease, workers concorrentes, validade e falhas terminais. Browser/emulador executam os ecrãs reais contra API/PostgreSQL; resultados efetivos e SHA final pertencem ao PR, não são inferidos da compilação.

Consultadas em 2026-09-11:

- [Microsoft: confirmação e recuperação de conta](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/accconfirm?view=aspnetcore-10.0).
- [ASP.NET Core 10: fonte oficial DataProtectorTokenProvider](https://github.com/dotnet/aspnetcore/blob/v10.0.0/src/Identity/Core/src/DataProtectorTokenProvider.cs).
- [Microsoft: separação de finalidades Data Protection](https://learn.microsoft.com/en-us/aspnet/core/security/data-protection/consumer-apis/purpose-strings?view=aspnetcore-10.0).
- [Flutter: pumpAndSettle aguarda frames, não todo o I/O](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html). A falha Android de integração de HO-013 revelou uma espera de logout insuficiente; os asserts mantêm-se, agora aguardando o ecrã final com prazo limitado.
