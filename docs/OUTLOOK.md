# Sincronização Outlook — contrato da V1

## Âmbito e autoridade

V1 usa Microsoft Graph v1.0 e uma ligação por utilizador ao calendário principal da sua própria mailbox. O estudo HO-001 valida Microsoft 365/Exchange Online, tenant e consentimento. Calendários partilhados/delegados, outros provedores e seleção de calendários secundários ficam para V2.

| Informação | Fonte autorizada | Comportamento |
|---|---|---|
| Pedido e aprovação | Aplicação | Outlook nunca aprova/rejeita pedidos |
| Localização confirmada | Aplicação | Publicada como evento identificado da aplicação |
| Presença obrigatória ativa | Aplicação | Publicada após resolução dos conflitos |
| Reunião externa | Outlook | Disponibilidade importada, sem impor presença física |
| Alteração externa de evento da aplicação | Divergência a resolver | Não altera o plano nem entra num ciclo de reposição automática |

Esta é sincronização nos dois sentidos com autoridade por tipo de informação; não é edição bidirecional irrestrita das aprovações.

## Conta e consentimento

- Separar entrar na aplicação de ligar o calendário. Quem não consentir pode continuar a planear, vendo claramente que o Outlook está desligado.
- Usar permissões delegadas `Calendars.ReadWrite` para ler e publicar no calendário do utilizador e os scopes OIDC/offline necessários ao fluxo. Não pedir permissões de email ou acesso a todas as mailboxes.
- O scope delegado de escrita abrange mais do que apenas os nossos eventos. A restrição a eventos geridos pela aplicação é imposta pelo código e pelos testes; não é uma limitação garantida pelo scope Microsoft.
- Políticas empresariais podem exigir consentimento de IT mesmo quando o scope delegado não exige admin por definição. Não presumir que instalar a aplicação concede acesso ao tenant.
- Guardar cache de tokens cifrada no backend, com controlo de acesso e chaves fora da base de dados. Não guardar tokens nos logs, issues, payloads push ou clientes Web.
- Revogação, conta desativada ou refresh inválido originam `ReconnectRequired`; parar retries de autenticação infinitos.

