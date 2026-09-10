# Preparação operacional Web/Android

**Não executar contra alojamento externo antes da aprovação em HO-012.** [Proposta/custos/gates](../../docs/HO-012-PILOT.md). Três contentores: Caddy, API/Web/worker e PostgreSQL. Sem Kubernetes, serviços Microsoft, registo público ou deployment automático. Comandos Linux na raiz do repositório, Docker Engine + Compose **2.24.4 ou posterior** (`!override` no ensaio), Python 3.10+, OpenSSL e restic **0.19.1** para backup externo. Builds usam versões fixadas no Dockerfile e locks.

## Preparar uma imagem, sem publicar

```sh
git rev-parse HEAD
docker build -f infra/pilot/Dockerfile -t homeoffice:COMMIT_SHA .
docker image inspect homeoffice:COMMIT_SHA --format '{{.Id}}'
docker save -o /CAMINHO/PRIVADO/homeoffice-COMMIT_SHA.tar homeoffice:COMMIT_SHA
sha256sum /CAMINHO/PRIVADO/homeoffice-COMMIT_SHA.tar
```

Substituir `COMMIT_SHA` pelo SHA aprovado. Não enviar a imagem para registo público. Após aprovação, transferir arquivo/configuração por SSH e confirmar hash; `docker load -i ...` no host. O build deve ocorrer fora da VM pequena. CI executa o build/ensaio, sem credenciais de deploy, SSH, publish, APK artifact ou trigger de release. Usar exatamente a imagem ensaiada; guardar a anterior para rollback.

## Configuração privada por ambiente

No host autorizado, escolher **Staging** ou **Production** e manter esse nome: ele faz parte da identidade criptográfica. Nunca usar Development fora da máquina local. Criar `/srv/homeoffice-<ambiente>/private` com acesso só do operador e UID/GID 1654 da app; diretório `keys` gravável por 1654. Ficheiros privados `0640 root:1654`, diretório `0750 root:1654`, keys `0700 1654:1654`. Certificados/passwords diferentes nos dois hosts. Volume PostgreSQL fica privado no Docker.

Copiar `environment.example` para um ficheiro **fora do checkout**, substituir hostname, ambiente, imagem e caminho. Copiar [exemplo de aplicação](../../apps/api/src/HomeOffice.Api/appsettings.Production.example.json) para `private/application.json`. Ficheiros:

| Ficheiro externo | Utilização |
|---|---|
| `application.json` | DB `Host=database;Database=homeoffice;Username=homeoffice;Password=...`; origem HTTPS/host/proxy; SMTP; paths DP; worker ativo; FCM Disabled até configuração autorizada |
| `database-password` | Password aleatória da role `homeoffice`, igual à connection string; sem acesso superuser/CREATEDB/CREATEROLE |
| `postgres-password` | Password administrativa separada, só operador; não usada pela API |
| `protection.pfx` | Certificado RSA privado para cifrar o key ring, protegido por password; não é o certificado TLS público |
| `keys/` | Key ring persistente; não apagar ficheiros antigos durante rotação |
| `firebase-admin.json` | `{}` enquanto FCM Disabled; depois de autorizado, credencial do projeto do ambiente com permissões mínimas de envio |
| `bootstrap.json` | Nome da organização, nome/email do administrador aprovado, sem password; nunca dados de dev |

O certificado pode ser gerado com OpenSSL, RSA 3072, finalidade Data Protection, export PKCS#12 com password por `env:`/ficheiro privado. Guardar PFX + password em cofre/backup independente do host; nunca argumentos contendo passwords reais em histórico de shell. O piloto usa um certificado estável e a rotação normal do key ring mantém esse protetor. A configuração atual aceita um PFX: não substituir por uma nova chave RSA sem preparar e ensaiar a leitura dos certificados antigos. Perder chave/password inviabiliza sessões e endereços FCM cifrados; restaurar DB sozinha não repara isso.

`HO_CONFIG_FILE=/run/config/application.json` é carregado pelo host; `appsettings.Local.json` só em Development. O exemplo contém `REPLACE` deliberadamente rejeitado. `AllowedHosts` é o hostname da origem sem porta. `Hosting:KnownProxies=10.77.0.2` coincide com Caddy; não limpar a restrição nem confiar em todas as redes. A sub-rede fixa exige hosts separados; escolher outra sub-rede se colidir e atualizar ambos os lados antes de ensaiar. Não usar CDN/proxy adicional sem rever a cadeia de confiança.

Firewall cloud: apenas TCP 80/443 públicos; SSH 22 só do IP administrativo, chave SSH, sem password/root remoto. PostgreSQL e app não publicam portas. Caddy gere HTTPS para o domínio DNS aprovado; a app conserva cookies Secure/HttpOnly, CSRF e recusa API HTTP. Não expor health, OpenAPI, Mailpit, logs ou base de dados. `/api/v1/admin/*` mantém autorização de administrador de contas; não é diagnóstico anónimo. Sem CORS entre origens. Nunca publicar o `verify.yaml` temporário.

