# ADR-009 — Notificações duráveis e push Android

Data: 2026-09-09. Item: HO-007, [issue #8](https://github.com/Dennyum204/HomeOfficeReservation/issues/8). Implementação em revisão; entrega FCM real ainda por validar. Complementa ADR-006/008; não altera as transações de aprovação nem reativa iOS/Outlook.

**Atualização 2026-09-10:** o texto abaixo preserva a decisão inicial. O ensaio real identificou problemas no registo Android; [ADR-010](ADR-010-android-fcm-registration.md) substitui o percurso getToken/Installations pelo registo FID nativo oficial. Evidência de entrega e limitações atuais no [guia HO-007](../HO-007-NOTIFICATIONS.md).

## Contexto e decisão

A outbox de Planning/Onsite/Tasks já participa na transação de negócio. Acrescentamos um `BackgroundService` no mesmo host, claims PostgreSQL com `FOR UPDATE SKIP LOCKED`, leases com proprietário e expiração, lotes limitados e tentativas limitadas. Não são necessários broker, microserviço, SignalR ou protocolo próprio de autenticação.

O destinatário é capturado pelo servidor na transação de negócio, a partir da relação de gestão. O worker volta a verificar membro ativo, organização, relação e contexto. Uma alteração de chefia não entrega automaticamente a nova chefia um evento antigo. Consultas, leitura, links e envio revalidam a autorização atual. Não há envio ao ator, nem destinatários escolhidos pelo cliente.

Cada evento/destinatário origina no máximo uma notificação interna, garantida por índice único. Notificação, intenções de push por instalação e estado processado da outbox são gravados na mesma transação. A chamada externa ocorre posteriormente, fora dessa transação. `ProcessedAt`/legado `DeliveredAt` indicam processamento interno; `ProviderAcceptedAt` indica apenas aceitação pelo fornecedor; `DeviceReportedAt` é um recibo enviado pelo cliente autenticado, sem constituir prova criptográfica de visualização. `ReadAt` é uma ação independente do utilizador. Nenhum destes campos aprova pedidos, aceita propostas ou reconhece presenças.

Leases expirados permitem recuperação após crash. IDs de lease impedem o worker anterior de confirmar trabalho reclamado por outro. Um crash depois da aceitação externa e antes da gravação pode repetir o push: não prometemos entrega exatamente uma vez. O Android usa a notificação interna como tag estável. Falhas permanentes são contáveis e recuperáveis por ID, sem apagar histórico.

Eventos anteriores à migração são arquivo: sem badge novo e sem push. Eventos de esquema 1 são sempre históricos, mesmo em reprocessamento. Contextos inexistentes antes do consumo são ignorados com motivo; histórico preservado. Se o contexto desaparecer depois, a caixa apresenta uma referência indisponível. O [guia operacional](../HO-007-NOTIFICATIONS.md) define política e recuperação.

## Clientes e fornecedor

Web e Android usam os clientes OpenAPI gerados e polling de 15 segundos, sem sobreposição, pausado quando ocultos. Estado por membro é descartado ao sair. Web abre o pedido/presença/tarefa atual. Android abre detalhe honesto com referência preservada e encaminha o tratamento para a Web enquanto HO-010/011 não existem.

Escolhemos Firebase Cloud Messaging, com FirebaseAdmin .NET **3.6.0**, FlutterFire `firebase_core` **4.14.0**, `firebase_messaging` **16.6.0** e `firebase_app_installations` **0.4.3**, fixados em lockfiles. A documentação atual recomenda FID; o campo legado `token` do envio está deprecated. O SDK mobile mantém o token FCM e a sua renovação; obtemos o FID pelo SDK Installations, observamos ambas as alterações e registamos no backend um endereço cifrado e versionado. Não copiamos protocolos FCM nem usamos Firebase Authentication.

Registo/rotação exigem sessão e propriedade; o endereço não permite transferir uma instalação para outra conta. Logout escreve revogação durável, inclusive se preceder o primeiro registo atrasado. Uma nova ligação usa novo UUID local. Sem Internet, apagamos a sessão e tentamos apagar a identidade FCM, conservando apenas IDs de remoção pendente, nunca credenciais antigas. A impossibilidade de confirmar remoção é mostrada. O registo expira em 24 horas, renovado em primeiro plano a cada 15 minutos; abrir a app diariamente é uma limitação deliberada inicial. Alertas genéricos já aceites/em trânsito não podem ser recolhidos.

Texto externo genérico, apenas UUID da notificação e versão de esquema, sem nomes, datas, motivos, títulos de tarefas, emails ou decisões. A permissão Android é pedida numa ação explícita em Definições; a recusa não limita a caixa. Abrir um aviso requer sessão e consulta atual à API. Em primeiro plano surge um aviso interno; em background o SDK/Android apresenta a notificação. O recibo de background só é reportado ao abrir, não no instante em que o sistema apresenta o aviso.

Por defeito `PushProvider=Disabled`: arranque, caixa e CI sem credenciais externas. `Local` só em Development/Testing e grava `Simulated`, nunca aceitação real. `Fcm` usa ADC no servidor e configuração Android nativa privada externa, com opt-in `FCM_ENABLED=true`. Não há push de browser, notificações de produto por email, iOS ou infraestrutura de cloud adicional neste item.

## Alternativas e limitações

Push direto na transação perderia isolamento e tornaria aprovações dependentes do fornecedor; um serviço separado não resolve uma necessidade atual. Polling é suficiente para duas contas e tem limites claros. Notifications podem repetir, atrasar ou não chegar por rede, permissão, modo de bateria, force-stop ou falta de Google Play services. A caixa é a fonte persistente. Compilar FCM e simular callbacks não demonstra entrega real. Gate externo pendente descrito no guia e STATUS; PR permanece draft enquanto faltar essa evidência.

## Fontes oficiais consultadas em 2026-09-09

- [Admin .NET release notes](https://firebase.google.com/support/release-notes/admin/dotnet) e [envio Admin/FID](https://firebase.google.com/docs/cloud-messaging/send/admin-sdk): versão, endereço atual e HTTP v1.
- [Flutter setup](https://firebase.google.com/docs/flutter/setup), [Android setup](https://firebase.google.com/docs/android/setup) e [receção Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages): recursos nativos, permissão, foreground/background e abertura inicial.
- [Firebase Installations](https://firebase.google.com/docs/projects/manage-installations), [gestão de tokens](https://firebase.google.com/docs/cloud-messaging/manage-tokens), [erros FCM](https://firebase.google.com/docs/cloud-messaging/error-codes) e [Admin setup/ADC](https://firebase.google.com/docs/admin/setup): renovação, remoção, tentativas e credenciais.
- [Google Services task, fonte oficial](https://github.com/google/play-services-plugins/blob/main/google-services-plugin/src/main/kotlin/com/google/gms/googleservices/GoogleServicesTask.kt): entrada externa `googleServicesJsonFiles`, plugin **4.5.0**. Sem copiar configuração real para Git.
