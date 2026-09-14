# HO-012 — Acesso privado e preparação dos convites

Inspeção de código em 2026-09-10, base técnica `b07b756576b5ad982eb4bf2b8e1d121c4355e57a`, [PR draft #37](https://github.com/Dennyum204/HomeOfficeReservation/pull/37). Esta revisão só documenta e cria tracking; não altera contas, papéis, emails, configuração privada ou código de autenticação.

## Decisão de utilização

A organização é privada. Fernando usa **uma conta**, com os papéis administrador de contas e colaborador. O chefe usa outra conta, como gestor explicitamente associado ao perfil de colaborador de Fernando. Outras pessoas só entram por convite administrativo. Não há registo público, inferência de papéis pelo email ou necessidade de Microsoft. Um administrador pode gerir membros, mas não aprovar os próprios pedidos nem decidir por colaboradores sem relação de gestão válida.

Páginas de login, ativação, recuperação e ficheiros da aplicação podem ser públicos. Dados de membros, calendário, pedidos, tarefas e notificações exigem autenticação, membro ativo e autorização atual na API. O endpoint público de apresentação `/api/v1/workspace` contém apenas metadados genéricos, sem dados dos utilizadores. Privacidade por convite não significa uma VPN ou Cloudflare Access adicional.

## O que existe e o que falta

| Área | Implementado e fonte | Limitação para a utilização escolhida |
|---|---|---|
| Login e aceitação | Identity, email/password, cookie Web com CSRF e bearer/refresh do framework Android. Ecrãs de ativação/recuperação nos dois clientes. [Endpoints](../../apps/api/src/HomeOffice.Api/Access/AccessEndpoints.cs), [ADR-005](../adr/ADR-005-identity-implementation.md) | Ativação introduz email, código recebido e password. Não há botão de registo público. SMTP real no alojamento ainda não foi validado. |
| Primeiro administrador | CLI `--bootstrap-admin` cria organização, IdentityUser sem password e membro administrador; envia código de ativação. [MaintenanceCommands](../../apps/api/src/HomeOffice.Api/Access/MaintenanceCommands.cs) | Cria **apenas administrador**, sem `IsEmployee` nem `IsManager`. A API recusa alterar o próprio membro. Não permite hoje preparar o titular administrador/colaborador pelo percurso documentado. [HO-013](https://github.com/Dennyum204/HomeOfficeReservation/issues/38). |
| Convidar tecnicamente | `POST /api/v1/admin/members` exige administrador ativo, cria conta sem password e membro com papéis explícitos, envia código Identity por SMTP. [AccountProvisioner](../../apps/api/src/HomeOffice.Infrastructure/Access/AccountProvisioner.cs) | É um mecanismo administrativo utilizável pela API, sem interface de convites. Envio síncrono ocorre depois do commit; falha pode deixar conta criada e sem email. Não há estado de entrega persistente/retry administrativo. [HO-014](https://github.com/Dennyum204/HomeOfficeReservation/issues/39). |
| Aceitar ou pedir novo código | Só uma conta previamente criada e ativa pode ativar; código Identity de uma hora e definição de password. Pedir ativação não cria membro e responde genericamente. | A validade do código não é uma expiração do convite. Não existe ciclo explícito pendente/aceite/cancelado, comando de reenvio/revogação do convite ou garantia de invalidar códigos anteriores por simples reenvio. Conta desativada não pode ativar. HO-014. |
| Membros e associação | API atualiza papéis/estado dos **outros** membros e associa gestor ativo a colaborador ativo na mesma organização. [MemberDirectory](../../apps/api/src/HomeOffice.Infrastructure/Access/MemberDirectory.cs) | O titular precisa primeiro do papel colaborador. Perfil gerado não expõe estado de ativação/envio nem a associação atual para gestão; listagem limita-se a 100. Sem UI de administração Web/Android. HO-013/014/015. |
| Aprovações | `CanManage` exige gestor, colaborador ativo, mesma organização, relação explícita e IDs distintos. [Regras](../../apps/api/src/HomeOffice.Domain/Access/Membership.cs), [serviço Planning](../../apps/api/src/HomeOffice.Infrastructure/Planning/PlanningService.cs) | Ser administrador não ignora estas regras. A nova gestão de contas deve conservar este comportamento e proteger a existência de um administrador ativo. |

A inspeção dos clientes encontrou os papéis apresentados ao utilizador, mas não formulários que invoquem criar/alterar membro ou atribuir gestor. Os métodos nos clientes gerados, por si só, não constituem uma interface administrativa. Não confundir a conclusão histórica de HO-003 com a entrega deste novo percurso completo.

## Percurso pretendido e trabalhos separados

1. Operador prepara o titular administrador/colaborador, numa única identidade, sem alterar diretamente SQL nem recorrer a contas artificiais para elevar os próprios papéis. [HO-013 — #38](https://github.com/Dennyum204/HomeOfficeReservation/issues/38) cobre bootstrap e correção controlada de um bootstrap anterior, preservando dados.
2. Administrador convida o chefe; o chefe aceita com código Identity e escolhe a password. Administrador associa esse gestor ao seu perfil de colaborador. [HO-014 — #39](https://github.com/Dennyum204/HomeOfficeReservation/issues/39) cobre estado, reenvio, cancelamento e recuperação de entrega, reutilizando Identity e infraestrutura existente.
3. Administrador gere outras pessoas convidadas na [administração Web HO-015 — #40](https://github.com/Dennyum204/HomeOfficeReservation/issues/40). Web responsiva é a superfície administrativa inicial; não se exige módulo administrativo nativo Android para o piloto. Android continua a permitir aceitar ativação e usar os fluxos do seu papel.
4. Fernando submete os seus pedidos; apenas o chefe associado decide. Entrar como administrador não permite autoaprovação. Um convidado não obtém acesso a outros calendários sem os papéis e relações necessários.

Dependências e critérios detalhados estão em [backlog.json](../backlog.json). Nenhuma das três tarefas depende de deployment HO-012: pode ser implementada/testada com PostgreSQL e SMTP sintéticos. A implementação será selecionada em tarefas/PRs próprios, não acrescentada silenciosamente ao PR operacional.

## Gates antes de pessoas reais

| Momento | Evidência que ainda falta |
|---|---|
| Antes do primeiro convite real para esta organização | HO-013 para a conta do titular; HO-014 para entrega recuperável e cancelamento verificável; SMTP real com destinatário de teste autorizado; HTTPS e configuração Production; ensaio sintético de ativação, associação, expiração/cancelamento, ausência de registo público, acesso anónimo negado e autoaprovação recusada. Aprovação explícita de envio e dos destinatários. |
| Antes de Fernando gerir convites autonomamente e de aceitar o piloto | HO-015 com percurso administrativo Web completo, sem comandos API manuais; aceitação Web/Android com duas contas autorizadas, mais ensaio sintético de uma terceira pessoa convidada. |
| Antes de instalar/distribuir o APK privado | Aprovação própria da distribuição, chave estável, projeto/grupo Firebase e destinatários definidos; instalação/atualização e push nos dispositivos autorizados. Ter conta na aplicação não autoriza automaticamente esta etapa. |

Estas dependências bloqueiam o acesso real e a aceitação final do piloto, **não a decisão documental sobre alojamento**. O mecanismo técnico já existente de provisionamento/ativação não é apresentado como inexistente; ainda falta torná-lo operável e verificar o percurso escolhido antes de o usar com pessoas reais.

## Convites da aplicação e convites Firebase

| Convite | Dá acesso a | Não faz |
|---|---|---|
| Aplicação, pelo administrador | Conta Identity na organização, após ativação, com papéis e relações controlados pela API | Não entrega nem instala APK; não atribui direitos em Firebase/Cloudflare/Hetzner |
| Firebase App Distribution | Download de uma versão Android para um tester autorizado | Não cria IdentityUser/Member, não atribui gestor, não permite ler dados sem login |

Não sincronizar automaticamente estas listas. Um email pode constar de ambas apenas por decisão explícita; retirar acesso à aplicação desativa o membro independentemente da posse do APK.

## Evidência e limites desta revisão

Leitura de implementação, contratos, testes existentes e clientes; não houve novo ensaio de autenticação, envio real, alteração de conta ou configuração de organização. A CI da base `b07b756` já era verde; os resultados desta revisão documental são registados no PR, sem os apresentar como testes de convites novos. Os limites de sessão do ADR-005 permanecem: logout local não é revogação global e refresh do framework não é de utilização única. O novo trabalho não promete capacidades que ainda não implementou.
