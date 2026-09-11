# HO-012 — Ensaio real isolado no Raspberry Pi

2026-09-11. Instalação e testes autorizados explicitamente pelo responsável. [PR #37 draft](https://github.com/Dennyum204/HomeOfficeReservation/pull/37), HO-012 aberta; não é aprovação de produção.

## Revisão, isolamento e preparação

Imagens reais instaladas: `21a2f21fc42bd77f363e858de685985ed0a82da5`, artifact do [runner ARM64 nativo](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34649620463/job/103428467077). Verificados SHA256 do arquivo, SHA do manifesto, quatro configurações Docker linux/arm64 e correspondência dos IDs; bases/dependências ARM64 verificadas na CI. Sem emulação ou compilação no Pi. Alterações posteriores desta etapa são preparação/documentação; aplicação, contratos e Dockerfile permanecem idênticos a essa revisão.

Inventário repetido imediatamente antes: diretório de ensaio ausente, sem contentores/volumes, redes Docker predefinidas, sem colisão de rota com 10.78.17.0/24. Serviços anteriores 22/8787 preservados. Memory/swap/CFS true. Criados apenas o diretório aprovado, imagens importadas, projeto/rede internos, dois volumes e ficheiros privados do ensaio.

Foi detetado CRLF no marcador e .env gerados em Windows; o preflight recusou antes de iniciar serviços. Gerador corrigido para emitir LF/UTF-8 sem BOM em todos os ficheiros Linux, incluindo scripts copiados do checkout. Teste reproduz o erro no gerador anterior e passa na correção; incluído em pi-preparation. Arquivo anterior privado conservado para diagnóstico; arquivo corrigido e respetivo hash verificados novamente. Nenhuma password/chave alterada pela normalização.

Quatro serviços permanentes: app/API/Web/worker, PostgreSQL, Caddy, Mailpit. Docker inspect confirmou 768/512/64/128 MiB, 1,5/1/0,25/0,25 CPU, total 1472 MiB/3 CPU, MemorySwap igual a Memory (sem swap adicional por contentor) e PortBindings vazios. Migração/bootstrap executados como comandos transitórios do perfil. Nenhuma porta publicada no Pi. Túnel PC com listeners somente 127.0.0.1:18443 e 127.0.0.1:18025; Web HTTPS e Mailpit responderam através dele.

## Testes reais concluídos no equipamento

- Migração explícita na base nova; nenhuma conta criada automaticamente no arranque.
- Bootstrap titular Admin+Employee repetido sem duplicação; duas ativações com códigos Identity recebidos exclusivamente no Mailpit.
- Gestor distinto convidado e associado; replay do convite não duplica membro.
- Cinco pedidos sintéticos: submissão pelo titular, autoaprovação recusada, aprovação pelo gestor associado; worker produz inbox durável.
- Duas sessões cookie com leituras concorrentes durante 602 segundos; cinco ciclos de pedido/decisão, aproximadamente um a cada dois minutos.
- Base parada controladamente: liveness disponível, readiness falha e recupera. Reinício apenas dos contentores conserva login, chefia, aprovações, inbox e email capturado.
- Backup consistente com pausa apenas de app/worker. Restauro em `ho012_restore_pi1`, preservando homeoffice; segunda tentativa de criação do mesmo destino recusada.
- Aplicação apontada temporariamente à base restaurada: sessões e pedido aprovado válidos. Configuração fonte reposta no fim. PFX/key ring protegidos copiados e hashes comparados; cópia adicional das chaves restauradas preservada, sem apagar as chaves em uso.
- Cópia manual fora do Pi no diretório privado do PC, cifrada AES-256-GCM. Desencriptação e todos os hashes internos de SQL/configuração/PFX/key ring verificados. A chave de recuperação fica privada no PC; não é backup externo automatizado, nem uma política de retenção/disaster recovery.
- Web real em Edge headless no PC: login titular e gestor, navegação Calendário e capturas privadas. Certificado verificado primeiro contra a CA exclusiva; exceção TLS limitada ao contexto descartável, sem alterar confiança global. Primeiro seletor do teste procurava link onde existe botão: timeout registado, seletor corrigido, execução repetida passou; não foi falha da aplicação.

## Medição inicial e condições

Pi 5/4 GB, Debian 13.4, kernel 6.12.75+rpt-rpi-2712, Docker 29.8.0/Compose 5.5.1, microSD e ligação Wi-Fi. Início do ensaio 21:36:36 UTC; fase ativa de 602 segundos. Monitor amostra aproximadamente a cada 17 segundos (15 segundos mais recolha Docker). Não é teste de saturação ou SLA. Latências API medidas no próprio Pi através de HTTPS da bridge; não incluem browser/renderização nem a ligação Wi-Fi do PC. As duas sessões Web no PC foram verificadas separadamente.

| Medida | Resultado inicial |
|---|---:|
| Amostras na fase ativa | 35 |
| RAM mínima disponível no host | 3277.2 MiB |
| Máximo da soma RAM dos quatro contentores, segundo docker stats | 262.0 MiB |
| Máximo CPU somado amostrado (100% = um núcleo) | 49.81% |
| Temperatura máxima amostrada | 58.95 °C |
| Swap usado / pswpin / pswpout / OOM | 0 / 0 / 0 / 0 |
| Throttling | 0x0 |
| Leituras API, incluindo CSRF/perfil/validação após recuperação | 160; p95 200.03 ms |
| Escritas API, incluindo autenticação e recusas esperadas | 27; p95 480.02 ms |

A janela adicional de trinta minutos após recuperação faz leituras leves a cada trinta segundos. O recibo final no PR regista a sua duração/resultado e os extremos de toda a observação; a tabela acima permanece deliberadamente limitada à amostra inicial. Monitor interrompe apenas o ensaio se RAM disponível cair abaixo de 768 MiB, houver OOM, mais de 64 MiB de swap-out, temperatura >=80 °C, throttling/undervoltage corrente ou falha repetida da monitorização. Nada disso foi observado na amostra inicial.

## Revisão manual e limitações

[Comandos de acesso/gestão](../infra/pi/README.md). Guia, credenciais, screenshots, dump e códigos apenas privados; usar Entrar nas duas contas já ativas. Titular submete num dia livre; noutra sessão o chefe seleciona o titular e aprova; titular confirma calendário e inbox. O certificado é local e pode exigir exceção específica no browser depois de conferir o fingerprint privado. O browser integrado recusou inicialmente a CA autoassinada; não se declarou essa navegação concluída.

Serviços mantidos disponíveis, sem restart automático: reiniciar o Pi/Docker pode exigir operação manual do perfil. Este ensaio não valida desgaste/fiabilidade prolongada da microSD, falta de energia, recuperação total noutro equipamento, acesso externo ou produção. Faltam decisão de alojamento, backup/recuperação externa automatizada, HTTPS/SMTP reais, alertas, assinatura/distribuição Android e aceitação piloto. NAS, boot, DNS, router e Cloudflare não alterados nesta instalação; sem emails reais, APK, contratação, merge, auto-merge ou release.
