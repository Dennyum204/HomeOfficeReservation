# HO-012 — HTTPS público do ensaio no Pi

2026-09-12. Publicação explicitamente autorizada pelo responsável, condicionada aos checks pendentes verdes. Gate cumprido no commit **d232709a2b05741297208c500682d8826b3bbe55**: project-docs, backend-contracts, web, flutter-android e pi-preparation passaram. [Core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34659849179), [documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34659849120). PR #37 permanece **draft**, issue #13 aberta. É um ensaio com contas sintéticas, não lançamento V1.

## Resultado real

**https://homeoffice.ferbatech.com** encaminha apenas Web/API para o Raspberry Pi. O conector corre no Pi; o acesso público não usa o túnel SSH ou qualquer processo do PC. O ecrã Web de login foi aberto no browser real. Contas, passwords, relações, calendário, base e Data Protection foram preservados; o novo hostname exige iniciar uma nova sessão Web. SMTP continua capturado, sem envio real.

Imagens da aplicação/dependências mantidas na revisão ARM64 **21a2f21**: não há diferença no código API/Web/Android ou Dockerfile desde a versão instalada e testada. Conector `cloudflare/cloudflared@sha256:b269e8abd07a5bf6f3f4be65d5050b2174eca89c56a0241a8ff32a16aec454e4`, versão 2026.9.1, `linux_arm64`, quatro conexões Cloudflare observadas. Configuração de publicação e [preparação validada](HO-012-HTTPS.md) são evidências separadas do build.

Os cinco serviços têm `unless-stopped`, limites efetivos totais **1600 MiB / 3,25 CPU**, memory+swap igual a memory, sem portas host. Conector limitado a **128 MiB / 0,25 CPU**, rede de origem com Caddy e bridge de saída próprias; sem ligação à rede da base/Mailpit/API. Token transferido cifrado até ao PC e por SSH para o Pi, sem aparecer em argumentos, chat, logs ou Git; ficheiro final UID/GID 65532, modo 0400, diretório root 0700. Sem alterar sudo, SSH, arranque do Pi, router ou NAS.

## Recursos Cloudflare criados

Zona ferbatech.com; túnel separado **homeoffice-pi**, `cc5b6025-b9fc-4d54-9854-5ed3aee17cad`. Os quatro registos DNS preexistentes foram comparados após a publicação e mantiveram ID, nome, tipo, conteúdo, proxy e TTL. Nenhuma alteração em staging, apex, email, túnel NAS ou configurações globais da zona. Sem Access obrigatório, sem rotas WARP/CIDR ou serviços de infraestrutura públicos.

| Recurso | Identificador / valor |
|---|---|
| CNAME proxied, TTL automático | `homeoffice.ferbatech.com` → `cc5b6025-b9fc-4d54-9854-5ed3aee17cad.cfargotunnel.com` |
| ID do CNAME | `db993c946b640f112474ba149adb9ee4` |
| Ruleset redirect | `5016c8f89e8c4621977bd0d032e1c198` |
| Regra HTTP→HTTPS 308 | `23dfcf826aab450da5dfa41ca1d914ac` |
| Ruleset cache | `a1adc106fd3e46a08cc12884fcc07ed4` |
| Regra cache bypass do hostname | `b69a941bbb324448b9b914c877930b1e` |
| Ruleset configuration | `c66a9c2df67b4b558009ce7392c41160` |
| Regra SSL strict do hostname | `367a057d761843b580be761624c4f8a5` |
| Regra BIC off apenas `/api/` | `635bc34879b94a7caa9a44335056fb8b` |

Valores completos em [cloudflare-publication.json](../infra/pi/cloudflare-publication.json). A API rejeitou a expressão proposta `http.request.scheme` antes de criar recursos; o campo suportado é `not ssl`. Corrigido e aceite sem mudar a finalidade ou o âmbito da regra. Browser Integrity Check continua ativo fora da API: uma leitura urllib com User-Agent padrão recebeu 403; o browser real e o cliente de verificação identificado receberam 200. Não foi desativada proteção global para satisfazer um probe.

Ingress remoto: hostname exato → `https://10.78.18.2:443`, Host/SNI homeoffice.ferbatech.com, `caPool=/etc/cloudflared/origin.pem`, `noTLSVerify=false`; health/openapi/metrics bloqueados e fallback 404. Caddy também bloqueia estes caminhos, incluindo maiúsculas, codificação e barras duplicadas. PostgreSQL, Mailpit, SSH e administração de infraestrutura não têm rotas públicas. Administração da **aplicação** continua sujeita ao papel Identity de administrador ativo.

## Verificação externa e recuperação

Resultados reais através do hostname Cloudflare:

