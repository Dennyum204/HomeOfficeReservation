# HO-012 — Monitorização externa dos backups

## Estado atual — 14/09/2026

[Primeiro backup diário realmente agendado confirmado](HO-012-SCHEDULED-BACKUP.md): 03:16:23–03:17:50 UTC, exit 0, snapshot e recibo correlacionados com start/success e reconhecimento HTTPS do monitor ativo. Nenhum backup ou ping foi forçado para esta confirmação. O disparo semanal continua não observado, sem gate adicional. SMTP/convite/ativação e aceitação funcional do piloto Web já validados. HO-017/018/019 preservam o trabalho separado; CI final e ausência de conflitos antes de ready, sem merge automático.

## Histórico e procedimentos

As situações pendentes nas entradas datadas abaixo descrevem o estado anterior e não substituem a evidência atual.


2026-09-13. PR #37 draft: integração instalada e ensaio externo validado; **execuções agendadas ainda por comprovar**. [Backup manual real](HO-012-BACKUPS.md) preservado. [ADR-022](adr/ADR-022-hosted-backup-monitoring.md).

## Decisão aprovada

Pesquisa nos scripts/documentação e unidades systemd do Pi não encontrou monitor externo configurado. Cloudflare Tunnel/R2 e o handler local existem; o alerta de orçamento não deteta falta de backups. Não se presume ausência de contas pessoais fora do projeto.

Recomenda-se **Healthchecks.io alojado, Hobbyist, US$0/mês**, três dos 20 checks incluídos: diário, semanal e ensaio. Histórico de 100 entradas por check, removendo as mais antigas; start/success consomem duas entradas (~50 execuções). Sem plano pago, cartão, SMS, WhatsApp ou chamadas. Email explicitamente aprovado pelo responsável e configurado privadamente; criação e alertas de teste autorizados.

