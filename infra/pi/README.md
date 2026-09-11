# HO-012 — Ensaio Raspberry Pi ARM64 para revisão

Preparação autorizada; **HomeOffice ainda não instalado no Pi**. [Proposta](../../docs/HO-012-PILOT.md), [ADR-019](../../docs/adr/ADR-019-pi-arm64-trial.md). NAS/AMD64 preservado em [infra/nas](../nas/README.md); não reutilizar os seus arquivos, volumes ou credenciais.

## Evidência e acesso

SSH com chave dedicada confirmado. Engine 29.8.0 ARM64/Compose 5.5.1, sem contentores/volumes; ~3,57 GiB disponíveis, ~49,6 GiB livres e swap/OOM zero em repouso. Leituras sudo executadas pelo responsável no terminal. Após alteração mínima de arranque e um reinício autorizados, **Memory=true/Swap=true/CFS=true** confirmados pelo Docker; controlador memory V2 disponível. O kernel processou o disable herdado do DTB e depois o enable explícito, conforme suportado pelo fornecedor. Original preservado. Suporte não equivale a teste de aplicação ou de imposição dos limites. HomeOffice não instalado. [Inventário atualizado](../../docs/HO-012-PI-INVENTORY.md).

Numa sessão SSH autorizada, executar [inventory.sh](inventory.sh) com sudo para as leituras Docker/sshd. O script só recolhe metadados: versão Engine, workloads/volumes/redes, armazenamento, memória/swap/pressão, temperatura quando disponível e limites. Confirmar a configuração sshd também com o contexto do utilizador se existirem regras Match. Não partilhar passwords ou logs integrais.

```powershell
ssh dennyum@192.168.1.105
```

A chave dedicada funciona; password sudo apenas no terminal quando necessária; não conceder sudo sem password nem alterar forwarding nesta etapa. Se qualquer leitura falhar, fica por verificar. São necessários, antes de instalar: Linux ARM64 nativo no host/Engine; Compose plugin; memory/swap/CFS suportados; pelo menos 2 GiB MemAvailable estável e 8 GiB livres; rede sem colisão e SSH direct-tcpip permitido. A ausência de acesso não impede build/test fora do Pi.

## Recursos exatos propostos

Projeto Compose **homeoffice-pi-trial**, diretório novo **/home/dennyum/ho012-pi-trial**, condicionado à confirmação do diretório pai e espaço. O gerador e mkdir recusam destino existente. Não formatar, alterar partições ou sobrescrever dados da microSD.

| Serviço | Imagem ARM64/tag | RAM / CPU | Persistência |
|---|---|---|---|
| app | homeoffice-pi:ho012-SHA | 768 MiB / 1,5 | private/keys; configuração e PFX em private |
| database | homeoffice-pi-postgres:ho012-SHA | 512 MiB / 1 | homeoffice-pi-trial_database, montado em /var/lib/postgresql |
| edge | homeoffice-pi-caddy:ho012-SHA | 64 MiB / 0,25 | TLS local em private, montagem de leitura |
| mailpit | homeoffice-pi-mailpit:ho012-SHA | 128 MiB / 0,25 | homeoffice-pi-trial_mail; até 100 mensagens |

SHA é sempre o commit completo verificado. Total **1472 MiB e 3 CPU**; reserva conservadora perante a memória reportada, a confirmar após Docker. Sem swap adicional por contentor, sem restart automático, logs até 2 × 5 MiB por serviço. Pool API 10, PostgreSQL máximo 20 conexões/shared_buffers 64 MiB. Não desativar OOM ou seccomp. Medir também margem do host, pressão de memória, temperatura/throttling e impacto da microSD.

Rede **homeoffice-pi-trial_trial**, internal=true, **10.78.17.0/24**, sujeita ao inventário; edge **10.78.17.2:443**, Mailpit **10.78.17.3:8025**. API 8080, PostgreSQL 5432 e SMTP 1025 apenas internos. **Nenhuma porta publicada no Pi**, sem rede host ou socket Docker. Nem LAN nem Internet recebem novas portas. Sem saída/relay, DNS ou Cloudflare. Rótulo aleatório org.homeoffice.trial impede reutilizar volumes/rede de outro ensaio.

## Build e transferência preparados no PC/CI

O job **pi-preparation** usa **ubuntu-24.04-arm**, exige arquitetura nativa ARM64 e verifica todas as imagens. Não instala emulação. Dockerfile partilhado com o perfil piloto; nenhuma mudança de aplicação, API, contratos ou migração nesta revisão. Bases fixadas: Node 24.20.0-bookworm-slim, SDK .NET 10.0.400-noble, ASP.NET 10.0.11-noble, PostgreSQL 18.6-bookworm, Caddy 2.11.4-alpine e Mailpit v1.31.1. Pull ARM64, arquitetura/configuração e digests reais são registados no manifesto de cada execução; falha se faltar suporte.

