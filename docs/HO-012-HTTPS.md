# HO-012 — Preparação HTTPS no Pi

2026-09-12. PR #37 **draft**, issue #13 aberta. O responsável aceitou manualmente o percurso no Pi: titular submete, chefe distinto aprova, calendário e notificação refletem a decisão. É aceitação parcial do ensaio, não lançamento V1 nem validação HTTPS externa.

## Estado observado e limite da autorização

Plugin Cloudflare autorizado: zona **ferbatech.com ativa**; não existiam registos exatos `homeoffice.ferbatech.com` nem `*.ferbatech.com`. O túnel `nas-connectivity-test` estava down e não foi alterado. Preparado um túnel remoto separado **homeoffice-pi**, UUID **cc5b6025-b9fc-4d54-9854-5ed3aee17cad**, sem conector, sem rotas privadas e apenas resposta 404. Nenhum token foi obtido ou impresso. Nenhum DNS/hostname publicado. Certificado Universal ativo para apex/*.ferbatech.com (expiração observada 2026-12-07); cobre homeoffice.ferbatech.com, mas não cobre automaticamente staging.homeoffice.ferbatech.com. Não publicar staging nesta etapa. Inventário: SSL full, Always Use HTTPS off, Browser Integrity Check on, security medium, cache aggressive; sem Page Rules, rotas Workers ou rulesets de zona personalizados nas fases pretendidas. Access devolveu not_enabled; não foi ativado e não é necessário para Identity.

SSH Pi confirmado nesta etapa: ~3284 MiB disponíveis, 48 GiB livres e 1 MiB de zram ocupado. A interação sudo posterior permitiu concluir a validação privada no Pi; a aplicação regressou à configuração local original. A primeira tentativa foi recusada antes do backup/troca de configuração por uma comparação incorreta de identificadores Docker (detalhe abaixo). Não atribuir ao Pi os resultados do runner ARM64.

## Configuração concreta para revisão

Manter `/home/dennyum/ho012-pi-trial`, projeto `homeoffice-pi-trial`, base, volumes, contas, PFX e key ring atuais. [prepare_https.py](../infra/pi/prepare_https.py) cria apenas `private/https` novo, sem sobrescrever originais. Não cria token nem faz chamadas de rede. O perfil ASP.NET permanece **Staging** para preservar o propósito Data Protection existente; o hostname não transforma o ensaio em produção.

| Alteração proposta no Pi | Valor |
|---|---|
| Quinto serviço | cloudflared 2026.9.1, Linux ARM64 nativo, referência imutável e RepoDigests verificados contra a CI, mais OS/arquitetura |
| Limites adicionais | 128 MiB RAM, 128 MiB memory+swap (zero swap), 0,25 CPU, 64 PIDs |
| Total dos cinco serviços | 1600 MiB / 3,25 CPU; margem medida anteriormente >3 GiB, medir novamente com conector real |
| Reinício | `unless-stopped` nos cinco serviços; sem auto-update de imagens |
| Rede de origem nova | `homeoffice-pi-trial_tunnel_origin`, internal, 10.78.18.0/29; Caddy .2, conector .3 |
| Saída do conector | `homeoffice-pi-trial_tunnel_egress`, bridge própria com subnet escolhida pelo Docker após inventário |
| Portas no Pi | Nenhuma publicada; sem host network ou socket Docker |
| Token | `private/https/tunnel-token`, UID/GID 65532, modo 0400, diretório 0700; bind individual readonly, `--token-file` |
| Origem | `https://10.78.18.2:443`, SNI e Host `homeoffice.ferbatech.com`, CA privada explícita, `noTLSVerify=false` |

Apenas conector e Caddy partilham a rede nova. O conector não pertence à rede de PostgreSQL/Mailpit/API. A saída do conector requer DNS e TCP/UDP 7844; não implica port forwarding no router. Não configurar rotas CIDR/WARP/SSH. Logs warning com rotação 2×5 MiB; sem access log ou debug com credenciais. O endpoint local de métricas do conector fica em 127.0.0.1:2000 **dentro** do contentor.

Novo certificado de origem, privado, com 30 dias de validade, separado do SMTP e de Data Protection. A publicação exige verificar validade e planear renovação antes do vencimento. Não é certificado público Cloudflare Origin CA: a CA local é confiada explicitamente pelo conector. O certificado público do edge Cloudflare só será verificado depois da publicação autorizada.

## Autenticação, origem e confiança

O overlay monta uma cópia de application.json com `AllowedHosts=homeoffice.ferbatech.com`, `Hosting.PublicOrigin=https://homeoffice.ferbatech.com`; conserva `KnownProxies=10.78.17.2` e ForwardLimit=1. Caddy aceita o site apenas do IP privado .3 do conector, interpreta CF-Connecting-IP apenas desse proxy e substitui X-Forwarded-For por um único IP validado. Ignora Forwarded recebido e força Host e protocolo HTTPS para o backend. Outros peers com headers forjados recebem 403.

Web e API partilham origem; sem CORS permissivo. Cookies Identity HttpOnly/Secure/SameSite=Lax e cookie CSRF Secure/Strict existentes; operações Web exigem X-CSRF-TOKEN. Cache-Control no-store na origem, incluindo respostas autenticadas. Antes de publicar, verificar que regras Cloudflare existentes não forçam cache HTML/API; preparar exceção do hostname se necessário. Não introduzir Cloudflare Access/browser challenge como autenticação obrigatória, pois quebraria os clientes bearer existentes. Identity mantém convites, ativação e autorização; não há endpoint de registo público.

Android mantém tokens opacos e refresh do framework, base `https://homeoffice.ferbatech.com`, certificado público normalmente confiado pelo Android. Testes HTTP de login/refresh não equivalem a ensaio num dispositivo físico. A interface de Administração da **aplicação** continua autorizada só para administradores ativos; não expõe DSM, Docker, Mailpit ou SSH.

## Plano exato da publicação — ainda NÃO executar

1. Confirmar novo backup DB/configuração/PFX/keys e preservar compose/Caddy originais. Validar origem privada; repor automaticamente acesso localhost no fim. Verificar imagem/digest, colisões, TLS, CSRF, bearer e headers antes de pedir autorização final.
2. Após autorização, guardar token do túnel **homeoffice-pi** diretamente em ficheiro privado. Nunca colocar token em argumento, variável publicada, histórico, Git ou chat. Entrada local oculta/ficheiro transferido por SSH; não usar token do NAS. Conferir ownership 65532:65532 e 0400.
3. No diretório do ensaio, aplicar a configuração já validada:

```sh
sudo docker compose -p homeoffice-pi-trial -f compose.yaml -f private/https/compose.json --profile publish up -d --pull never
```

4. O túnel permanece 404-only durante o arranque. Confirmar conexão saudável, limites e restart. Só após autorização explícita trocar a configuração remota pelo ficheiro `private/https/route.json`: bloquear `/health`, `/openapi`, `/metrics`; encaminhar apenas o hostname exato para HTTPS Caddy; regra final `http_status:404`, warp-routing disabled.
5. Criar **apenas** este registo, sem alterar os restantes:

```json
{"type":"CNAME","name":"homeoffice.ferbatech.com","content":"cc5b6025-b9fc-4d54-9854-5ed3aee17cad.cfargotunnel.com","proxied":true,"ttl":1}
```

Inspecionar colisões novamente antes de criar; não substituir outro registo. `staging.homeoffice.ferbatech.com`, apex/MX/TXT e túnel NAS ficam intactos. Preparar HTTPS-only para este hostname, nunca uma alteração global da zona sem revisão. As regras exatas estão em [cloudflare-publication.json](../infra/pi/cloudflare-publication.json): redirect 308 HTTP→HTTPS apenas neste hostname, cache bypass no hostname e SSL strict; Browser Integrity Check desativado apenas em /api/ para clientes nativos. Não desativar WAF/DDoS nem alterar opções globais. Reconsultar regras e acrescentar por ref estável, sem substituir listas existentes; guardar IDs criados para recuperação. As permissões de escrita destas fases e eventuais desafios a clientes legítimos permanecem por validar na publicação. Não publicar caso os gates HTTPS/cache falhem. Nenhum contrato ou serviço pago necessário para a preparação.

6. Validar certificado público/cadeia/hostname, HTTP→HTTPS antes de login, ausência de cache de respostas privadas, Web cookie/CSRF/logout, Android bearer, isolamento e endpoints privados. Medir conector e reinício sem PC. Esses testes são **externos pendentes**; Mailpit continua capturado, não convidar pessoas reais.

## Testes e recuperação

[verify_https.py](../infra/pi/verify_https.py) testa origem TLS real/Caddy/API/PostgreSQL com cliente num namespace de rede simulando o conector, sem token ou saída Cloudflare. Verifica CLI/ingress ARM64 offline, configuração efetiva, login/logout cookie/CSRF, login/refresh bearer, negação anónima, ausência de registo, endpoints privados e rate limit imune a XFF forjado. Repõe os mounts/configuração originais no finally. CI executa-o após backup/restauro do ensaio descartável; não executa esse harness destrutivo no Pi.

[validate_https_on_pi.py](../infra/pi/validate_https_on_pi.py) é o wrapper separado do Pi: recusa pasta HTTPS existente/colisões, compara o digest de repositório fixado e Linux ARM64 com a evidência da CI, faz novo backup antes da troca temporária e restaura acesso local. Exige sudo interativo. O backup é local ao Pi; copiar de forma cifrada para o PC antes da publicação. A cópia manual anterior permanece protegida e não equivale a backup externo automatizado.

Em caso de falha durante o teste privado ou para regressar ao acesso SSH:

```sh
cd /home/dennyum/ho012-pi-trial
# Após eventual publicação, primeiro repor o túnel em blocked-route.json (404-only).
sudo docker compose -p homeoffice-pi-trial -f compose.yaml -f private/https/compose.json --profile publish stop cloudflared
sudo docker compose -p homeoffice-pi-trial -f compose.yaml up -d --pull never app edge database mailpit
sudo sh trial.sh health
```

Remover somente o CNAME criado, identificado pelo seu ID e conteúdo exatos, se a rota já tiver sido publicada. Não apagar volumes, base, imagens, PFX, keys, backups ou outros registos. As configurações originais não são sobrescritas pelo overlay. Na origem pública os cookies novos pertencem ao novo hostname; é esperado voltar a entrar. As identidades/passwords/dados continuam iguais.

## Falta para concluir HO-012

- Validação/publicação HTTPS autorizada e aceitação externa; destino definitivo e separação staging/produção, retenção e renovação de certificados.
- SMTP real autorizado: entrega, falhas/retry, reputação e convite/aceitação; não confundir Mailpit com envio real.
- Backups cifrados externos **automatizados**, retenção/RPO/RTO e restauro exercitado; cópia manual no PC é apenas uma salvaguarda adicional.
- Monitorização/alertas acionáveis de disponibilidade, worker/falhas, capacidade, backups e certificados; operação/atualizações do Pi/microSD.
- Android físico, assinatura e distribuição privada autorizada; convites Firebase para APK separados de acesso Identity.
- Piloto e aceitação final core, com critérios/riscos revistos. iOS/Outlook adiados. Sem merge/release enquanto incompleto.

Fontes oficiais consultadas em 2026-09-12: [token-file](https://developers.cloudflare.com/tunnel/reference/run-parameters/), [TLS da origem](https://developers.cloudflare.com/learning-paths/clientless-access/connect-private-applications/best-practices/), [cloudflared 2026.9.1](https://github.com/cloudflare/cloudflared/releases/tag/2026.9.1), [Caddy proxies](https://caddyserver.com/docs/caddyfile/options#trusted-proxies), [headers Caddy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#headers), [ASP.NET forwarded headers](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/proxy-load-balancer?view=aspnetcore-10.0).

Fontes complementares: [redirect API](https://developers.cloudflare.com/rules/url-forwarding/single-redirects/create-api/), [cache rules API](https://developers.cloudflare.com/cache/how-to/cache-rules/create-api/), [configuration rules](https://developers.cloudflare.com/rules/configuration-rules/settings/). Propostas locais, nenhuma regra aplicada.

Diagnóstico inicial da nova CI: o teste esperava 405 num POST de registo inexistente; a API respondeu corretamente 404. Expectativa corrigida para verificar o contrato real, sem mapear registo nem enfraquecer autorização/CSRF.

## Validação no Pi e correção de identidade Docker — 2026-09-12

No Pi, Docker 29/containerd devolveu `Id=sha256:b269e8abd07a5bf6f3f4be65d5050b2174eca89c56a0241a8ff32a16aec454e4`; no armazenamento clássico da CI, Id era o digest de configuração `sha256:275625bde2cb95151140b12af359f6e744dca5a45cbd357a8566a8438c853e51`. **RepoDigests era idêntico nos dois**, Linux ARM64. Não era uma imagem AMD64 nem houve prova de conteúdo diferente. A recusa inicial preservou a stack e ocorreu antes do backup/troca da origem.

A referência agora é `cloudflare/cloudflared@sha256:b269e8abd07a5bf6f3f4be65d5050b2174eca89c56a0241a8ff32a16aec454e4`. Pull por digest e validação do RepoDigest completo + OS/ARM64, sem aceitar apenas um Id coincidente. Testes cobrem os dois formatos e recusam digest ausente/diferente, repositório diferente, Windows e AMD64. A CI exporta também uma tag de transporte do conector; a execução continua fixada pelo digest do fornecedor.

Com a autorização sudo existente, o ensaio privado foi executado autonomamente no Pi: novo backup DB/config/PFX/keys e compose/Caddy originais; CLI ARM64/ingress offline; TLS privado CA/SNI; Secure/HttpOnly/SameSite; CSRF/login/logout; bearer/refresh; leitura anónima 401; registo/health/openapi/metrics indisponíveis; headers falsificados recusados e rate limit preservado. Conector simulado num namespace isolado, **sem conexão Cloudflare ou token**, sem teste Android físico. Acesso localhost restaurado e saúde confirmada no fim.

Backup novo `20260911T235340Z-71752` no diretório privado de backups do ensaio. Cópia independente AES-256-GCM no diretório privado do PC, decriptação e todos os hashes internos verificados (incluindo SQL, PFX/key ring, configuração e routing originais). Backup manual, não automatizado. Configuração real, recibo e chave de cópia apenas locais; tokens/códigos/passwords não publicados. Não é necessário repetir o script de validação já concluído.

Fontes: [Docker containerd store](https://docs.docker.com/engine/storage/containerd/), [implementação oficial de inspect](https://github.com/moby/moby/blob/master/daemon/containerd/image_inspect.go), [referências imutáveis por digest](https://docs.docker.com/engine/containers/run/#image-digests). Consultadas em 2026-09-12. O próximo gate é autorização explícita para publicar o hostname e validar o percurso externo; não ocorreu nesta correção.
