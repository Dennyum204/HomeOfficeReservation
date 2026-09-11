# HO-012 — Ensaio NAS pronto para revisão, ainda não instalado

**Histórico preservado:** o responsável mudou o ensaio para o [Raspberry Pi ARM64](../pi/README.md). Não executar esta preparação AMD64 no Pi; NAS permanece inalterado.

[Proposta atual](../../docs/HO-012-PILOT.md), [decisão](../../docs/adr/ADR-018-nas-trial.md), [acesso implementado](../../docs/HO-012-PRIVATE-ACCESS.md). Estes comandos são o plano concreto para a próxima etapa autorizada. **Não executar start/load/bootstrap no NAS antes da revisão do inventário e da aprovação da instalação.** Nenhum comando modifica DSM, router, DNS ou Cloudflare.

**Inventário direto concluído em 2026-09-11:** [resultados e condições por resolver](../../docs/HO-012-NAS-INVENTORY.md). Engine 20.10.3, sem quotas CPU CFS, encaminhamento SSH desativado, RAM abaixo da margem proposta e arrays de sistema/swap degradados. Os comandos de instalação abaixo permanecem uma proposta, não uma sequência atualmente executável no host. Nenhuma proteção foi retirada e HomeOffice continua por instalar.

## 0. Primeiro passo: inventário só de leitura

Na sessão SSH já autorizada (`ssh OverseekersAdmin@192.168.1.102`), executar o conteúdo de [inventory.sh](inventory.sh). Se Docker negar acesso, usar a sessão sudo de operador apenas para as mesmas leituras; não alterar grupos/serviços. Não partilhar logs completos com dados privados. O script imprime versão, CPU/kernel, memória/swap/disco, limites do Engine, carga, redes/rotas e cauda de dmesg. Recusa de leitura de dmesg não equivale a ausência de OOM.

A instalação futura requer SSH com chave/credenciais locais, permissões Docker/sudo do operador apenas para o projeto, escrita no novo diretório do volume escolhido e encaminhamento SSH (direct-tcpip) para a rede do ensaio. Se algum acesso faltar, registar; não alterar sshd/DSM nesta etapa.

O IP foi observado por DHCP; confirmar destino/host key habitual antes de autenticar. O timeout inicial foi ultrapassado numa sessão posterior autorizada; shell/sudo funcionam, mas AllowTcpForwarding=no impede o acesso Web proposto. Não instalar ou abrir portas para contornar. Password SSH nunca entra nos ficheiros do projeto, logs ou tracking; usar apenas o pedido de autenticação local.

Confirmar x86_64, Engine >=20.10.10, Compose 2.x ou avaliar o 1.28.5 legado, cgroups com MemoryLimit/SwapLimit/CpuCfsQuota verdadeiros. Engine novo é necessário mas não suficiente: kernel/libseccomp do fabricante precisam de executar as imagens Noble/Bookworm. Docker 20.10.3, presente em notas antigas Synology, fica abaixo do piso do script. Parar e discutir compatibilidade; não atualizar DSM/Engine, instalar WSL no NAS ou retirar seccomp.

Escolher volume existente com >=8 GiB livres para archive/imagens, dados e duas cópias pequenas; confirmar folga após obter os tamanhos reais do manifesto. Exigir inicialmente >=1100 MiB MemAvailable estável e ausência de pressão de swap. Capturar baseline durante utilização normal DSM. Confirmar que 10.78.16.0/24 não colide com LAN/VPN/redes Docker. Não alterar automaticamente a rede ou limites para fazer o teste passar.

## 1. Preparação no PC e imagens fora do NAS

Ferramentas no PC/runner: Git/gh autenticado, Python >=3.11 para o harness, OpenSSL; build exige Docker Linux amd64. **No NAS só Docker/Compose e utilitários DSM existentes** (sh, awk, tar, sha256sum, SSH), sem SDK, Node, .NET instalado no host, Python, restic, Redis ou monitorização nova.

O check adicional `nas-preparation` compila o Dockerfile do piloto no head real do PR, executa o Compose desta pasta e exporta quatro imagens. `ho012-nas-images-<SHA>` contém `images.tar`, `SHA256SUMS` e `manifest.json`; retenção 7 dias. São artifacts de ensaio sem credenciais, sem release/registry/APK. `ho012-nas-runner-evidence` contém recibo sanitizado e métricas **do runner, não do NAS**. Se expirarem, repetir o check do mesmo commit e verificar novamente manifesto/checks; não usar um archive de outro commit.