## Primeiro arranque e atualização explícita

```sh
docker compose --env-file /srv/homeoffice-staging/environment -f infra/pilot/compose.yaml up -d --wait database
sudo python3 infra/pilot/operations.py --env-file /srv/homeoffice-staging/environment migrate
docker compose --env-file /srv/homeoffice-staging/environment -f infra/pilot/compose.yaml up -d --wait app edge
docker compose --env-file /srv/homeoffice-staging/environment -f infra/pilot/compose.yaml ps
```

A inicialização de PostgreSQL cria apenas uma base/role. Migrações não são executadas pelo arranque normal. Só depois de validar SMTP e com destinatário autorizado:

```sh
docker compose --env-file /srv/homeoffice-staging/environment -f infra/pilot/compose.yaml run --rm --no-deps app --bootstrap-admin /run/config/bootstrap.json
```

Formato de `bootstrap.json`: `{"organizationName":"Organização piloto","email":"admin@example.invalid","displayName":"Administrador"}` — substituir privadamente. Ativação chega pelo SMTP configurado; o administrador cria apenas os participantes autorizados na app e atribui relação chefia/colaborador. Bootstrap recusa organização existente. Se SMTP falhar depois de criar o administrador, corrigir SMTP e pedir novo código de ativação pela app; não repetir criando outra organização. Produção rejeita `--provision-dev` e configuração de tempos de sessão/limites/captura de email de teste.

Atualização: confirmar backup restaurável, colocar app em manutenção (`stop app`), snapshot, aplicar `migrate` com a imagem candidata e voltar a `up --wait`. `snapshot` só retoma a app se ela estava a correr ao iniciar o comando; preserva uma paragem administrativa. Comparar migrações com a imagem anterior; reverter só imagem é seguro apenas com esquema compatível. Caso contrário, restaurar para nova base, verificar, e trocar configuração durante manutenção. Nunca fazer downgrade de esquema automático. HO-012 não acrescenta migrações de negócio.

## Backup, restauro e isolamento

```sh
sudo python3 infra/pilot/operations.py --env-file /srv/homeoffice-staging/environment snapshot /srv/homeoffice-staging/exports/UTC_UNICO
sudo python3 infra/pilot/operations.py --env-file /srv/homeoffice-staging/environment restore /srv/homeoffice-staging/exports/UTC_UNICO ho012_restore_ENSAIO
```

Substituir o sufixo por letras minúsculas/números/underscore. `snapshot` pára brevemente a app/worker, exporta PostgreSQL custom com `pg_dump`, copia chaves cifradas/PFX e manifesto com hashes, contagens, imagem e ambiente. O diretório de destino deve ser novo. Guardar também inventário de configuração e passwords no cofre; não entram no manifesto. Nenhuma configuração privada é impressa. Executar como operador root no host Linux para ler keys 0600. `operation-error.log` é privado e pode conter diagnóstico sensível; não anexar ao GitHub.

O restauro **recusa nomes fora de `ho012_restore_*` e bases existentes**, usa `pg_restore --exit-on-error`, verifica hashes e contagens de todas as tabelas. Não apaga nem sobrescreve a base em uso. Um restauro falhado deixa o alvo isolado para diagnóstico. Depois, numa app isolada sem email/FCM externo, usar a imagem e ambiente do manifesto, chaves/PFX recuperados, password do cofre e a nova connection string. Validar login/refresh/cookie, membros e datas/tarefa conhecida. Confirmar que dados e sessões persistem após reinício. Só trocar a origem de produção após estas verificações e autorização operacional. O ensaio automático faz isto com dados sintéticos; não se copia a base real para staging.

Restic cifra a exportação antes do armazenamento externo; preparar repositório SFTP e subconta separados por ambiente, SSH host key verificada e `RESTIC_PASSWORD_FILE` fora do repo. Inicializar uma vez após aprovação. Com as variáveis privadas configuradas no host:

```sh
restic backup /srv/homeoffice-staging/exports/UTC_UNICO --tag homeoffice-staging
restic check
restic forget --tag homeoffice-staging --keep-daily 7 --keep-weekly 4 --prune
restic restore latest --tag homeoffice-staging --target /srv/homeoffice-staging/recovered-UTC_UNICO
```

Não executar `forget/prune` antes de confirmar política e restauro; remover exportações locais somente após cópia verificada. `backup-once.sh` e `homeoffice-backup.service/.timer` preparam execução diária **02:00 UTC**, sem sobreposição (`flock`) e ficheiro `last-success`; não foram instalados/ativados. Configurar `/etc/homeoffice/backup.env` privado com `HO_CHECKOUT=/opt/homeoffice`, `HO_ENV_FILE`, `HO_EXPORT_ROOT`, `RESTIC_REPOSITORY`, `RESTIC_PASSWORD_FILE` e SSH conhecido. No host aprovado, instalar units em `/etc/systemd/system`, executar primeiro `systemctl start homeoffice-backup.service`, verificar restauro, e só então `systemctl enable --now homeoffice-backup.timer`. Vigiar falha do serviço e idade >26 h de `last-success`; monitor/alerta externo ainda exige configuração autorizada. O script não elimina retenção/exportações automaticamente. Proposta de retenção/RPO/RTO em HO-012-PILOT.md. As sete cópias do host são complemento; volumes anexados Hetzner não entram no backup do servidor. O desenho usa disco local do servidor. Host comprometido pode comprometer backups acessíveis: guardar acesso de recuperação/chave restic fora dele e cópia independente periódica.

