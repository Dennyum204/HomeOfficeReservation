# HO-012 — Preparação de backups externos automatizados

2026-09-13 · [PR #37 draft](https://github.com/Dennyum204/HomeOfficeReservation/pull/37) · [issue #13 aberta](https://github.com/Dennyum204/HomeOfficeReservation/issues/13). [ADR-021](adr/ADR-021-pi-encrypted-external-backups.md). **Preparação, não serviço externo ativado.** Não foram criados buckets, credenciais R2 ou timers no Pi, nem enviados backups a um fornecedor.

## Estado confirmado nesta revisão

- Aceitação parcial do responsável no browser do telemóvel preservada: titular submete, chefe aprova e calendário/notificações internas refletem o resultado. Não equivale a APK/Android físico/push ou aceitação final.
- SSH com chave dedicada voltou a funcionar; ARM64, Docker systemd ativo, cerca de 3382 MiB disponíveis, swap 0 MiB e 48 GiB livres. O Pi tinha cerca de 20 minutos de uptime; nenhum reboot foi pedido nesta tarefa. Não se atribui uma causa ao reinício observado.
- HTTPS público 200/DYNAMIC, TLS normal; teste de browser Edge com titular e chefe confirmou login, calendário, papéis, cookies Secure/HttpOnly e logout. Sem alterar contas/configuração.
- sudo sem interação foi recusado. Estado protegido individual dos contentores/backups não foi novamente inspecionado; evidência anterior não é apresentada como leitura atual. [Inventário mínimo protegido](../infra/pi/backup/inventory.sh) preparado para execução sudo no terminal.
- API Cloudflare R2 devolveu **10042: Please enable R2 through the Cloudflare Dashboard**. Não há destino R2 utilizável confirmado. Não se presume ausência de outros serviços pessoais que não estejam configurados no projeto.

## Destino recomendado e custo

Reutilizar a conta Cloudflare existente: bucket **homeoffice-pi-backups**, **Standard**, jurisdição **EU**, prefixo **restic-v1**. Endpoint S3 `https://ACCOUNT_ID.eu.r2.cloudflarestorage.com`; sem r2.dev, domínio, CORS público ou alteração DNS. Capacidade inicial planeada **10 GB** para dumps/configuração/imagens e versões; medir após primeiro envio, não presumir dimensão dos dados futuros. O bucket é elástico, não tem um teto automático de custo de 10 GB.

Preços oficiais consultados em **2026-09-13**: Standard **US$0,015/GB-mês**, 10 GB-mês incluídos; 1 milhão de operações A e 10 milhões B incluídas por mês. Excedente: US$4,50/milhão A e US$0,36/milhão B; saída sem custo. Se o uso ficar nas franquias da conta, estimativa **US$0/mês**; 20 GB médios representam US$0,15 de armazenamento, 50 GB US$0,60, antes de operações excedentes. Impostos, câmbio e consumo de outros recursos da conta não confirmados. Faturação arredonda unidades; não é um plafond contratado. [Preços R2](https://developers.cloudflare.com/r2/pricing/).

Ativação R2/faturação poderá exigir interação no painel. Aprovação necessária antes de ativar/criar/enviar. Não contratar espaço noutro fornecedor. O NAS não é destino único; cópia manual no PC permanece complementar. [Jurisdição UE](https://developers.cloudflare.com/r2/reference/data-location/), [arranque R2](https://developers.cloudflare.com/r2/get-started/).

## Conteúdo, execução e retenção

[Código](../infra/pi/backup/backup.py), [exemplo sem segredos](../infra/pi/backup/config.example.json). O serviço usa o perfil ativo, incluindo `private/https/compose.json`; nunca troca para localhost durante manutenção.

1. Validar marker/projeto existente, espaço livre >=8 GiB, imagens linux/arm64 e identidade fixa do repositório. Nenhum pull/build/migração.
2. Exportar imagens runtime para cache privada, apenas quando muda o conjunto. Guardar `.env`, compose, scripts de arranque e hashes; não depender de imagens Docker locais nem artifacts CI após perda do Pi.
3. Pausar apenas app/worker enquanto produz dump PostgreSQL custom e copia configuração base/HTTPS, passwords de serviços, SMTP/TLS, PFX e key ring cifrado. A password do PFX está na configuração privada. Preservar Staging/nome Data Protection. Retomar o app existente em finally; marcador+ExecStopPost tratam interrupção do processo. Upload começa depois de recuperar a aplicação.
4. restic cifra SQL/configuração/chaves/imagens antes de guardar no destino; `check`, download do snapshot SQL/configuração/chaves e hashes antes de retenção. Código não imprime credenciais, conteúdo, stderr sensível ou tokens. Ficheiros de staging permanecem privados; última captura incompleta fica para diagnóstico/repetição, sem sucesso registado.
5. Reter 7 diários, 4 semanais e 6 mensais (até 17 snapshots; sobreposição reduz o total). `forget/prune` filtra host/tag exclusivos e só corre após envio/download verificado. Não usar lifecycle de expiração R2: packs são partilhados entre snapshots.

Timer diário 03:15 UTC + até 15 min de jitter, Persistent=true; recuperação de execução perdida após arranque. Check integral aos domingos às 06:00 UTC, com o mesmo jitter. Lock exclusivo entre backup/check/restauro, sem remover locks remotos automaticamente. Antes do uso real, medir a pausa local e duração/upload. Limites extra 512 MiB/0,5 CPU, sem swap adicional, prioridade baixa, upload até 2 MiB/s; não alteram limites da aplicação. RPO/RTO propostos no ADR, não garantidos.

## Instalação preparada, ainda não executada

Paths novos: `/opt/homeoffice-backup` (scripts/binário), `/etc/homeoffice-backup` (configuração e credenciais), `/var/lib/homeoffice-backup` (staging/cache/recibos/restauros). Diretórios root 0700; configuração/passwords root 0600 ou 0400. Unidades `homeoffice-backup{,-check,-failure}.service` e timers diário/semanal em `/etc/systemd/system`. Sem novas portas, containers, rotas ou ficheiros no NAS.

Binário restic **0.19.1** descarregado fora do Pi por [download_restic.py](../infra/pi/backup/download_restic.py), SHA256 do arquivo fixado a partir da release oficial. Linux ARM64 descomprimido SHA256 `2fb45ac6f9071b6f20eb883953a188f9e7c7cb6bbe43c67a2e47ada4e85ee7f0`. Não instalar pacotes pesados nem usar emulação.

Depois de autorizar o destino e preparar o bundle privado, o operador executa:

```sh
# A partir do diretório privado que contém scripts, unidades e restic verificado:
sudo sh install.sh
```

O instalador recusa paths/unidades existentes e **não ativa timers**. Copiar o exemplo para `/etc/homeoffice-backup/config.json` em sessão root/umask 077; preencher conta, paths e flags apenas após os factos correspondentes. `s3.json` contém exclusivamente `AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY` do token de objetos limitado ao bucket; não usar token administrativo da conta. Password aleatória restic independente em `repository-password`. Não colocar valores em argumentos publicados ou no histórico.

Antes do primeiro envio: preparar e confirmar o **kit de recuperação independente**: password restic, endpoint/bucket/prefixo/ID, versão/checksum do binário e este runbook. Guardar fora do Pi e com recuperação independente do PC; acesso Cloudflare/MFA/códigos de recuperação sob controlo do responsável. Token S3 pode ser reemitido após perda do Pi; perder a única password restic impede recuperar. A própria cópia cifrada não pode ser o único local da sua chave. Flags `external_authorized` e `recovery_kit_confirmed` começam falsas; não foram confirmadas nesta tarefa.

```sh
sudo python3 /opt/homeoffice-backup/backup.py init
# Registar repository_id devolvido na configuração e atualizar o kit independente.
sudo systemctl start homeoffice-backup.service
sudo systemctl start homeoffice-backup-check.service
sudo python3 /opt/homeoffice-backup/backup.py status
```

`init` é explícito, recusa repositório já configurado, nunca faz parte do job diário. Confirmar recibo/snapshot, download e restauro abaixo antes de ativar:

```sh
sudo systemctl enable --now homeoffice-backup.timer homeoffice-backup-check.timer
systemctl list-timers --all 'homeoffice-backup*'
```

Estes comandos aguardam autorização/configuração e execução real; esta documentação não é evidência de sucesso.

## Restauro novo e perda total do Pi

No Pi em uso, escolher o ID completo de 64 caracteres do snapshot no recibo privado; não usar `latest` ambíguo:

```sh
sudo python3 /opt/homeoffice-backup/backup.py restore-new \
  --snapshot SNAPSHOT_ID_COMPLETO --database ho012_restore_external1
```

Faz download para pasta nova `restore-TIMESTAMP`, verifica inventário/hash e cria uma **nova** base. Recusa nome existente e qualquer base fora do prefixo; sem DROP/--clean, sem trocar a configuração em uso. Falha conserva a base nova para diagnóstico. Validar contagens/plano/auditoria e a recuperação autenticada numa instância isolada sem worker/envio público, nunca apontar o app em uso para a base restaurada. CI faz a prova de cookie/keys/plano no runner descartável; no destino real essa prova continua pendente.

Após perda total: recuperar acesso Cloudflare e kit, reemitir token de bucket se necessário, obter restic verificado; recriar os mesmos paths de estado/configuração e usar o snapshot explícito. Os dois subdiretórios no snapshot são `/var/lib/homeoffice-backup/current` e `/var/lib/homeoffice-backup/runtime`; restaurá-los para uma pasta nova por `restic restore ID:/var/lib/homeoffice-backup/current --target NOVA_PASTA/current` e equivalente runtime, usando password-file e credenciais apenas no ambiente privado. Executar `verify_bundle` em ambos antes de usar ficheiros. O arquivo `runtime/images.tar` contém as imagens para `docker load`, sem depender do registry original.

Recriar uma stack isolada sem ativar cloudflared: copiar `current/trial` apenas para diretório **novo**, não extrair sobre instalação existente; recriar volumes próprios vazios, importar imagens e confirmar ARM64. Restaurar propriedade do perfil: configuração app/PFX/CA e key ring UID/GID 1654; segredos PostgreSQL UID/GID 999; token conector UID/GID 65532 modo 0400; diretórios privados 0700. Iniciar só PostgreSQL, que recria roles pela configuração capturada; importar dump para base nova com pg_restore --role=homeoffice --no-owner --no-privileges --exit-on-error. Manter PFX/password/key ring e nomes Identity/Data Protection consistentes. Certificados expirados e rotas têm de ser revistos antes de repor acesso externo. Não reproduzir outbox/email/push para pessoas reais durante a prova. Hardware substituto, limites, DNS existente e recuperação autenticada exigem verificação operacional própria.

## Integridade, falhas e remoção

`status.json` privado conserva último sucesso, snapshot e erro/execução em curso. `backup.py status` retorna erro para nunca executado, última tentativa falhada ou último sucesso com mais de 36 h; também falha se a leitura integral nunca passou, falhou ou tem mais de 8 dias. `full-check.json` regista essa evidência separadamente, sem um backup diário apagar uma falha semanal. Systemd falha o job e OnFailure escreve `HO012_BACKUP_FAILED` sem payload no journal. Consultar `systemctl --failed`, `systemctl status homeoffice-backup.service homeoffice-backup-check.service` e status privado; não publicar logs completos.

**Monitorização externa ainda pendente:** journal não avisa se o Pi perde energia/rede. Antes de dados reais, escolher alerta externo de ausência de sucesso, incluindo falha/check semanal e capacidade. Uma credencial S3 de escrita/eliminação pode apagar backups se o Pi for comprometido; não se promete imutabilidade. Não aplicar bucket lock/lifecycle incompatível com restic/prune sem novo desenho/teste.

Para suspender: `sudo systemctl disable --now homeoffice-backup.timer homeoffice-backup-check.timer`. Deixar execução corrente terminar; se interrompida, ExecStopPost retoma só o app marcado. Preservar repositório, password/kit, staging/recibos e todas as cópias antigas. Não usar prune global, apagar volumes ou limpar `/home/dennyum/ho012-pi-trial`. Revogar o token apenas depois de confirmar acesso independente de recuperação.

## Evidência e limites

Testes locais reais restic no Windows: cifragem, password errada, corrupção, identidade de repositório, falha de download sem poda, manifesto e nomes de base; simulações cobrem falha de dump com retoma e inclusão de HTTPS/PFX/keys. Repositórios descartáveis sintéticos, nunca dados do ensaio.

No Pi, binário ARM64 verificado e testes restic em diretório separado `/home/dennyum/ho012-backup-preparation-20260913`, sem sudo, acesso à base/app ou timers instalados. Unidades passaram `systemd-analyze verify`. Isto demonstra execução nativa do mecanismo, **não envio externo nem backup da aplicação atual**.

`pi-preparation` acrescenta PostgreSQL real: captura → restic local cifrado → download → base nova → rejeição de sobrescrita → PFX/key ring recuperados → cookie existente/plano aprovado. Resultados remotos por commit no PR; não transferir sucesso local para CI. Quatro checks core preservados. **Envio/restauro R2, kit independente confirmado, agenda real e impacto sobre o Pi em uso permanecem por verificar.**

Fontes oficiais consultadas em 2026-09-13: [release restic](https://github.com/restic/restic/releases/tag/v0.19.1), [repositório/password/S3](https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html), [check](https://restic.readthedocs.io/en/stable/045_working_with_repos.html), [retenção](https://restic.readthedocs.io/en/stable/060_forget.html), [restauro](https://restic.readthedocs.io/en/stable/050_restore.html), [credenciais R2](https://developers.cloudflare.com/r2/api/tokens/).
