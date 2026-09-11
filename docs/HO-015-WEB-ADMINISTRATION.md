# HO-015 — Administração Web de membros e convites

Data: 2026-09-11. [Issue #40](https://github.com/Dennyum204/HomeOfficeReservation/issues/40). Web responsiva; administração nativa Android e tema Claude+ continuam HO-016/âmbitos futuros. Não há deployment nem convites reais autorizados.

## Utilização

O administrador ativo encontra **Administração** na navegação. A mesma conta pode manter Colaborador e usar Calendário/Pedidos; só o chefe distinto associado decide os pedidos próprios. A lista permite procurar por nome/email, carregar mais resultados e abrir um membro. Todas as páginas da API são consultadas para resolver nomes e chefias, sem depender do limite de 100 do diretório geral.

**Convidar membro** agrupa identificação e papéis. Rever o resumo antes de confirmar. A API admite a identidade, cria o convite e tenta entregar o email; a pessoa aceita em **Ainda não ativei a conta → Já tenho um código**, na Web ou Android, e define a password. Depois inicia sessão normalmente. Não existe registo público. Convites da aplicação não são convites Firebase para instalar o APK.

O detalhe separa três dimensões:

- Acesso ativo ou suspenso e papéis atuais.
- Convite por aceitar, aceite/conta ativada ou cancelado.
- Email em fila, a enviar, enviado ao adaptador, falhado ou entrega terminada.

Enviado não comprova leitura nem aceitação. Um código expira após uma hora; o convite pendente permanece. Reenvio respeita o próximo instante disponibilizado pelo servidor e invalida o código anterior. Uma falha de entrega indica retry durável ou recuperação pelo operador/novo reenvio, sem apagar a conta. Atualizar membros consulta o estado atual; não há sucesso otimista.

Cancelar é terminal para convites pendentes. Suspender uma conta ainda por ativar também cancela o convite. Uma conta aceite pode ser suspensa e reativada sem perder identidade, password ou calendário. Papéis/acesso próprios não são editáveis nesta UI; o procedimento restrito ao operador de HO-013 continua disponível. A organização conserva pelo menos um administrador ativo.

**Chefia e decisões** mostra o chefe atual e a validade da relação. A confirmação explica que substituir/remover o chefe altera a autoridade para consultar/decidir, preservando calendário/histórico. Administrar não concede autoridade de gestor; não existe autoaprovação nem seleção de outra organização.

## Concorrência e respostas perdidas

Criação reutiliza a intenção idempotente de HO-014: mesmo administrador, email normalizado, nome e papéis. Reenvio/cancelamento reutilizam `commandId` e `expectedVersion` do convite. A Web guarda a operação exata em sessionStorage, vinculada ao ator, **sem códigos, passwords ou tokens**. Recarregar o separador permite **Recuperar a mesma operação**; nenhum comando novo é enviado enquanto houver resultado incerto. Logout/troca de conta eliminam o registo local. O servidor revalida autoridade antes de reconhecer qualquer repetição.

Lacunas verificadas e corrigidas: os PUT antigos de papéis/chefia não tinham controlo de versão e a associação não permitia remover o chefe. Agora aceitam os campos emparelhados `expectedAccessVersion` e `commandId`; a Web fornece sempre ambos. `managerId: null` remove a relação. `InvitationProfile.accessVersion` é independente da versão do convite. Escritas legadas sem os dois campos mantêm compatibilidade e fazem avançar a versão quando alteram o acesso; não oferecem a proteção otimista dos novos comandos. Não os usar na UI nova.

O lock administrativo de organização serializa as mudanças. Recibos na tabela existente `InvitationCommands` vinculam ator/alvo/operação/versão e fingerprint do corpo; replay exato nunca repõe um estado ultrapassado por outra operação. Versão antiga ou chave reutilizada para corpo diferente devolvem 409. O formulário exige nova revisão dos dados atuais. Erros de leitura, sessão, autorização, limites e armazenamento são explícitos. A intenção de convite permanece no formulário após recusa para poder ser corrigida.

## Migração e recuperação

Migração aditiva `20260911080127_WebAdministrationConcurrency`: acrescenta `Members.AccessVersion` com zero para dados existentes e alarga `InvitationCommands.Operation` para acomodar fingerprint. Sem alterações de passwords, contas ou planeamento. Aplicar explicitamente com o procedimento do [backend](../apps/api/README.md). OpenAPI/TypeScript/Dart são regenerados por `scripts/generate_contracts.py`; não editar DTOs gerados.

Manter backup antes de migrações operacionais. Não executar Down numa base usada: removeria versões e reduziria a largura dos recibos existentes. Reverter binários mantendo a migração é possível, mas clientes legados perdem a proteção otimista. Não limpar recibos, recriar membros ou reemitir convites como forma de recuperar uma resposta incerta.

## Verificação e ambiente manual

Testes PostgreSQL acrescentam concorrência entre administradores, idempotência após alteração posterior, edição legada, remoção/reassociação de chefe e isolamento. Preservam as suites HO-013/014 para autoaprovação, último administrador, ativação, cancelamento, expiração, SMTP loopback 451/ack perdido e auditoria.

Browser desktop/estreito usa API/PostgreSQL reais e emails capturados localmente: criação do titular com os dois papéis, convites de chefe/pessoa adicional, aceitação Web, associação, pedido do titular e decisão do chefe, suspensão, negação a utilizador comum, cancelamento, reenvio e versões. Perda de resposta é injetada **depois da escrita real**; leituras falhadas são simulações explícitas. Capturas do ecrã administrativo não contêm credenciais. Scripts e resultados finais são registados no PR; testes locais não comprovam CI remota.

Com os SDKs fixados e configuração privada de teste:

```sh
dotnet test apps/api/HomeOffice.slnx -c Release
python scripts/generate_contracts.py --check
python scripts/check_project.py
npm --prefix apps/web run format:check
npm --prefix apps/web run typecheck
npm --prefix apps/web run lint
npm --prefix apps/web test
npm --prefix apps/web run build
npm --prefix apps/web run test:e2e:auth
npm --prefix apps/web run test:e2e
```

`HO_TEST_DATABASE` e `HO_DEV_ACCOUNTS` são entradas privadas; usar PostgreSQL isolado e os guias existentes. O ambiente manual fornecido neste computador tem base/portas/chaves/AVD próprios. Endereços, credenciais sintéticas e códigos ficam no guia local indicado na entrega, fora do Git. Não reprovisionar nem limpar os ambientes habituais.

## Integração anterior e limites

PR #43 integrado em main no commit `e12d5ccafaa8a2e336743eacf6f2b1ef5a1ee8e9`, merge humano em 2026-09-11T07:56:17Z, com teste manual HO-014 aprovado pelo responsável. A primeira [integração core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34576735065) passou backend/Web mas falhou Android: SocketException após terminar o teste de autenticação, numa consulta de capacidades push em encerramento. A [documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34576735019) passou. A repetição do job na mesma base fica documentada separadamente; não apaga a falha inicial.

Correção restrita à verificação: inicialização push revalida a sessão após cleanup e não inicia consulta de capacidades quando o dispositivo não tem configuração Firebase. Estado continua indisponível, nunca ligado. Regressões simuladas cobrem cancelamento durante cleanup e dispositivo sem configuração. Não implementa administração Android nem muda o gate de push real.

PR #37 permanece draft e HO-012 incompleta. NAS DS218+, Celeron J3355, 2 GB e Docker: evidência reportada comprova apenas conectividade Cloudflare Tunnel, sem instalação/desempenho HomeOffice. Sem DNS, alojamento pago, deployment, emails externos, distribuição APK, iOS ou Outlook neste trabalho.
