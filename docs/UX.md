# Experiência Web e Android

Mobile no âmbito atual significa Android; iOS está adiado para HO-306, sem data. As interfaces futuras abaixo permanecem planos até ao respetivo item estar implementado.

## Próxima melhoria visual escolhida, não implementada

Em 2026-09-10 o responsável selecionou **[Claude +](https://tweakcn.com/themes/cmdght103000n04lh3e2ae93r?p=application)**. Página pública confirmada com esse título, autoria Luis Llanes. [HO-016 — #41](https://github.com/Dennyum204/HomeOfficeReservation/issues/41), [milestone visual](https://github.com/Dennyum204/HomeOfficeReservation/milestone/8): tarefa futura dedicada, sem gate do piloto ou alteração de código nesta revisão.

Web mantém a estética neutra, aplica claro/escuro e preferência do sistema; modais/pedidos separam contexto, secções, resumo e ações. Android partilha a identidade com cartões simples, badges legíveis e animações discretas, respeitando redução de movimento. Local de trabalho e estado de aprovação têm rótulos/ícones distintos, sem depender apenas de cor ou esconder conflitos/plano vigente.

Ao implementar, inspecionar tokens e condições de utilização da referência, adaptar às bibliotecas atuais e verificar contraste, foco, teclado, leitores de ecrã, alvos táteis e texto ampliado. Não se decidiu adicionar shadcn, Tailwind ou outra infraestrutura apenas pela origem do tema. Funcionalidades, permissões e acessibilidade mantêm-se; iOS continua adiado. Cores ilustrativas abaixo não substituem os tokens a verificar na tarefa.

Administração de acesso é outro trabalho, [HO-015](https://github.com/Dennyum204/HomeOfficeReservation/issues/40): superfície Web responsiva para o titular gerir membros, convites e associação ao chefe. Os ecrãs existentes de ativação Web/Android não constituem essa administração. O redesenho visual pode avançar quando selecionado sem aguardar deployment; não autoriza implementar administração dentro do PR HO-012.

## Estrutura de navegação

| Ecrã | Web | Mobile |
|---|---|---|
| Início | Calendário e resumo lateral | Próximo compromisso, pendentes e agenda |
| Calendário | Mês/semana, seleção por intervalo | Mês compacto e lista do dia selecionado |
| Pedidos | Lista, filtros e detalhe | Lista com estados e detalhe completo |
| Presenças/Tarefas | Contexto de máquina/projeto e prazos | Lista acionável e detalhe |
| Notificações | Centro com não lidas | Centro e abertura por push |
| Definições | Conta local e preferências; Outlook opcional posterior | Conta local e permissões push; Outlook opcional posterior |

Ambas as plataformas suportam os dois papéis. O chefe consegue aprovar um subconjunto de dias no mobile. Não é suficiente entregar apenas ecrãs estáticos ou uma agenda de leitura.

## Calendário sem ambiguidades

| Informação | Representação proposta |
|---|---|
| Presencial confirmado | Azul + ícone de edifício + texto |
| Home office aprovado | Verde + ícone de casa + Portugal |
| Pedido pendente | Contorno/padrão âmbar + relógio |
| Presença necessária | Etiqueta roxa com motivo |
| Férias/indisponível | Cinzento + rótulo explícito |
| Conflito | Ícone e aviso persistente sobre o plano existente |
| Padrão base | Apresentação discreta com indicação “Padrão” |

Cores são propostas, sujeitas a contraste e teste. Não dependem de cor para comunicar estado. Uma presença em conflito não pinta por cima do remoto aprovado: o detalhe mostra os dois e a ação de resolução.

## Fluxos principais

1. Selecionar datas, rever dias incluídos, comentar, submeter e ver estado pendente.
2. Abrir pedido, escolher dias, decidir e confirmar o resumo antes de enviar.
3. Criar presença com motivo; pré-visualizar conflitos; publicar ou iniciar resolução.
4. Abrir dia aprovado, pedir alteração; manter a indicação do plano vigente.
5. Entrar com conta da aplicação, recuperar password e retomar sessão sem Microsoft.

Após o core, HO-008 acrescenta Ligar Outlook em Definições e estado da publicação; sem ligação não há erro global ou bloqueio. Explicar que só publica dias confirmados, com disponibilidade livre e sem convites. Não mostrar disponibilidade importada ou ações de reconciliação externa antes de HO-009.

## Estados obrigatórios

- Loading, sem dados, sem ligação, falha recuperável, permissão negada, conflito de versão e sucesso.
- Botões de escrita protegidos contra cliques repetidos, sem bloquear a recuperação de um erro.
- Em rede indisponível, mostrar cache apenas se existir e identificar a data da última atualização. Escritas offline ficam para V2; não mostrar uma aprovação local como concluída.
- Não usar atualizações otimistas para aprovações definitivas. Mostrar estado de envio até confirmação da API.
- Acessibilidade por teclado na Web, foco visível, semântica de formulários e alvos de toque adequados.
- Datas legíveis, primeiro dia da semana configurável no produto e horas com zona quando relevante.
- Textos inicialmente PT-PT, externalizados; sem strings de erro técnicas nas ações de produto.

## Consistência visual

Partilhar nomes semânticos para cores/estado, tipografia, espaçamento e linguagem. Web e Flutter podem ter componentes próprios; não tentar reutilizar widgets Flutter dentro de React. A implementação deve incluir capturas das vistas principais e teste de calendário em ecrã pequeno.

## Concretização HO-006

Web inclui separadores Presenças e Tarefas, filtros por estado, formulários e detalhes com comentários/histórico. Gestor cria presença por seleção no calendário ou formulário inclusivo; preview mostra impedimentos e avisos, sendo repetido pelo servidor na escrita. No calendário, remoto aprovado e obrigação Por resolver aparecem juntos. A confirmação de leitura tem explicação própria; propor resolução abre o fluxo de contraproposta/aceitação/decisão existente. Detalhes de tarefas mostram se a presença ligada foi cancelada e explicam que o progresso da tarefa é independente.

Navegação estreita distribui cinco separadores em linhas; diálogo modal contém o seu scroll. Campos locais são conservados no mesmo separador/conta e os comandos incertos usam replay exato. [Percurso e limitações](HO-006-ONSITE-TASKS.md). Interface Android equivalente continua HO-011; não há notificações entregues nesta etapa.

## Concretização HO-007

Notificações é um separador real Web/Android: badge, filtros, páginas, leitura explícita e estados de rede/sessão. Web abre contexto atual; Android conserva referência e explica o tratamento pela Web enquanto os ecrãs HO-010/011 faltam. Push Android é ativado por ação explícita em Definições; recusa e configuração ausente mantêm a caixa funcional. Ler nunca aprova nem confirma presença. Polling pausa em background e o estado é descartado ao sair. [Percurso e limitações](HO-007-NOTIFICATIONS.md).

## Concretização Android HO-010

Mês compacto e agenda selecionada, rótulos/ícones, padrão e aprovações separados de pendentes e presenças. Nome do colaborador ativo permanece na barra superior. Pedido de dias de trabalho é distinto de uma obrigação presencial; esta última é apenas consultada neste item, com tratamento Web até HO-011.

Formulários revêm o intervalo antes de o adicionar e confirmam a intenção antes de enviar. A chefia seleciona só o subconjunto pretendido; o colaborador retira pendentes sem cancelar aprovados. Cancelamento aprovado exige revisão e decisão final. Voltar no Android fecha confirmação/editor/detalhe; input local continua protegido até logout explícito. Erros de rede, versão e resultado incerto têm ações distintas. [Percurso e evidência](HO-010-ANDROID-PLANNING.md).

## Concretização HO-011

Os planos de interface Android dos parágrafos históricos acima são concretizados neste item: Presenças/tarefas tem listas, filtros, detalhes, edição autorizada e histórico. **Conta com sessão iniciada** e **Colaborador selecionado** são distintos. **Pedir os meus dias de trabalho** cria um pedido próprio; **Exigir presença do colaborador** é uma ação da chefia.

Um conflito explica que o plano aprovado permanece e quem atua a seguir. Confirmar leitura não aceita uma contraproposta; aceitar não é a decisão final. Calendário e notificações abrem o detalhe atual. A Web estreita coloca o detalhe antes da lista e move/devolve foco; Android usa voltar/scroll/formulários com texto escalável. [Ensaios, capturas e percurso](HO-011-CORE-ACCEPTANCE.md).