## Worker e diagnóstico privado

`restart: unless-stopped` mantém API/worker e DB após reboot; ativar serviço Docker no host. Confirmar reboot real depois do deploy. Readiness verifica DB/esquema; liveness apenas host HTTP. Um container unhealthy não é reiniciado automaticamente pelo Docker: operador inspeciona e resolve, não confiar só na restart policy. Preparar monitor externo de HTTPS/login e alerta de ausência de backup depois de autorizado.

```sh
docker compose --env-file /srv/homeoffice-staging/environment -f infra/pilot/compose.yaml exec app bash /app/healthcheck.sh
sudo python3 infra/pilot/operations.py --env-file /srv/homeoffice-staging/environment queues
```

O relatório mostra estado, contagem, tentativas máximas e idade pendente, sem nomes/conteúdo/tokens. Outbox: 0 Pending, 1 Leased, 2 Processed, 3 Ignored, 4 Failed. Push: 0 Pending, 1 Leased, 2 ProviderAccepted, 3 Simulated, 4 Suppressed, 5 Failed. Alertar atraso >5 min ou failed >0. Consultar também disco, CPU/RAM e saúde dos três processos; logs Docker são limitados a 3×10 MB por serviço. Para reprocessar falha, usar o endpoint administrativo existente após diagnóstico e confirmação de acesso atual; não editar outbox em massa. ProviderAccepted não prova entrega ao dispositivo. Não reabrir histórico de testes nem importar dispositivos para produção.

Email: validar DNS/DKIM/DMARC/remetente aprovado, STARTTLS com certificados válidos, ativação, recuperação, código expirado/reutilizado e entrega em duas caixas reais autorizadas. Mailpit só no ensaio temporário, não no Compose piloto. Uma captura local não é prova de entrega real.

## Android privado

Java/Flutter/SDK conforme apps/mobile/README.md. Manter package `dev.homeoffice.homeoffice_mobile`. Criar chave real apenas na fase aprovada, por keytool interativo ou passwords via ambiente privado; guardar keystore e passwords em duas localizações seguras. Perder a chave impede atualizações compatíveis. Aumentar `--build-number` monotonamente e conservar chave/package. Exemplo **fora do repo**, com barras `/` em paths Windows:

```properties
storeFile=/CAMINHO/PRIVADO/homeoffice-pilot.jks
storePassword=REPLACE_PRIVATELY
keyAlias=homeoffice
keyPassword=REPLACE_PRIVATELY
```

```sh
export HO_ANDROID_SIGNING_PROPERTIES=/CAMINHO/PRIVADO/signing.properties
export HO_FIREBASE_ANDROID_CONFIG=/CAMINHO/PRIVADO/google-services.json
cd apps/mobile
flutter pub get --enforce-lockfile
flutter build apk --release --build-number=NUMERO_SEGUINTE --dart-define=API_BASE_URL=https://app.DOMINIO --dart-define=FCM_ENABLED=true
apksigner verify --verbose build/app/outputs/flutter-apk/app-release.apk
```

Confirmar projeto Firebase, certificado SHA-256 e URL corretos antes de distribuir pelo grupo privado. Release exige URL HTTPS e não inclui cleartext debug. Sem ficheiro de assinatura o build normal continua **unsigned**, sem fallback para chave debug. A CI usa key descartável, nunca apropriada ao piloto. Instalação existente com chave debug: preservar; usar telefone/perfil separado. Não desinstalar, limpar dados nem ativar restore automático para contornar assinaturas. Depois de autorizado, provar instalação física, atualização que preserva sessão, login e workflows, FCM foreground/background/cold start, recusa de permissão e logout. Sem loja pública/tag nesta preparação.

## Verificação reproduzível

```sh
sudo -E python3 infra/pilot/verify.py
python scripts/check_android_signing.py
```

O primeiro comando usa portas loopback 18443/18025, projeto/volumes e CA novos, sem credenciais reais; termina somente os recursos que criou. Requer Linux/Docker e falha se indisponíveis. Usa Production, migração duas vezes, zero contas iniciais, bootstrap explícito sintético, SMTP autenticado STARTTLS isolado, Web/API/CSRF/cookies, pedido e worker, reinício, backup cifrado restic local e restauro para nova DB, conteúdo e sessões recuperados, recuperação de password. Não imprimir mensagens/credenciais. CI guarda apenas recibo sanitizado; não anexar arquivos privados. O segundo verifica compilação/assinatura com chave descartável, sem instalar nem enviar APK. Os quatro checks core permanecem obrigatórios; iOS não é executado.
