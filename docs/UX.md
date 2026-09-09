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