Tags próprias por commit evitam substituir tags existentes de PostgreSQL/Caddy/Mailpit no NAS. Exportação inclui os runtimes Linux amd64; SDKs/build stages não são transferidos. Não executar `docker pull`/build no NAS. Manifesto regista IDs, digests, tamanhos e SHA do archive.

PowerShell no checkout atualizado, substituindo RUN pelo run efetivamente verde:

```powershell
$sha = git rev-parse HEAD
$bundle = "C:/Work/Private/HomeOfficeReservation/HO012-NAS-$sha"
gh run download RUN --repo Dennyum204/HomeOfficeReservation --name "ho012-nas-images-$sha" --dir "$bundle/images"
Get-FileHash "$bundle/images/images.tar" -Algorithm SHA256
# Comparar com manifest.json; confirmar commit, linux/amd64 e checks do head.
python infra/nas/prepare.py --destination "$bundle/trial" --image "homeoffice:ho012-$sha"
```

O gerador recusa diretório existente e configuração dentro do repositório. OpenSSL pode ser o já preparado com Git for Windows (`C:/Program Files/Git/usr/bin` no PATH desta sessão). Aplicar ACL privada ao diretório novo (utilizador atual, SYSTEM e Administrators); não alterar ACL de pastas existentes. Credenciais apenas em `trial/private/CREDENCIAIS.json`; são passwords sintéticas propostas, **contas ainda não criadas/ativadas**. Aplicação e certificado DP usam passwords distintas; DP e TLS usam chaves RSA distintas. PFX/password e key ring antigos têm de sobreviver a reinícios.

Depois de rever os ficheiros, criar no PC um arquivo privado separado, nunca artifact do GitHub:

```powershell
tar -cf "$bundle/trial-private.tar" -C "$bundle/trial" .
Get-FileHash "$bundle/trial-private.tar" -Algorithm SHA256
```

## 2. Recursos e instalação proposta — só depois de aprovar

O caminho abaixo é um **exemplo sujeito ao volume confirmado**, não prova de `/volume1` livre. Reservar um diretório novo `/volume1/docker/ho012-nas-trial`; recusar se já existir. Criar só esse diretório, modo 0700, e transferir por SCP/SFTP do PC as imagens/manifesto e o arquivo privado. Não enviar dados/configuração de HO-013/014/015/016. Não transferir a pasta `.git`.

```sh
# No NAS, apenas após confirmar volume/acesso e autorizar esta instalação:
umask 077
mkdir /volume1/docker/ho012-nas-trial
chmod 700 /volume1/docker/ho012-nas-trial
```

```powershell
scp "$bundle/images/images.tar" "$bundle/images/SHA256SUMS" "$bundle/images/manifest.json" "$bundle/trial-private.tar" OverseekersAdmin@192.168.1.102:/volume1/docker/ho012-nas-trial/
```

```sh
cd /volume1/docker/ho012-nas-trial
sha256sum -c SHA256SUMS
sha256sum trial-private.tar
# Comparar o segundo hash com o PC antes de extrair o arquivo criado por si.
tar -xf trial-private.tar
sudo docker load -i images.tar
sudo sh trial.sh validate
sudo sh trial.sh start
sudo sh trial.sh health
sudo sh trial.sh bootstrap
```

`start` verifica imagens importadas, ajusta ownership **apenas no diretório privado deste ensaio**, inicia PostgreSQL/Mailpit, para só a app deste projeto, migra explicitamente e inicia API/worker/edge. Não provisiona contas automaticamente. `bootstrap` cria titular administrador+colaborador sem password e entrega o código no Mailpit; repetir não duplica o titular nem ativa por si.

O identificador aleatório HO_TRIAL_ID identifica os volumes/rede; scripts recusam recursos retidos de outro ensaio mesmo com o mesmo nome de projeto. Não substituir esse identificador para reutilizar dados.

