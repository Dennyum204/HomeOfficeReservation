# Primeiro backup diário realmente agendado

Confirmado em 14/09/2026 por leitura SSH de systemd/journal e pelo recibo sanitizado recolhido pelo responsável com sudo interativo. A leitura não iniciou serviços, backups ou pings, não reiniciou o Pi e não alterou configuração. A tentativa inicial de leitura falhou no transporte de aspas Windows/Python antes de executar o payload; o wrapper corrigido foi validado por SSH com SHA256, UTF-8/LF sem BOM e preservação de exit codes.

| Evidência | Resultado UTC |
|---|---|
| LastTrigger do timer diário | 2026-09-14 03:16:23 |
| Início do serviço | 2026-09-14 03:16:23 |
| Fim do serviço | 2026-09-14 03:17:50; Result=success, exit 0 |
| Recibo de backup | success, 03:17:50.776533; snapshot começa por `62402f23` |
| Monitor: início | 03:16:23.349567 |
| Journal: start reconhecido | 03:16:23.549122 |
| Journal: operação concluída | 03:17:50.777017 |
| Monitor: sucesso reconhecido | 03:17:51.169144, acknowledged=true |
| Journal: success reconhecido | 03:17:51.169496 |
| Próximo diário observado | 2026-09-15 03:28:00, timer ativo |

Duração do serviço: 87 segundos, numa carga de piloto. O arranque corresponde ao horário diário 03:15 UTC com atraso aleatório; o horário estimado anteriormente mudou após reinício. Não é uma execução manual nem garantia de duração máxima futura.

Os hashes lidos no Pi coincidem com os ficheiros auditados neste repositório:

- backup.py: `7235c2522d6931b6840f45a9ab847f668004142e8f29cd2c4135cdc1aa7ed587`
- monitor.py: `f33dc6915eaad6a043a4e841ad2f40c09b648ee3b7dd9f34bf81ff20f2cb873d`

O backup só escreve o recibo de sucesso após captura/retoma, envio cifrado, check, download com comparação de hashes e retenção. O monitor ativo, com destinatário confirmado, só emite success após recibo novo posterior ao start. A correlação timer/serviço/recibo/snapshot/journal deu `correlated_scheduled_daily=true`.

## Alcance da confirmação

O sinal externo está comprovado pelo reconhecimento HTTP 200 via HTTPS registado pelo monitor instalado, com os eventos start/success correlacionados. O script não consultou o histórico do painel do fornecedor e não foi enviado um email de alerta nesta execução bem-sucedida. A entrega de alertas de falha/ausência/recuperação foi validada separadamente no ensaio anterior.

O restauro para base nova e a recuperação independente no PC/Bitwarden pertencem ao ensaio manual anterior. Não se repetiu esse ensaio para apresentar uma execução manual como agendada. A primeira verificação integral semanal ainda não foi observada; permanece em acompanhamento, sem bloquear o piloto Web acordado.

## Fecho do âmbito aprovado

A evidência satisfaz o último critério operacional pendente do piloto inicial Web. HO-012 permanece `review` até merge humano. Verificar os quatro checks core e pi-preparation no commit documental final e ausência de conflitos antes de marcar PR #37 pronto; não fazer merge, auto-merge ou release.

Android físico/distribuição (#46), separação staging/produção (#47) e renovação TLS/monitorização geral (#48, origem antes de 11/10/2026) continuam separados e não concluídos. A última imagem publicamente verificada é `3f8e8ac`; o refinamento Web de `bc55aad` tem CI verde e pacote preparado, mas a sua instalação ainda necessita de recibo do operador. Esta evidência não declara uma instalação que não foi observada.
