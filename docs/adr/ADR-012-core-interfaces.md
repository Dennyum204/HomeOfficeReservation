# ADR-012 — Interfaces core e recuperação comum Android

- Data: 2026-09-10
- Trabalho: HO-011, [issue #12](https://github.com/Dennyum204/HomeOfficeReservation/issues/12)
- Estado: proposto para revisão; complementa ADR-008/009/011, sem substituir regras de domínio.

## Contexto

HO-006 já oferece contratos e transações de presenças/tarefas. HO-007 fornece caixa e destinos autorizados. HO-010 fornece calendário/pedidos Android, sessão e envelope cifrado para recuperação. A lacuna é a interface Android equivalente e a aceitação entre clientes, não um novo backend.

## Decisão

Presenças e tarefas usam o mesmo `PlanningController`, colaborador selecionado, cliente gerado e armazenamento protegido dos pedidos. `planning_work.dart` separa as operações de leitura; `features/work` contém formulários/detalhes. Os modelos de edição compõem DTOs gerados. Não existem DTOs wire copiados, novas migrações ou alterações OpenAPI.

Uma única intenção de escrita pode ficar incerta por sessão. O envelope guarda ator, colaborador, operação, contexto, chave e corpo JSON exatos antes de enviar. Presenças/tarefas acrescentam operações ao journal existente; o campo interno `request` contém o identificador do recurso destas operações, discriminado pela operação/contexto. Não há uma segunda fila nem repetição automática de escritas. O campo não é exposto como rótulo de produto.

Input é separado de estado confirmado e persistido por conta/origem/colaborador/recurso. Logout explícito limpa; expiração conserva input protegido apenas para a mesma conta. Gerações de consulta e sessão descartam respostas atrasadas. Preview depende do conteúdo atual e da versão do calendário. 409/412/428 exigem atualização e revisão explícita; uma nova intenção usa uma nova chave. Recuperação de resultado incerto reutiliza chave e corpo anteriores.

Leitura de uma presença, confirmação da sua revisão, aceitação de contraproposta e decisão final são ações distintas. Resolução usa o fluxo existente de proposta ligada à revisão da presença, aceitação pelo colaborador e decisão da chefia. A API conserva a aprovação anterior até ao commit final. Tarefas ligadas consultam a presença atual; RequiresOnsite e alterações da ligação não alteram o calendário nem reabrem progresso.

Notificações transportam apenas o identificador de notificação. Inbox/FCM resolvem destino e autorização atuais pela API antes de abrir pedido, presença ou tarefa. Abrir não marca leitura nem executa negócio. Sessão, duplicados, recurso indisponível e mudança de conta usam as proteções existentes.

Na Web estreita, o detalhe selecionado precede a lista, também no DOM; recebe foco ao abrir e devolve foco à lista ao fechar. Os rótulos distinguem a conta autenticada do colaborador selecionado e pedir dias de exigir presença. Não se apresentam UUIDs como nomes de ações.

## Alternativas e consequências

Controllers/queues independentes por área criariam múltiplas intenções incertas e rotinas de logout concorrentes. Reutilizar a sessão/journal limita esse risco sem introduzir infraestrutura. A extensão aumenta o estado do controller; testes de isolamento, recuperação e fluxos reais acompanham essa escolha.

Sem escritas offline, novo protocolo de autenticação, fornecedor de identidade ou alteração da implementação FCM. Sem iOS, Microsoft, implantação ou operação de piloto. A evidência corrente e limites estão no [guia HO-011](../HO-011-CORE-ACCEPTANCE.md); evidência anterior continua histórica.
