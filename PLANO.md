# Plano inicial — Home Office Reservation

Atualizado: 8 de setembro de 2026. Versão do plano: 0.3. Estado: HO-000 integrado pelo PR #25; HO-001 preparado para Outlook.com pessoal, com validação real pendente.

## Objetivo

Fernando e o seu chefe planeiam os dias presenciais na Suíça e os dias de trabalho remoto em Portugal. O calendário mostra localização, pedidos pendentes e compromissos presenciais, mantendo um histórico claro das decisões.

## Stack confirmada e desenho inicial

| Parte | Escolha | Motivo |
|---|---|---|
| Backend | C# / ASP.NET Core .NET 10 LTS | Aproveita a experiência em C#; centraliza regras e integrações |
| Base de dados | PostgreSQL + Entity Framework Core | Transações para decisões, conflitos e histórico |
| Web | React + TypeScript + Vite | Dashboard e calendário adaptados ao desktop |
| Mobile | Flutter / Dart | Aplicação Android/iOS, aproveitando experiência existente |
| Identidade | Microsoft identity platform, conta MSA confirmada em HO-001 | Outlook.com pessoal; registo/consentimento e ensaio real pendentes |
| Outlook | Microsoft Graph v1.0, através do backend | Sincronização sem guardar credenciais Microsoft nas interfaces |
| Contrato | OpenAPI, clientes TypeScript e Dart gerados | Mantém Web e Mobile alinhados com a API |
| Código | Um monorepo Git | Uma fonte de contexto para o Codex e PRs por funcionalidade |

O backend começa como um monólito modular: um serviço com módulos bem separados e um worker alojado no mesmo processo. A fila de trabalho é persistida em PostgreSQL. Não é necessário introduzir microserviços para dois utilizadores.

.NET 10, EF Core/PostgreSQL, React/TypeScript e Flutter Android/iOS são as escolhas confirmadas. Identidade Microsoft, alojamento e distribuição do piloto continuam sujeitos aos estudos previstos. Consultar versões suportadas nas [fontes oficiais](docs/SOURCES.md) ao criar os projetos em HO-002.

## O que entra na V1

- Login, perfis de colaborador/chefe e relação de aprovação configurada.
- Dashboard e calendário mensal/semanal; no mobile, agenda compacta.
- Pedidos por dia ou período, rascunhos e comentários.
- Aprovação total/parcial, rejeição e proposta de outras datas.
- Alterações a períodos aprovados através de uma nova revisão.
- Compromissos presenciais com motivo, máquina/projeto, datas e confirmação de leitura.
- Deteção e resolução explícita de conflitos.
- Tarefas simples com prazo, responsável, estado e necessidade de presença.
- Notificações dentro da aplicação e push mobile, com ligações para o pedido.
- Outlook: publicar planeamento confirmado e importar disponibilidade para identificar conflitos.
- Histórico das decisões, estado da sincronização e opção de voltar a ligar a conta.
- Marcação manual de férias/indisponibilidade para fins de planeamento; sem substituir um sistema de RH.

Home office é trabalho; não é férias nem ausência. Um dia pode apresentar uma localização confirmada e, simultaneamente, um conflito ou uma proposta de alteração.

## Como funciona o Outlook na V1

A aplicação é a fonte das decisões. Publica os dias confirmados no calendário principal da conta ligada, identifica os eventos que criou e mantém-nos atualizados. Pedidos pendentes não são publicados como confirmados.

No sentido inverso, a aplicação importa intervalos de disponibilidade do calendário para ajudar a planear. Uma reunião Outlook é um aviso de potencial conflito; não significa automaticamente presença obrigatória na Suíça. A leitura técnica usa sincronização incremental suportada pela [API de calendário Microsoft Graph](https://learn.microsoft.com/en-us/graph/api/event-delta?view=graph-rest-1.0).

Editar ou apagar um evento gerado pela aplicação no Outlook cria uma divergência visível; não altera uma aprovação nem recria silenciosamente um evento eliminado. A interface permite restaurar o evento ou iniciar uma alteração do planeamento. Calendários partilhados, múltiplas contas e aprovação por edição no Outlook ficam fora da V1.

HO-001 confirmou com Fernando que o alvo é Outlook.com pessoal. O [estudo](docs/HO-001-MICROSOFT-OUTLOOK-STUDY.md) e o probe estão preparados; falta preparar registo, consentimento e mailbox dedicada para criar, alterar e remover eventos de teste e verificar delta/datas. Uma conta empresarial futura exige nova validação de IT; a conta do gestor ainda deve ser confirmada. Esta dependência externa permanece aberta.

## Quando entram as próximas funcionalidades

O [roadmap](ROADMAP.md) atribui uma versão a cada ideia. As datas dependem do acesso Microsoft, capacidade de desenvolvimento e feedback do piloto; não são promessas de entrega.

| Marco | Entrada / saída |
|---|---|
| Preparação | Rever arquitetura e validar conta Outlook |
| Construção V1 | Entregar os fluxos completos em pequenos PRs; critérios em BACKLOG.md |
| Piloto V1 | Usar com as duas contas reais; validar notificações, viagens, alterações e recuperação Outlook |
| V1.1 | Primeira iteração após duas semanas de piloto: lembretes, resumo semanal, preferências e exportação |
| V1.2 | Iteração seguinte após validar V1.1: padrões recorrentes, meios dias, viagens reservadas e propostas mais flexíveis |
| V2 | Após estabilizar V1.x e confirmar necessidade: equipa maior, substituto, calendários adicionais, anexos e offline |

Nenhuma ideia desaparece do backlog. Uma alteração de versão fica registada num PR com motivo. Funcionalidades canceladas continuam registadas como canceladas.

## Como o Codex vai trabalhar

1. Ler AGENTS.md, STATUS.md e a tarefa escolhida no backlog.
2. Trabalhar numa branch como `feat/ho-004-approval-workflow`.
3. Implementar uma alteração funcional delimitada, com testes dos riscos reais.
4. Atualizar contrato, documentação, backlog e notas de continuidade conforme necessário.
5. Abrir PR com objetivo, evidência dos testes, impacto e referência da issue real.
6. Corrigir revisão/CI e entregar PR sem draft, verde e sem conflitos. Fernando revê e integra; o Codex nunca faz merge nem ativa auto-merge.
7. No início da tarefa seguinte, verificar merge/CI e reconciliar estados antigos antes de avaliar dependências.

AGENTS.md define contexto e regras para o Codex. Os testes e proteções do GitHub verificam o que é automatizável; o ficheiro de instruções, por si só, não garante qualidade. [Instruções oficiais do Codex](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

## Entrega deste pacote

Documentação, backlog estruturado, modelos de issue/PR, instruções por área e uma validação documental de CI em [Dennyum204/HomeOfficeReservation](https://github.com/Dennyum204/HomeOfficeReservation). Não foram implementados backend, Web ou Mobile. O [estado atual](STATUS.md) regista o PR e a evidência da preparação GitHub.