Recursos exatos: quatro contentores Compose (nomes concretos variam entre v1/v2), rede `homeoffice-nas-trial_trial`, volumes `homeoffice-nas-trial_database` e `homeoffice-nas-trial_mail`, key ring bind `private/keys`, ficheiros/backups locais e quatro tags exclusivas `ho012-<SHA>`. Nenhuma porta publicada, socket Docker montado, rede host, acesso a pastas DSM ou dados de outros serviços. Rede interna sem saída e Mailpit sem relay impedem envio real pela stack. Não publicar Mailpit ou PostgreSQL.

## 3. Acesso e percurso manual sintético

No PC, manter esta sessão SSH aberta (as portas são do PC, não publicadas no NAS):

```powershell
ssh -N -o ExitOnForwardFailure=yes -L 127.0.0.1:18443:10.78.16.2:443 -L 127.0.0.1:18025:10.78.16.3:8025 OverseekersAdmin@192.168.1.102
```

Web **https://localhost:18443**; email capturado **http://127.0.0.1:18025**. Identificar o ambiente pela organização **HO-012 ENSAIO NAS — SINTETICO**. A Web exige o certificado local gerado; verificar fingerprint no PC e usar apenas confiança explícita desse certificado/perfil de teste. Não desligar validação TLS globalmente nem importar o certificado em DSM. Não é HTTPS público. Teste por CLI: `curl --cacert <caminho>/trial/private/ca.pem https://localhost:18443/api/v1/workspace`.

1. Abrir Mailpit, email de owner@nas.example; na Web, **Ativar conta** com código e password privada proposta. Se decorrer >1 h, o código pode expirar: usar o percurso de recuperação/reenvio; não editar DB/códigos.
2. Entrar como titular → **Administração** → convidar manager@nas.example com papel gestor, sem administrador. Aceitar num segundo perfil/janela privada, com email capturado e password local de manager. As duas sessões são independentes.
3. Administração → titular → associar a chefia distinta, confirmar impacto. O titular mantém Admin+Employee; não editar os próprios papéis.
4. Titular → Calendário/Pedidos: submeter um dia remoto futuro. Chefia → selecionar titular → Pedidos: aprovar. Voltar ao titular: aprovação e notificação persistente visíveis. Anotar tempos; refresh não duplica dados.
5. Repetir leituras nas duas sessões, verificar aviso de versão desatualizada se aplicável, e recusa de autoaprovação. Mailpit prova captura/aceitação SMTP, não entrega a pessoas reais.

Este ensaio prepara **Web/API** no NAS. Não altera a app/emulador habitual nem distribui APK. A CI Android continua a validar o cliente atual no runner; apontar um dispositivo ao NAS/TLS externo fica para outra etapa autorizada.

## 4. Saúde, memória e persistência

```sh
sudo sh trial.sh health
sudo sh trial.sh metrics
sudo sh trial.sh database-outage-check
# Amostras por 10 minutos, apenas ficheiro privado novo do ensaio:
umask 077
for n in $(seq 1 20); do sudo sh trial.sh metrics; sleep 30; done > private/measurements-10min.txt
sudo sh trial.sh restart
sudo sh trial.sh health
```

Guardar baseline DSM, samples com duas sessões, p95/erros HTTP e 30 min de observação posterior. `metrics` inclui CPU/RAM/PIDs, MemAvailable, swap global, pswpin/out, OOMKilled, reinícios e limites efetivos. Não confundir swap total já ocupado com atividade nova; comparar deltas. Consultar dmesg e Resource Monitor sem alterar DSM; documentar qualquer falta de acesso. Rejeitar se OOM, reinício inesperado, swap crescente ou degradação dos outros serviços. Não extrapolar carga do runner para o Celeron.

Liveness é `/health/live` interno e não testa DB; readiness `/health/ready` exige ligação/migrações. O proxy bloqueia ambos. `database-outage-check`, **só no ensaio aprovado**, para apenas `database` deste projeto, exige liveness 200 e readiness não 200 via exec interno e volta a iniciar a DB. Uma falha conserva o diagnóstico, sem afirmar saúde. A CI exercita a distinção, mas não é medição NAS. Nunca usar `docker stop $(docker ps -q)`.

Após restart: sem nova ativação, as sessões devem funcionar, relação chefia, pedido/decisão, inbox e convites devem permanecer. Verificar emails capturados persistentes. Não apagar key ring, certificados ou volumes para corrigir login.

