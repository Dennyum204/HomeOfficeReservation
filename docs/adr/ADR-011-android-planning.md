# ADR-011 — Planeamento Android, recuperação e navegação privada

- Data: 2026-09-10
- Âmbito: HO-010, issue [#11](https://github.com/Dennyum204/HomeOfficeReservation/issues/11)
- Estado: implementação na branch `feat/ho-010-android-calendar-requests`; integração pendente de revisão/merge.
- Continuidade: [ADR-006](ADR-006-transactional-planning.md), [ADR-007](ADR-007-web-planning-and-active-platforms.md), [ADR-009](ADR-009-durable-notifications.md) e [ADR-010](ADR-010-android-fcm-registration.md) mantêm a sua história.

## Contexto e decisão

O Android passa a consumir os mesmos endpoints de planeamento que a Web. Vistas, controller e repository são separados; a API decide autorização, transições, conflitos e concorrência. Não se acrescentam DTOs manuais, endpoints, migrações, infraestrutura Identity ou uma fila offline. Presenças/tarefas completas continuam em HO-011.

O mês compacto mostra o plano efetivo, pendentes, padrão e presenças como camadas distintas. A agenda identifica o motivo e a origem. Disponibilidade manual utiliza os pedidos/revisões existentes; não representa um processo RH nem transforma remoto em ausência. A seleção de funcionário provém de membros e verificação de gestão autorizados na API.

Formulários usam modelos gerados `DayInput` e restantes contratos. Intervalos inclusivos são pré-visualizados no servidor. `DateTime` representa aqui apenas componentes de calendário, serializadas pelo cliente gerado como `YYYY-MM-DD`; não se passa por UTC. `timezone` **0.11.1**, fixado no lockfile, serve apenas para calcular “Hoje” na zona de planeamento da organização. Horas de comentários/decisões continuam a ser instantes.

## Escritas e sessões

Uma confirmação apresenta uma cópia fixa da intenção. Antes de enviar, guarda-se num registo protegido pelo `flutter_secure_storage` o membro, destinatário, operação, chave aleatória e JSON produzido pelo DTO gerado. Input local e recuperação são separados do estado confirmado. O access token continua em memória; não se guardam passwords nem novos tokens nesse registo.

Uma escrita incerta bloqueia outras escritas. Só uma ação explícita recupera a **mesma chave e corpo**. Reinício/restauro não envia automaticamente. Uma leitura idempotente verifica/renova a sessão antes da escrita; nenhuma mutação ganha um retry implícito com outra chave. Os testes verificam os bytes HTTP nas duas tentativas e uma única consequência simulada no servidor.

O cliente Dart gerado pode encapsular erros de transporte em `ApiException(400)` com `innerException`. Esse caso permanece incerto; só uma resposta HTTP sem exceção interna comprova uma rejeição. 409/412/428 obrigam a atualizar e rever o estado antes de preparar outra intenção. Não se apresenta uma aprovação antes do recibo e leitura atuais. Uma falha de armazenamento antes do envio impede o pedido HTTP.

O registo cifrado pertence à origem API e inclui obrigatoriamente o membro. Fila de armazenamento serializa gravação/remoção entre controllers. Logout explícito apaga input e recuperação, limpa vistas e intenções de notificação; expiração limpa a vista e mantém input protegido para reautenticação da mesma conta. Outra conta não o restaura. Gerações de sessão, funcionário, consulta e detalhe impedem respostas atrasadas de repor dados. Diálogos privados são fechados ao perder a sessão. A retoma atualiza leituras, sem submeter ações pendentes.

## Notificações

A caixa e os callbacks FCM existentes abrem primeiro a notificação através da API autenticada. O destino autorizado fornece o pedido atual; IDs recebidos por push não são estado de negócio. Toques simultâneos são limitados, recursos indisponíveis têm erro explícito, e a intenção é conservada em memória durante restauro/reautenticação da mesma conta. Destinos de presenças/tarefas conservam o fallback honesto de HO-007. Não se altera o registo FID, as permissões Firebase ou a configuração privada.

## Lacuna concreta corrigida na API

O ensaio de uma contraproposta sobre uma revisão pendente de um dia aprovado revelou `invalid_revision_base`: a API exigia que o dia aprovado pertencesse diretamente ao pedido imediatamente anterior. A revisão já transportava a referência à aprovação original, mas uma contraproposta seguinte não a podia preservar.

`ValidateInput` aceita agora essa referência apenas quando o pedido anterior contém explicitamente **a mesma data, BaseDayId e BasePlanVersion**, do mesmo funcionário. A seleção afetada da contraproposta tem de confirmar essa mesma referência. A reserva e decisão final continuam a verificar o plano efetivo/versionado dentro da transação. Não se infere uma base pela data ou apenas pela raiz do pedido. O teste PostgreSQL reproduziu a recusa anterior, verifica rejeição de versão forjada sem efeitos, manutenção do plano até decisão e cancelamento explícito final. Contratos e esquema SQL mantêm-se; regeneração confirma ausência de drift.

## Alternativas e consequências

Não foi acrescentado um gestor de estado externo: `ChangeNotifier` e repositories existentes bastam para este fluxo. Um cache de calendário persistente e decisões offline aumentariam regras de reconciliação sem requisito V1; ficam fora do âmbito. A confirmação protege intenção, mas não reserva a versão no servidor: concorrência continua a poder exigir nova revisão. Após logout explícito perde-se o rascunho local; rascunhos já guardados no servidor permanecem acessíveis pela conta autorizada.

Fontes oficiais consultadas em 2026-09-10: [arquitetura Flutter](https://docs.flutter.dev/app-architecture/recommendations), [guia de arquitetura](https://docs.flutter.dev/app-architecture/guide), [PopScope](https://api.flutter.dev/flutter/widgets/PopScope-class.html), [estado Android](https://docs.flutter.dev/platform-integration/android/restore-state-android), [timezone publicado por labs.dart.dev](https://pub.dev/packages/timezone). Os APIs concretos de testes/screenshot foram conferidos no SDK Flutter fixado. Resultados reais, simulações e limitações estão no [guia HO-010](../HO-010-ANDROID-PLANNING.md).
