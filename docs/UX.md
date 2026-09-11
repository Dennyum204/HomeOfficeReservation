# Experiência Web e Android

Mobile no âmbito atual significa Android; iOS está adiado para HO-306, sem data. As interfaces futuras abaixo permanecem planos até ao respetivo item estar implementado.

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
| Presencial confirmado | Superfície neutra + edifício + Suíça; confirmação separada |
| Home office aprovado | Superfície neutra + casa + Portugal; confirmação separada |
| Pedido pendente | Contorno/padrão âmbar + relógio |
| Presença necessária | Ícone de presença + rótulo + motivo; conflito em aviso separado |
| Férias/indisponível | Cinzento + rótulo explícito |
| Conflito | Ícone e aviso persistente sobre o plano existente |
| Padrão base | Apresentação discreta com indicação “Padrão” |

Cores concretizadas em HO-016/ADR-017, substituindo as propostas históricas verde/azul/roxo. Não dependem de cor para comunicar estado. Uma presença em conflito não pinta por cima do remoto aprovado: o detalhe mostra os dois e a ação de resolução.

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

## Concretização HO-016

Tema neutro Claude + adaptado com preferência claro/escuro/sistema. Web conserva componentes e reorganiza o editor em contexto, método de datas, resumo, comentário e ações; pedidos distinguem resumo, decisões por dia, ações pertinentes e histórico. Android usa ThemeData, cartões e badges comuns, preservando navegação, texto ampliado e ações existentes. Foco visível, semântica e movimento reduzido fazem parte da verificação. [Referência, licença, testes e comparações](HO-016-VISUAL-THEME.md).