## 5. Backup local e restauro para base NOVA

```sh
sudo sh trial.sh backup
# Usar o caminho exato impresso; nome novo em cada tentativa:
sudo sh trial.sh restore-new /volume1/docker/ho012-nas-trial/private/backups/TIMESTAMP ho012_restore_manual1
```

Backup faz uma breve pausa só na API/worker, `pg_dump -Fc`, cópia de key ring/PFX/configuração e hashes, depois retoma. Não contém email Mailpit: uma intenção de convite continua na DB; reenvio é o caminho para novo código. `restore-new` verifica hashes e CREATE DATABASE; recusa destino existente, sem DROP/--clean ou sobrescrita da fonte. Falha deixa a base de diagnóstico própria para investigar.

O restauro SQL **não basta**. Para ensaio autenticado, pausar a app, guardar cópia de `private/application.json`, mudar **apenas Database=** para o nome restaurado, preservar Staging/PFX/key ring e reiniciar só a app. Verificar as mesmas sessões, titular/chefia, pedido aprovado e notificações. Repor configuração da base fonte ao terminar, sem apagar a restaurada. Confirmar contagens/hash da tabela e registar tempos/resultado sem payloads. A CI exercita este percurso completo numa base nova e recupera também PFX/key ring. O comando `backup` usa sempre a fonte `homeoffice`: não o usar como política permanente depois de escolher outra base; no ensaio, voltar à fonte antes do próximo backup.

Hashes não cifram. Backups/configuração são privados; uma cópia neste NAS não protege contra perda do NAS. Antes de dados reais é necessária cópia cifrada independente, incluindo key ring, PFX/password e procedimento testado a partir de outro equipamento. Nenhum destino externo/restic/compra está configurado nesta etapa.

## 6. Parar e remover apenas o ensaio

```sh
sudo sh trial.sh stop
# Depois da revisão dos resultados:
sudo sh trial.sh remove-containers
```

O segundo comando remove apenas contentores/rede do projeto e conserva volumes, key ring, ficheiros, backups e imagens. Verificar rótulos antes de remover dados deliberadamente:

```sh
sudo docker volume inspect homeoffice-nas-trial_database homeoffice-nas-trial_mail
# Só após confirmar projeto, backup e intenção de perder exclusivamente dados sintéticos:
sudo docker volume rm homeoffice-nas-trial_database homeoffice-nas-trial_mail
```

Não usar prune, comandos globais ou `rm -rf` de paths calculados. Os ficheiros privados e archives podem ficar preservados até revisão; remoção posterior só pelo caminho absoluto confirmado do ensaio. Não remover imagens se outro contentor as usar. Fechar a sessão SSH de encaminhamento termina o acesso do PC. Não parar o Docker/DSM/NAS.

## Fontes oficiais verificadas em 2026-09-11

- [Synology: release notes Docker/DS218+](https://www.synology.com/en-global/releaseNote/Docker?model=DS218%2B): versões do pacote e Engine; confirmar o instalado.
- [Docker 20.10](https://docs.docker.com/engine/release-notes/20.10/): alteração clone3/seccomp em 20.10.10; [official images/libseccomp](https://github.com/docker-library/official-images/issues/16829): incompatibilidade possível com distribuições novas.
- [.NET 10 plataformas](https://github.com/dotnet/core/blob/main/release-notes/10.0/supported-os.md): imagem suportada não certifica um host DSM.
- [Docker limites](https://docs.docker.com/engine/containers/resource_constraints/), [rede interna Compose](https://docs.docker.com/reference/compose-file/networks/#internal), [save](https://docs.docker.com/reference/cli/docker/image/save/): limites, isolamento e transferência.
- [Mailpit STARTTLS](https://mailpit.axllent.org/docs/configuration/smtp/), [armazenamento](https://mailpit.axllent.org/docs/configuration/email-storage/): captura persistente sem configurar relay.
- [PostgreSQL pg_dump](https://www.postgresql.org/docs/18/app-pgdump.html), [pg_restore](https://www.postgresql.org/docs/18/app-pgrestore.html), [Data Protection](https://learn.microsoft.com/en-us/aspnet/core/security/data-protection/configuration/overview?view=aspnetcore-10.0): cópia lógica e preservação/proteção das chaves.