- Cadeia e hostname TLS verificados com trust store normal, TLS 1.3; certificado público observado válido até **2026-12-07 00:35:35 UTC**. Sem ignorar erros TLS.
- HTTP redireciona 308 para HTTPS, preservando caminho/query, antes de enviar credenciais.
- Web: login/logout com CSRF, cookies Secure/HttpOnly/SameSite; ausência de CSRF recusada com 400; identidade do titular preserva administrador+colaborador.
- Bearer: login e refresh do chefe distinto, papel manager confirmado. É verificação HTTP do protocolo existente, **não teste Android físico**.
- Leitura anónima de membro 401; registo público 404; health/openapi/metrics 404. Cache-Control no-store em Web/API e CF-Cache-Status DYNAMIC; nenhuma resposta privada servida de cache.
- Falha controlada apenas do processo do conector: Docker reiniciou automaticamente, contador 0→1, novo processo observado em 0,3 s; túnel regressou a healthy e HTTPS 200 confirmado. Esse tempo mede o reinício do processo, não o tempo exato de indisponibilidade externa. Sem reiniciar o Pi, a base ou a aplicação.

Novo backup **20260912T000655Z-79206** antes da troca, incluindo SQL, configuração original, PFX/key ring, compose/Caddy e configuração HTTPS preparada. Cópia AES-256-GCM no diretório privado do PC, decriptação e todos os hashes internos verificados. Cópia manual, não backup externo automatizado. A prova anterior de restauro para uma base nova continua em [ensaio Pi](HO-012-PI-TRIAL.md); não foi repetida nem atribuída ao backup novo nesta publicação.

Observação de **125,3 s / 24 amostras**, conector real, pedidos HTTPS sintéticos e reinício controlado: mínimo **3196 MiB** disponíveis no host, pico agregado dos contentores **194,0 MiB**, conector **19,4 MiB**, CPU agregada máxima amostrada **47,05%** (100%=um núcleo), temperatura máxima **57,3 °C**, zram ocupado **1 MiB**, zero OOM e `throttled=0x0`. Os 23 pedidos de verificação demoraram **62–390 ms** neste PC/rede; amostra curta, sem percentis de capacidade ou garantia de produção.

Certificado privado da origem vence em **2026-10-11 23:53:44 UTC**. A renovação ainda não é automática; deve preservar o certificado SMTP e PFX/key ring, atualizar a CA confiada pelo conector e voltar a verificar TLS. Certificado público e privado têm ciclos distintos.

Para fechar a publicação sem apagar dados: repor a configuração remota `private/https/blocked-route.json` (404-only), remover **apenas** o CNAME acima depois de conferir ID/conteúdo e parar o conector. Repor os quatro serviços com o compose base conforme [recuperação](HO-012-HTTPS.md#testes-e-recuperação). As regras criadas podem ser removidas pelos IDs acima, preservando eventuais regras acrescentadas depois; não apagar um ruleset que entretanto contenha outras regras. Sem `down -v`, drop de base ou remoção de keys/backups.

Operação corrente, a partir de `/home/dennyum/ho012-pi-trial`:

```sh
sudo docker compose -p homeoffice-pi-trial -f compose.yaml -f private/https/compose.json --profile publish ps
# Para arrancar/recuperar o mesmo perfil público, sem pulls nem migrações:
sudo docker compose -p homeoffice-pi-trial -f compose.yaml -f private/https/compose.json --profile publish up -d --pull never
```

O compose base serve a recuperação **local**, não a manutenção do perfil público. Backups posteriores à publicação têm de incluir também `private/https` com proteção adequada; o comando base de backup, isoladamente, só copia a configuração local original. Não mostrar `docker inspect` completo, configuração efetiva, tokens ou dumps em canais públicos.

## Próxima aceitação e critérios ainda abertos

O responsável deve abrir o hostname no telemóvel com Wi-Fi desligado e repetir o percurso titular→chefe→calendário/notificação com as contas sintéticas existentes. Credenciais, guia e recibos completos ficam apenas no diretório privado do PC. Mailpit permanece pelo encaminhamento SSH local; não há entrega de email real.

HO-012 continua incompleta: aceitação externa pelo responsável, escolha definitiva/separação staging–produção, SMTP real autorizado, backups externos automatizados/retidos e restauro, monitorização/alertas/renovação, Android físico/assinatura/distribuição privada e aceitação final. iOS/Outlook adiados. Sem merge, auto-merge ou release.

Fontes oficiais consultadas em 2026-09-12: [campo ssl](https://developers.cloudflare.com/ruleset-engine/rules-language/fields/reference/ssl/), [normalização dos caminhos Caddy](https://caddyserver.com/docs/caddyfile/matchers#path), restantes fontes e configuração na [preparação HTTPS](HO-012-HTTPS.md).