As permissões e tipos de conta suportados devem ser confirmados na [referência Microsoft Graph](https://learn.microsoft.com/en-us/graph/permissions-reference) e no [fluxo OIDC/PKCE](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow).

## Publicação: aplicação para Outlook

1. A transação de negócio confirma o plano, auditoria e outbox.
2. O worker consulta a versão efetiva atual; mensagens antigas não publicam estados ultrapassados.
3. Cria um evento all-day por data explícita confirmada na V1. Esta granularidade simplifica aprovações parciais e revisões. Não materializar meses de dias meramente inferidos do padrão base.
4. Usar assunto curto, por exemplo `Home office — Portugal` ou `Presencial — Suíça`; incluir apenas o contexto que o utilizador decidiu publicar. Colocar ligação para a aplicação, sem tokens no URL.
5. Eventos de localização usam `showAs=free` por defeito: indicam onde se trabalha sem bloquear todas as reuniões. A opção de bloquear disponibilidade por compromisso pode ser configurada separadamente; não interpretar trabalho remoto como out-of-office.
6. Não adicionar attendees nem enviar convites. O calendário do chefe não recebe cópias automaticamente.
7. Guardar o mapeamento do ID local, ID externo, versão e hash dos campos que a aplicação gere.
8. Em atualização/cancelamento aprovado, alterar/remover apenas eventos com mapeamento validado para essa conta; nunca pesquisar pelo título e apagar os resultados.

Para uma data, `isAllDay=true`, início às 00:00 e fim às 00:00 do dia seguinte na mesma zona suportada. A data do produto não passa por meia-noite UTC. As propriedades de evento, incluindo `transactionId`, estão na [documentação do recurso event](https://learn.microsoft.com/en-us/graph/api/resources/event?view=graph-rest-1.0).

## Leitura: Outlook para aplicação

- Importar inicialmente uma janela de 30 dias anteriores e 180 dias futuros. É um limite técnico configurável, não o limite do calendário da aplicação.
- Usar `calendarView/delta` do calendário principal. Guardar e seguir integralmente `@odata.nextLink` até ao fim e depois `@odata.deltaLink`; os cursores pertencem a uma janela fixa.
- A janela não desliza alterando parâmetros de um deltaLink existente. Ao avançar o horizonte, inicializar uma janela nova, completar a leitura e trocar o checkpoint de forma segura.
- Aplicar cada página idempotentemente e persistir cursor/projeção de forma consistente. Uma falha a meio pode repetir a página sem duplicar intervalos.
- Processar ocorrências de eventos recorrentes, exceções, cancelamentos e remoções. Se um cursor deixar de ser válido, reinicializar a janela; a ausência numa resposta parcial não autoriza apagar todos os intervalos locais.
- Reduzir o resultado a ID, intervalo, all-day, showAs e metadados técnicos mínimos. O endpoint delta não suporta `$select`: pode receber mais dados do que se persiste. Descartar corpos/títulos privados e nunca registar a resposta bruta.
- Eventos geridos pela aplicação são reconhecidos pelo mapeamento, excluídos dos avisos de disponibilidade e usados para deteção de divergência.
- Fora da janela sincronizada, a UI indica disponibilidade Outlook ainda não consultada; não declara que não há conflitos.

Esta estratégia e limitações são baseadas em [event: delta](https://learn.microsoft.com/en-us/graph/api/event-delta?view=graph-rest-1.0).

## Webhooks, recuperação e ordenação

O webhook recebe notificações básicas sem resource data, valida `clientState`, associação à subscrição e formato, enfileira um pedido de reconciliação e responde rapidamente. Implementar corretamente o desafio de validação do endpoint. O corpo recebido não é uma instrução para aprovar nem modificar negócio. [Entrega por webhooks](https://learn.microsoft.com/en-us/graph/change-notifications-delivery-webhooks).

Uma subscrição expira. Guardar a expiração devolvida pelo Graph, renovar com antecedência e tratar notificações de ciclo de vida quando aplicáveis. Não assumir que uma subscrição é permanente. [Tipos e duração de subscrições](https://learn.microsoft.com/en-us/graph/change-notifications-overview).

Webhooks aceleram a atualização, mas podem chegar duplicados ou fora de ordem. Coalescer os sinais e reconciliar o estado atual. Executar uma leitura incremental periódica, proposta a cada 15 minutos, e uma verificação de saúde mais ampla diária. Estes intervalos são decisões de produto a validar em operação, não garantias da Microsoft.

Para throttling, respeitar `Retry-After`; usar backoff com jitter quando apropriado. Distinguir falhas temporárias de falhas de consentimento. Uma indisponibilidade externa não desfaz aprovações. [Orientações oficiais de throttling](https://learn.microsoft.com/en-us/graph/throttling).

## Idempotência e divergências

- Chave única por ConnectionId e fonte/data do plano; fila com lease; versão desejada monotónica.
- Nas criações, usar `transactionId` estável para a mesma intenção e manter recuperação por mapeamento. Não assumir que existe entrega exactly-once.
- Pedir IDs imutáveis de forma consistente nas leituras/subscrições relevantes. IDs permanecem sujeitos ao âmbito da mailbox; mudanças entre mailboxes não são uma identidade global. [IDs imutáveis Outlook](https://learn.microsoft.com/en-us/graph/outlook-immutable-id).
- Comparar apenas campos geridos pela aplicação. Alterações cosméticas, como cor/reminder, não mudam o planeamento.
- Se o utilizador mover datas/apagar um evento gerido, registar `Diverged`, notificar o dono e suspender a reposição desse evento.
- Oferecer `Restaurar a partir do plano` ou `Pedir alteração do plano`. A primeira ação é explícita; a segunda segue o fluxo de aprovação.
- Se a aplicação e o Outlook mudarem ao mesmo tempo, reconciliar versões e apresentar divergência; não usar last-write-wins indiscriminado. Testar o suporte real a precondições do endpoint antes de depender de um header para a escrita.
- A resolução valida novamente o estado e a propriedade do evento antes de fazer qualquer update/delete.

## Desligar

Parar jobs da ligação, remover subscrições quando possível, eliminar cache de tokens e expurgar disponibilidade importada. Eventos já publicados permanecem por defeito, com informação clara ao utilizador. Uma futura limpeza explícita só pode afetar eventos comprovadamente geridos pela aplicação. Desligar não cancela decisões de trabalho.

## Critérios do estudo HO-001

- Identificar tipo de conta/mailbox e requisitos de IT; não usar dados reais no repositório.
- Validar login Web e viabilidade mobile com token destinado à API.
- Consentir com uma conta de teste e criar/alterar/apagar exclusivamente um evento de teste identificado.
- Verificar all-day em Lisboa/Zurique, evento recorrente na leitura e revogação/reconexão.
- Provar acesso à janela delta e registar o desenho de callback/subscrição.
- Fechar ADR-002 ou registar a limitação concreta. Não substituir Outlook silenciosamente por um ficheiro ICS.

## Critérios da integração V1

Duplicados, retries após timeout, cursor inválido, mudança de horário de verão, consentimento revogado, edição manual no Outlook e corrida entre versões constam dos testes. Objetivo interno de publicação saudável: até dois minutos; recuperação de leitura sem webhook: até 15 minutos mais o tempo de processamento. São objetivos a medir, sujeitos a indisponibilidade/throttling externo.
