# Outlook — integração opcional por fases

Decisão atual: [ADR-004](adr/ADR-004-independent-core.md), substituindo a exigência anterior de Outlook V1. A aplicação e o seu calendário são autoritativos e funcionam integralmente sem conta Microsoft. Login, planeamento, notificações e release core não dependem de uma ligação externa.

## HO-008 — publicação opcional, após o core

- Ação Ligar Outlook apenas em Definições; funcionalidade desligada por defeito. Sem configuração, não pedir credenciais nem apresentar erro global no calendário. Estado de publicação não é estado de aprovação.
- Utilizador autentica-se primeiro na aplicação com Identity. Consentimento Microsoft separado, biblioteca OAuth/OIDC, state/nonce/PKCE e callback ligado à sessão/MemberId; confirmar a conta Microsoft escolhida, sem exigir igualdade de emails/IDs entre fornecedores. Mobile abre fluxo backend no browser, sem bearer/Graph em URLs, e consulta estado do seu membro pela API.
- Alvo inicial opcional Outlook.com pessoal; conta de teste/registo/consentimento reais ficam por validar quando HO-008 for selecionado. Tokens Graph apenas numa cache cifrada no backend. Não pedir permissões application ou de email. Calendars.ReadWrite delegado é amplo; limitação a eventos próprios é responsabilidade do nosso código.
- Publicar só localização em **dias explícitos confirmados**: remoto Portugal ou presencial Suíça efetivo. Pedidos pendentes/rejeitados, padrões inferidos e obrigações ainda em conflito não publicam localização confirmada. Tarefas não criam eventos por si só.
- Trabalho remoto não é ausência. Default `showAs=free`, all-day com início à meia-noite local e fim exclusivo no dia seguinte na mesma zona. Sem attendees/convites; nenhuma cópia automática para o gestor.
- Decisão grava plano/auditoria/outbox numa transação; worker publica depois, só para ligação ativa e versão atual. Ausência/falha do conector não bloqueia aprovação nem cria uma fila impossível de entregar. Ao ligar, o utilizador escolhe horizonte explícito de dias confirmados para publicação.
- Guardar mapeamento por membro/ligação/fonte/data, ID externo e versão. Atualizar/apagar apenas evento com propriedade confirmada nessa conta; nunca procurar pelo título e apagar resultados. Usar transactionId estável e recuperação de criação ambígua; não repetir POST indiscriminadamente.
- Leituras pontuais de eventos próprios para propriedade e escrita segura são permitidas. Validar precondições/ETag reais antes de confiar nelas. Se o evento desapareceu, mudou de forma incompatível ou ganhou participantes, parar essa publicação com erro e preservar o plano. Não fazer escrita cega nem implementar detetor/reconciliador contínuo de edições externas nesta fase.
- Definições mostram desligado, pendente, publicado, erro ou reconexão necessária. Desligar para jobs e elimina cache; eventos publicados permanecem por defeito. Uma limpeza explícita futura só pode afetar eventos comprovadamente próprios. Revogação não termina login na aplicação.

[Permissões Graph](https://learn.microsoft.com/en-us/graph/permissions-reference#calendarsreadwrite), [event/all-day](https://learn.microsoft.com/en-us/graph/api/resources/event?view=graph-rest-1.0), [criação](https://learn.microsoft.com/en-us/graph/api/user-post-events?view=graph-rest-1.0) e [IDs imutáveis](https://learn.microsoft.com/en-us/graph/outlook-immutable-id), consultados no estudo de 2026-09-08. São referências técnicas, não evidência de integração realizada.

## HO-009 — disponibilidade e sincronização avançada, posteriormente

Preservar no milestone separado: importação de disponibilidade do calendário principal, delta inicial/incremental de janela fixa, paginação, ocorrências/exceções recorrentes, cursores inválidos, webhooks/lifecycle, renovação de subscrições, recuperação de sinais perdidos e divergências após edição/remoção externa. Não instalar estes mecanismos no core nem em HO-008.

Quando implementada, reduzir conteúdo privado a intervalos necessários; não mostrar títulos/corpos ao gestor. Outlook nunca aprova pedidos nem transforma reunião em presença obrigatória. Resolver divergências explicitamente sem sobrepor aprovação local. Webhooks serão sinais de reconciliação, não comandos de negócio. HTTPS público, fila/scheduler e ensaios reais são gates deste milestone.

O [estudo anterior](HO-001-MICROSOFT-OUTLOOK-STUDY.md) conserva fontes, desenho detalhado e limitações técnicas para essa retoma. A janela proposta 30 dias anteriores/180 futuros e reconciliação de 15 minutos são hipóteses futuras a rever, não funcionamento atual.

## Evidência e desenvolvimento normal

Onboarding Microsoft e probe real **interrompidos por decisão de produto**. Uma conta dedicada vazia foi confirmada pelo utilizador; não houve consentimento Graph, CRUD, delta ou webhook real validado. O [probe legado](../scripts/outlook_probe/README.md) e os seus 19 testes simulados são referência opcional e incluem leitura avançada além do âmbito HO-008; não executar integralmente sem adaptar e autorizar o acesso na tarefa futura.

Normal desenvolvimento/CI do core exige zero credenciais Microsoft e não instala dependências do probe. HO-001 documenta a reformulação; os critérios reais adiados são de HO-008/HO-009. Não declarar o probe como validação dos futuros clientes Web/Flutter.
