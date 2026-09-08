# Qualidade e critérios de entrega

## Definition of Ready

Tarefa com objetivo, área, dependências, release e critérios observáveis. Mudanças de contrato têm consumidor identificado. Credenciais e consentimentos necessários estão disponíveis, ou o trabalho usa um adaptador de teste e regista explicitamente o que falta validar.

## Definition of Done

- Critérios da tarefa cumpridos; comportamento utilizável nas plataformas abrangidas.
- Regras no backend e autorização por objeto, não apenas botões escondidos.
- Testes dos riscos relevantes, CI verde e revisão do diff.
- Contratos/clientes e migrações atualizados no mesmo PR quando aplicável.
- Estados de erro/loading/conflito implementados na UI.
- Documentação/backlog atualizados e nenhuma integração simulada apresentada como real.
- PR integrado e ligação/evidência registadas. Release requer ainda os gates do piloto.

## Testes que realmente importam

| Risco | Verificação |
|---|---|
| Aprovação parcial incorreta | Datas aprovadas/rejeitadas/pendentes mantêm-se distintas |
| Acesso indevido | Outro colaborador/chefe sem relação recebe negação, inclusive por ID direto |
| Autoaprovação | Identidade com múltiplos papéis não aprova o próprio pedido |
| Corrida entre aprovação e presença | Operações concorrentes em PostgreSQL preservam plano coerente |
| Duplicação por retry | Uma intenção repetida cria uma decisão, notificação interna e projeção externa |
| Edição de plano confirmado | Original mantém-se até resolução; histórico liga revisões |
| Datas deslocadas | DateOnly e all-day testados em Lisboa/Zurique e transições de horário |
| Falha de Graph | Outbox persiste, aplicação funciona, retry não perde nem duplica eventos |
| Webhook perdido/duplicado | Reconciliação converge; sinal não altera negócio diretamente |
| Consentimento revogado | Estado de reconexão, sem loop de erros nem perda de aprovações |
| Evento externo alterado | Divergência visível, sem overwrite silencioso |
| Privacidade | DTO/log/push não expõe corpo/título de evento privado |
| Quebra API/clientes | Geração reprodutível e builds dos clientes contra o mesmo contrato |

Backend: testes unitários das regras e integração HTTP/EF com PostgreSQL. Web: componentes de interação e E2E do fluxo principal. Flutter: viewmodels/widgets relevantes e integração em dispositivo/emulador. Usar relógio e IDs controláveis em testes para evitar flakiness.

Não impor cobertura de 100% como substituto dos cenários. Não escrever testes de getters, cores isoladas ou detalhes internos sem risco demonstrado.

## Segurança proporcional ao produto

- OIDC/OAuth por bibliotecas estabelecidas; validação de tokens e sessões; CSRF no BFF.
- Roles mais relação Employee/Manager e OrganizationId em todas as operações sensíveis.
- Segredos fora do Git; cache Graph cifrada; não expor secrets em app mobile/Web.
- TLS, limites de input, paginação, rate limits de escrita e endpoints de autenticação/webhook.
- Logs estruturados sem tokens/dados Outlook brutos; auditoria mínima com acesso restrito.
- Imports e comentários tratados como dados, nunca instruções ou HTML confiável.
- Consentimento e preferência para partilhar disponibilidade, com conteúdo privado reduzido.
- Backups cifrados, retenção definida pelo responsável antes do piloto, exercício de restauro.

## Gate de lançamento V1

1. HO-001 até HO-012 concluídos e PRs correspondentes integrados.
2. Duas contas reais autorizadas percorrem submissão, decisão, presença e conflito.
3. Outlook validado com eventos próprios de teste: criar, atualizar, cancelar, delta, reconectar e resolver divergência.
4. Web utilizável em desktop; Android/iOS nos alvos de distribuição acordados. Builds sem assinatura não equivalem a apps distribuídas.
5. Push real validado no dispositivo; caixa interna funciona mesmo com push recusado.
6. Migração e restauro demonstrados em staging; operação do worker e subscrições observável.
7. Nenhum defeito aberto que comprometa autorização, datas, perda de decisões ou corrupção de calendário.
8. Limitações conhecidas e canais de suporte/feedback registados; responsável aceita iniciar piloto.

O objetivo do piloto é observar duas semanas de utilização antes de priorizar a primeira iteração V1.1. Se houver defeitos críticos, a correção tem prioridade sobre novas funcionalidades.