Condições verificadas em 2026-09-13: [preço/limites](https://healthchecks.io/pricing/), [termos](https://healthchecks.io/terms/), [privacidade](https://healthchecks.io/privacy/). Não existe garantia de disponibilidade contínua. Conta/entrega exigem email; o fornecedor observa IP/horários de acesso. Os sinais não incluem dados pessoais da aplicação, dumps, logs, passwords ou credenciais R2. Alertas devem conter apenas nome genérico, estado e horário; rever uma mensagem de ensaio. URLs de ping são segredos de escrita de estado, exclusivamente em configuração privada, nunca Git/chat/logs.

## Configuração concreta

Projeto privado existente da conta, sem badges públicos. Uma integração Email para endereço **aprovado e mantido privado**, ligada aos três checks: DOWN/UP e lembrete diário enquanto DOWN. Filtrar **Only POST**, sem conteúdo/anexos. Não preencher descrições com pessoas, paths privados ou hostnames.

| Check | Agenda externa, Cron UTC | Grace | Sem sinal esperado |
|---|---|---|---|
| HomeOffice daily backup | `15 3 * * *` | 3 horas | Alerta aproximadamente às 06:15 UTC |
| HomeOffice weekly integrity | `0 6 * * 0` | 5 horas | Domingo aproximadamente às 11:00 UTC |
| HomeOffice monitoring rehearsal | Simple, 1 minuto | 1 minuto | Cerca de 2 minutos, só check sintético |

Grace cobre jitter de 15 minutos e limites atuais dos serviços (2 h/4 h), com margem. O ensaio de 396 s não estabelece máximo futuro. Start também inicia o prazo até success. Prazos são mantidos no fornecedor, sem Pi/PC ligados; margens conservadoras atrasam deteção e devem ser revistas com histórico. [Agendas](https://healthchecks.io/docs/configuring_checks/), [alertas](https://healthchecks.io/docs/configuring_notifications/).

## Integração preparada

[monitor.py](../infra/pi/backup/monitor.py) usa Python stdlib existente no ARM64, sem infraestrutura adicional pesada:

- ExecStartPre tenta start; falha de telemetria não impede o backup.
- ExecStart existente completa captura/retoma, upload, check, download/hash e retenção; semanal completa leitura integral. Recibos diário/semanal independentes, incluindo falhas.
- ExecStartPost só emite success após exit 0 e recibo novo posterior ao start. Não reutiliza sucesso antigo nem considera upload isolado suficiente.
- OnFailure preserva journal e acrescenta handler separado daily/weekly, sem recursão. Trata runner/preflight/timeout; se não chegar um aviso, o prazo externo expira.

POST vazio, duas tentativas HTTPS de 5 s com intervalo 1 s, sem redirecionamento/proxy herdado. TLS validado; host fixo hc-ping.com/UUID. Nunca imprime URL, exceção, resposta ou stdout de backup. Falha de envio de success falha o serviço, preservando recibo técnico do backup e distinguindo entrega. Sem replay tardio de sucessos. Configuração ausente/disabled mantém operação existente e não faz chamadas. [API](https://healthchecks.io/docs/http_api/), [falhas](https://healthchecks.io/docs/signaling_failures/).

[Exemplo seguro](../infra/pi/backup/monitor.example.json): destino real `/etc/homeoffice-backup/monitor.json`, root 0600/0400, diretório 0700. Três URLs distintos e flags enabled/recipient_confirmed só após aprovação/seleção efetivas. Guardar no kit privado independente; não é necessário token de gestão no Pi. Estes URLs não integram os snapshots atuais: recuperar do kit ou recriar checks após perda total; o prazo externo continua ativo.

## Instalação futura e recuperação

**Não executada.** [install-monitor.py](../infra/pi/backup/install-monitor.py) exige root/configuração aprovada; confere hashes da revisão instalada 9ca6a4d e recusa instalação desconhecida. Guarda três originais em `/var/lib/homeoffice-backup/monitor-upgrade-TIMESTAMP`, pausa só timers, recusa jobs em curso, instala hooks/script e repõe timers previamente ativos. Não inicia backup manual nem envia ping diretamente; um timer vencido pode executar ao retomar. Preserva horários, retenção, restic, dados e credenciais. Em erro repõe originais.

Depois de aprovação, preencher configuração privada e transferir/verificar **bundle completo** no scratch (os ficheiros do ensaio isolado não constituem instalação completa):

```sh
cd /home/dennyum/ho012-monitor-preparation-20260913
sudo python3 install-monitor.py
systemctl show homeoffice-backup.timer homeoffice-backup-check.timer \
  --property=Id,ActiveState,LastTriggerUSec,NextElapseUSecRealtime
```

Rollback: parar timers, aguardar jobs terminarem, repor backup.py em /opt/homeoffice-backup e os dois serviços em /etc/systemd/system a partir do diretório de recuperação; daemon-reload e repor só timers antes ativos. Não apagar backups. Para suspender apenas telemetria: enabled=false privadamente e pausar checks no fornecedor, registando perda de cobertura.

Antes de declarar cobertura, confirmar no fornecedor que os dois checks operacionais estão ativos e têm próximo prazo. Um check novo ainda sem sinal não demonstra vigilância. Após aprovação, executar uma vez os serviços reais `homeoffice-backup.service` e `homeoffice-backup-check.service` com os hooks instalados, confirmar etapas/recibos e start/success recebidos. Essa inicialização é **manual**, pode usar a breve pausa de captura já documentada e não valida o timer. Não emitir um success sintético em daily/weekly para os armar; em alternativa aguardar os primeiros jobs agendados, mantendo explicitamente a cobertura pendente até os observar.

## Ensaio controlado após aprovação

Usar só `rehearsal`, com o destinatário aprovado. Não tocar nos checks operacionais nem parar serviços, backups ou Pi:

```sh
sudo python3 /opt/homeoffice-backup/monitor.py rehearsal start
sudo python3 /opt/homeoffice-backup/monitor.py rehearsal fail
# Confirmar DOWN no fornecedor e receção do aviso.
sudo python3 /opt/homeoffice-backup/monitor.py rehearsal success
# Confirmar UP e recuperação recebida.
# Ficar >2 minutos sem sinais; confirmar novo DOWN/aviso por prazo externo.
sudo python3 /opt/homeoffice-backup/monitor.py rehearsal success
# Confirmar recuperação; pausar APENAS rehearsal, ignorando pings até reativação.
```

Rehearsal não altera recibos reais. Verificar conteúdo sanitizado do email sem publicar mensagem ou cabeçalhos privados. Não simular sucesso nos checks daily/weekly para os tornar verdes; estes devem observar jobs completos.

## Evidência separada

- Manual real: envio R2/check/restauro novo e recuperação PC/Bitwarden passaram; 396 s, fonte preservada. Não repetido para monitorização.
- Agendado real: releitura SSH em 2026-09-13 conserva LastTrigger vazio nos dois timers; próximos 14/09 03:26:26 UTC e 20/09 06:05:46 UTC. Ainda não observado. Relacionar depois LastTrigger/execução com recibo novo/snapshot e eventos externos; execução manual não prova timer.
- Preparação: testes locais restic/cifragem e monitorização; falha, ausência e recuperação com recetor/relógio simulados, sem rede externa. CI corre suite e integração PostgreSQL/restic; resultados finais no PR. Não prova email entregue ou prazo real Healthchecks.
- Externo real: Monitorização Healthchecks.io Hobbyist ativada em 2026-09-13, três checks gratuitos e destinatário aprovado guardado privadamente. Ensaio isolado real confirmou falha, ausência de sinal e duas recuperações; responsável confirmou quatro emails recebidos. Rehearsal pausado ignorando pings. Hooks instalados no Pi; backup e leitura integral iniciais MANUAIS terminaram com success reconhecido (cerca de 81 s e 75 s). Timers ativos; LastTrigger 16:25:13 UTC não correlacionado com operação concluída, não prova execução agendada. Próximos prazos locais 14/09 03:23:13 UTC e 20/09 06:09:36 UTC. Ciclos realmente agendados permanecem por comprovar. docs/HO-012-BACKUP-MONITORING.md.

HO-012 continua draft/incompleta. Também faltam SMTP real da aplicação, renovação TLS/monitorização geral, ambientes definitivos, Android físico/assinatura/distribuição e aceitação final. NAS/DNS/rotas públicas/contas da aplicação preservados. Emails de monitorização autorizados foram recebidos; SMTP da aplicação continua capturado.

### Recibo de ativação e limites da evidência

Falha explícita às 17:12 UTC, recuperação às 17:13, ausência detetada às 17:15 e segunda recuperação às 17:18 em 2026-09-13. Sinais reais enviados do PC ao check isolado, com job sintético; não se desligou o Pi. Quatro mensagens recebidas confirmadas pelo responsável, sem publicar capturas, email, IP ou URLs. Pausa persistente apenas do ensaio e lembrete diário para checks DOWN confirmados no painel.

Instalação autorizada via sudo interativo: bundle verificado, originais guardados em diretório privado de recuperação e timers preservados. Recibos daily/weekly result=success, acknowledged=true. Releitura SSH confirma ambos os serviços Result=success (17:32–17:34 UTC). Estes arranques foram manuais. LastTrigger dos timers passou a 16:25:13 UTC, coincidente com ativação dos timers anterior aos hooks; não há aqui recibo correlacionado que prove conclusão agendada. Não substituir esta lacuna pelos sucessos manuais posteriores. Próximas execuções esperadas indicadas acima incluem jitter.
