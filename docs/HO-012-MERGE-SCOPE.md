# HO-012 — revisão de âmbito para merge

## Âmbito vigente aprovado

Âmbito aprovado: piloto inicial Web no Pi, aceitação funcional anterior válida. HO-017/#46 Android, HO-018/#47 staging/produção e HO-019/#48 TLS/monitorização geral separados e não concluídos. Renovação da origem antes de 11/10/2026. Bloqueios do PR: evidência do backup diário agendado e sinal externo, CI final e conflitos; não acrescentar gates.

As referências abaixo ao âmbito mais amplo são históricas e não substituem esta decisão.


Esta revisão não altera os critérios de aceitação nem declara o piloto concluído. PR #37 permanece draft. Fonte: acceptance de HO-012 em docs/backlog.json e issue #13; decisões posteriores do responsável.

## Concluído

- Instalação ARM64 no Pi, limites e ensaio com dois utilizadores, migração, worker e persistência; aceitação manual titular/chefe/calendário/notificação.
- HTTPS público Web/API, autenticação, CSRF, isolamento de serviços internos e configuração/chaves privadas.
- SMTP Brevo: convite recebido e ativação pela aplicação confirmados pelo responsável.
- Backup cifrado R2, restauro em base nova e recuperação independente com Bitwarden; agenda/retencão e monitorização externa instaladas. Falha, silêncio e recuperação testados separadamente.

## Bloqueios e decisão de âmbito

- Disparo realmente agendado ainda não observado. Leitura de 13/09 às 19:54 UTC mostra apenas serviços manuais de 17:32–17:34 UTC; diário previsto 14/09 03:23 UTC e semanal 20/09 06:09 UTC. Correlacionar timer, resultado/recibo e monitorização externa sem executar manualmente.
- Critérios escritos mantêm staging/produção isolados e Web/Android com assinatura/distribuição. Um ensaio Pi publicado não demonstra esses critérios. Android físico/distribuição é obrigatório no piloto Web/Android atualmente escrito, mas pode ser explicitamente transferido para outra issue se o responsável escolher piloto inicial só Web.
- TLS atual foi validado. Não é necessário inventar uma plataforma de monitorização geral para fechar este PR. Renovação da origem antes de 11/10/2026 continua obrigação operacional: automação pode ser separada, com responsável/procedimento/prazo explícitos; não declarar renovação ensaiada.
- Aceitação final do âmbito escolhido pelo responsável e CI verde no commit final, sem conflitos, continuam obrigatórias. Aceitação parcial não é release V1.

## Issues propostas, ainda não criadas nem consideradas concluídas

1. Renovação TLS e monitorização geral: procedimento/ensaio de renovação e recuperação, observação de disponibilidade/certificado, sem ampliar este PR. Não substitui monitorização de backups já acordada.
2. Piloto Android físico e distribuição privada: assinatura protegida, instalação em dispositivo real, login/convite/plano/aprovação/notificação e entrega privada; dependente de aceitação explícita de piloto inicial Web.
3. Separação definitiva staging/produção: ambientes/dados/segredos isolados, promoção e recuperação documentadas; transferência do critério existente depende de aprovação explícita.

Recomendação: ainda não fazer merge como HO-012 concluída. Para limitar PR #37 à entrega operacional Web já executada, aprovar explicitamente essa divisão e manter os critérios transferidos abertos nas issues próprias. Não há autorização implícita para os retirar. Depois de resolver os bloqueios desse âmbito e verificar CI final, marcar ready; merge sempre humano.