O job executa a stack exata antes de exportar as quatro imagens runtime em **ho012-pi-images-SHA**: images.tar, manifest.json e SHA256SUMS; retenção 7 dias. Evidência sanitizada em **ho012-pi-runner-evidence**, 14 dias. Não contém configuração, credenciais, SDKs ou dados do dispositivo. Se expirar, repetir CI do mesmo SHA e verificar novamente. Nunca usar artifacts NAS/AMD64.

No PC preparado, Python >=3.11, OpenSSL e gh (build local exigiria host ARM64 nativo; não usar Docker Windows/AMD64 para simular):

```powershell
$sha = git rev-parse HEAD
$bundle = "C:/Work/Private/HomeOfficeReservation/HO012-PI-$sha"
gh run download RUN --repo Dennyum204/HomeOfficeReservation --name "ho012-pi-images-$sha" --dir "$bundle/images"
Get-FileHash "$bundle/images/images.tar" -Algorithm SHA256
# Comparar com manifest.json/SHA256SUMS, platform=linux/arm64 e o SHA/checks reais.
python infra/pi/prepare.py --destination "$bundle/trial" --image "homeoffice-pi:ho012-$sha"
tar -cf "$bundle/trial-private.tar" -C "$bundle/trial" .
Get-FileHash "$bundle/trial-private.tar" -Algorithm SHA256
```

RUN é o run verde efetivo do commit. O arquivo privado é separado do artifact público. Proteger o diretório novo com ACL apenas do operador/SYSTEM/Administrators no Windows; não alterar ACL de diretórios existentes. Passwords sintéticas propostas ficam em **trial/private/CREDENCIAIS.json**. Não representam contas criadas nem ativação realizada. Certificados TLS e Data Protection usam chaves distintas; não substituir PFX/key ring ao renovar TLS.

## Instalação proposta — NÃO executar antes da revisão/autorização

Só após corrigir/verificar memory/swap/CFS, repetir inventário, rever recursos e autorizar a instalação, criar o diretório novo no Pi:

```sh
umask 077
mkdir /home/dennyum/ho012-pi-trial
chmod 700 /home/dennyum/ho012-pi-trial
```

No PC:

```powershell
scp "$bundle/images/images.tar" "$bundle/images/SHA256SUMS" "$bundle/images/manifest.json" "$bundle/trial-private.tar" dennyum@192.168.1.105:/home/dennyum/ho012-pi-trial/
```

No Pi, após conferir os hashes com os do PC:

```sh
cd /home/dennyum/ho012-pi-trial
sha256sum -c SHA256SUMS
sha256sum trial-private.tar
tar -xf trial-private.tar
sudo sh trial.sh preflight
sudo docker load -i images.tar
sudo sh trial.sh validate
sudo sh trial.sh start
sudo sh trial.sh health
sudo sh trial.sh bootstrap
```

start verifica arquitetura de todas as imagens, recusa colisões de projeto/volumes, nunca faz pull/build, ajusta ownership só dos ficheiros deste ensaio, inicia DB/Mailpit, migra explicitamente e inicia API/worker/edge. bootstrap cria apenas o titular Admin+Employee e enfileira convite; repetir é idempotente. Não cria/ativa contas automaticamente no arranque. Falhas conservam o diagnóstico privado.

## Acesso e teste manual com duas pessoas sintéticas

No PC, confirmar que as portas estão livres e manter este encaminhamento aberto, apenas após instalação autorizada e confirmação de permissões SSH:

```powershell
ssh -N -o ExitOnForwardFailure=yes -L 127.0.0.1:18443:10.78.17.2:443 -L 127.0.0.1:18025:10.78.17.3:8025 dennyum@192.168.1.105
```

Web **https://localhost:18443**, email capturado **http://127.0.0.1:18025** no PC. O túnel publica apenas sockets loopback no PC. Confirmar o fingerprint e confiar explicitamente no certificado local num perfil de teste; não desativar validação TLS globalmente. TLS local expira após 30 dias; o PFX de Data Protection separado deve ser preservado. O harness usa ca.pem com validação TLS.

1. Mailpit → email owner@pi.example → Web **Ativar conta**, código capturado e password do ficheiro privado. Organização **HO-012 ENSAIO Pi — SINTETICO**.
2. Titular → Administração → convidar manager@pi.example como gestor, sem administrador. Aceitar num segundo perfil do browser com email capturado e credencial privada. Não usar email real.
3. Administração → titular → associar o chefe distinto; manter Admin+Employee. O próprio titular não aprova os seus pedidos.
4. Titular → Calendário/Pedidos → submeter dia remoto futuro. Chefia → selecionar titular → aprovar. Confirmar plano/notificação persistente na sessão do titular.
5. Confirmar que a entrega SMTP foi capturada; não equivale a leitura nem envio externo. Código expirado exige reenvio/recuperação pela aplicação. Nenhum código em logs/GitHub.

