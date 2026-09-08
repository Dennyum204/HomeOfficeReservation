# Experiência Web e Mobile

## Estrutura de navegação

| Ecrã | Web | Mobile |
|---|---|---|
| Início | Calendário e resumo lateral | Próximo compromisso, pendentes e agenda |
| Calendário | Mês/semana, seleção por intervalo | Mês compacto e lista do dia selecionado |
| Pedidos | Lista, filtros e detalhe | Lista com estados e detalhe completo |
| Presenças/Tarefas | Contexto de máquina/projeto e prazos | Lista acionável e detalhe |
| Notificações | Centro com não lidas | Centro e abertura por push |
| Definições | Conta, Outlook e preferências | Conta, Outlook e permissões push |

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
5. Ligar Outlook, ver consentimento/estado; consultar último sucesso e recuperar divergências.

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
