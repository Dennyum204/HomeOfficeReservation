# HO-005 — Calendário e pedidos na Web

Interface PT-PT sobre a API transacional de HO-004. O calendário próprio funciona sem Microsoft. Os alvos ativos são Web e Android; HO-005 implementa a interface Web, enquanto o calendário Android pertence a HO-010. iOS foi adiado pelo responsável e consta de HO-306, sem data.

## Utilização local

Reutilizar o PostgreSQL e as contas sintéticas privados de [HO-003](HO-003-AUTHENTICATION.md). Não reinicializar dados para experimentar a interface. Na raiz, com os SDKs fixados disponíveis:

```sh
dotnet run --project apps/api/src/HomeOffice.Api
```

Noutro terminal:

```sh
npm --prefix apps/web run dev
```

Abrir **http://127.0.0.1:5173**. API: **http://localhost:5080**. No Windows preparado, `. .git/ho002-env.ps1` carrega os SDKs locais quando esse ficheiro privado existe. A base PostgreSQL portátil existente é uma alternativa ao Docker; não depende de Microsoft/Azure.

1. Entrar como colaborador. Em Calendário, escolher Mês/Semana, Hoje ou período anterior/seguinte. Clicar num dia abre o detalhe; as setas movem o foco, Home/End delimitam a semana, PageUp/PageDown mudam o mês. Enter/Espaço escolhem o dia. A legenda distingue padrão, localização confirmada, pendentes e ausência manual.
2. Usar **Selecionar datas** ou **Novo pedido**. Pode adicionar dias individuais ou pré-visualizar um intervalo: rever a lista exata antes de adicionar. Escolher localização/disponibilidade, escrever comentário, guardar rascunho, rever e submeter.
3. Noutro perfil/separador privado, entrar como chefia. Selecionar o colaborador atribuído no controlo **Calendário de**, abrir Pedidos, selecionar por exemplo três de cinco datas, escrever motivo e confirmar a decisão. A lista/detalhe indicam aprovados e pendentes separadamente.
4. No colaborador, **Atualizar dados**, selecionar os dois dias pendentes e retirá-los. Os três aprovados mantêm-se. Para mudar um aprovado, selecionar só dias aprovados e **Propor alteração** ou **Propor cancelamento**; guardar/submeter a revisão. O calendário continua a mostrar a aprovação efetiva e a mudança pendente separadamente até à decisão final.
5. A chefia pode criar/rever contrapropostas. O colaborador aceita a revisão exata; isso cria um pedido pendente, que ainda requer decisão final. Histórico de decisões, comentários e ligação à revisão anterior permanecem visíveis.

Férias/indisponibilidade são propostas explícitas, sujeitas às regras da API; não substituem autorização de RH. Não podem sobrepor silenciosamente um dia aprovado. O padrão semanal é uma previsão com histórico de vigências, não uma aprovação. Gestão de membros continua reservada ao administrador, sem poderes adicionais por ser gestor.

## Falhas e recuperação

Em conflito/versão antiga, a UI atualiza os dados, mantém texto e exige **Já revi os dados atualizados** antes de novo envio. Reabrir a confirmação congela novas versões e a seleção atual. Uma seleção já decidida deve ser ajustada pelo utilizador.

Se a resposta se perder, **Recuperar o mesmo envio** repete a chave e o payload guardados antes do HTTP. Pode recarregar a página e continuar a recuperação na mesma conta/separador. Não há novas escritas até resolver o resultado. Não limpar o armazenamento durante uma operação incerta; se for limpo, consultar a lista/plano antes de recriar uma intenção. Logout elimina dados locais específicos. Não se guardam credenciais no journal. [ADR-007](adr/ADR-007-web-planning-and-active-platforms.md) explica os limites.

## Contrato e recuperação da versão

Duas extensões de leitura: `EffectiveDay.sourceRequestId` e filtro `state` antes da paginação de pedidos. Sem migração ou novo modelo de negócio. Clientes TypeScript/Dart gerados a partir do OpenAPI; não editar os gerados. Para recuperar uma versão anterior da interface, usar o processo normal de PR/reversão de código, sem apagar tabelas/histórico ou recibos de idempotência.

## Verificação

Os comandos atuais estão no [guia Web](../apps/web/README.md). E2E usa Chromium, API real e PostgreSQL com contas sintéticas existentes, em 5083/5174. Escolhe semanas sem planos/pedidos pendentes existentes, sem reset. Uma execução deixa o seu histórico sintético. Uma falha interrompida pode deixar o seu pedido pendente; não elimina pedidos alheios para repetir o teste.

`planning.spec.ts` verifica cinco dias, aprovação parcial 3+2 nas duas contas, retirada dos dois pendentes, revisão preservando o plano, conflito com ausência manual, versão antiga real por comentário concorrente, recuperação de envio e acesso negado. A perda da resposta é uma **falha de transporte injetada depois de a API real confirmar a transação**; payload/recibo/estado PostgreSQL são reais. Testes Vitest de contratos, datas e respostas atrasadas são **simulações**, identificadas nos nomes.

`test:e2e:auth` mantém a expiração real de cookies de quatro segundos de HO-003. Os testes de negócio usam uma vida de dez minutos em Development. Não enfraquece o teste de expiração e não altera o limite normal de produção.

Capturas de dados sintéticos em `docs/evidence/ho-005/`, ligadas no PR, representam a interface executada. As capturas não incluem formulários de autenticação; traces/HAR permanecem desligados. Resultados locais/finais e CI do head real são registados no STATUS/PR.

## Limites desta entrega

Sem calendário Android (HO-010), presenças obrigatórias/tarefas (HO-006), entrega de notificações (HO-007), Outlook (HO-008/009), deployment ou migração destrutiva. Não foi executado iOS. Os quatro gates atuais são `project-docs`, `backend-contracts`, `web`, `flutter-android`; fonte iOS histórica permanece em Git. Não há data para HO-306. Próximo item recomendado após integração humana de HO-005: **HO-006**, não iniciado.