Android habitual permanece inalterado. Este ensaio verifica Web/API; CI Android mantém o check existente, sem distribuição ou ligação a este TLS privado.

## Medições, reinício e recuperação

Antes do arranque guardar inventário/baseline em ficheiro privado. Durante dez minutos com duas sessões e pelo menos trinta minutos depois, recolher:

```sh
sudo sh trial.sh metrics
umask 077
mkdir private/measurements
for n in $(seq 1 20); do sudo sh trial.sh metrics; sleep 30; done > private/measurements/two-users-10min.txt
sudo sh trial.sh database-outage-check
sudo sh trial.sh restart
sudo sh trial.sh health
sudo sh trial.sh backup
sudo sh trial.sh restore-new /home/dennyum/ho012-pi-trial/private/backups/TIMESTAMP ho012_restore_manual1
```

Não reutilizar/sobrescrever ficheiro de medição existente. metrics inclui memória/CPU/PIDs, swap, contadores OOM, reinícios e limites; comparar deltas de pswpin/out, não apenas swap ocupado. Recolher latência das leituras/escritas nas duas sessões sem exportar payloads. Metas propostas após aquecimento: p95 leitura <=1 s, escrita <=2 s, sem OOM/reinícios inesperados/pressão crescente ou degradação de workloads anteriores. Não são resultados nem SLA. Medir temperatura e throttling pelos utilitários já disponíveis, sem instalar monitorização pesada.

database-outage-check para só a DB do ensaio: liveness tem de continuar 200 e readiness falhar, recuperando depois. restart deve conservar sessões, relações, plano aprovado, inbox e Mailpit. O worker é validado por efeitos duráveis na inbox, não apenas pelo estado do processo.

backup pausa brevemente só app/worker, exporta pg_dump -Fc, configuração/PFX/key ring e hashes, retomando app. restore-new verifica hashes e CREATE DATABASE, recusa base existente e não faz DROP/--clean. Não altera a fonte nem a aplicação. Falha deixa a base nova para diagnóstico.

Para recuperação autenticada completa: parar só app, guardar cópia privada de application.json, mudar apenas Database=homeoffice para Database=ho012_restore_manual1, preservar/recuperar PFX e key ring do backup, iniciar app e verificar sessões/chefia/pedido/inbox. Repor a configuração fonte no fim; não apagar a base restaurada. O comando backup usa sempre a fonte homeoffice. Mailpit não faz parte do backup SQL: usar reenvio de convite quando necessário. CI demonstra este percurso numa base nova, incluindo recusa de sobrescrita, mas o restauro na microSD continua por executar.

Backup na mesma microSD permite recuperação lógica; não protege contra perda do cartão/Pi. Cópia cifrada independente, retenção e RPO/RTO continuam decisões do piloto, sem contratação nesta etapa.

## Parar e remover apenas o ensaio

```sh
sudo sh trial.sh stop
sudo sh trial.sh remove-containers
```

Remoção conserva volumes, dados, keys, PFX, imagens e backups. Inspecionar rótulos antes de qualquer eliminação posterior autorizada; nunca usar prune, limpeza global ou apagar paths calculados. Não parar Docker/Pi nem outros serviços. **verify.py é destrutivo e restrito à CI descartável; nunca executá-lo no Pi.**

## Fontes oficiais consultadas em 2026-09-11

- [Docker Debian](https://docs.docker.com/engine/install/debian/): Trixie e ARM64 suportados; instalação reportada pelo responsável.
- [Runners GitHub](https://docs.github.com/en/actions/reference/runners/github-hosted-runners): ubuntu-24.04-arm nativo para repositório público.
- [.NET Docker ARM64](https://github.com/dotnet/dotnet-docker/tree/main/src/sdk/10.0/noble/arm64v8), [Node](https://github.com/docker-library/official-images/blob/master/library/node), [PostgreSQL](https://github.com/docker-library/official-images/blob/master/library/postgres), [Caddy](https://github.com/docker-library/official-images/blob/master/library/caddy), [Mailpit](https://mailpit.axllent.org/docs/install/docker/): fontes dos fornecedores; digests/arquitetura das tags exatas verificados pela execução, não só pela documentação.
- [Limites Docker](https://docs.docker.com/engine/containers/resource_constraints/), [redes internas](https://docs.docker.com/reference/compose-file/networks/#internal), [Data Protection](https://learn.microsoft.com/en-us/aspnet/core/security/data-protection/configuration/overview?view=aspnetcore-10.0), [pg_restore](https://www.postgresql.org/docs/18/app-pgrestore.html).
