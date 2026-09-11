# ADR-019 — Ensaio isolado Raspberry Pi ARM64

Data: 2026-09-11. Estado: preparação autorizada; instalação e adequação por validar. Substitui o alvo do [ADR-018](ADR-018-nas-trial.md), preservando NAS/AMD64 e Hetzner como históricos. O NAS permanece inalterado.

O responsável selecionou o Pi 5 existente, 4 GB, Debian 13 Trixie aarch64, alimentação oficial de 27 W, caixa/ventoinha e microSD High Endurance. Reportou 3,7 GiB disponíveis antes de instalar Docker, swap zero, 50 GB livres, hello-world arm64v8 e Compose 5.5.1. SSH automático foi recusado: não se assumem Engine, limites, workloads ou margem atuais.

Reutilizar Dockerfile API/React e worker no mesmo processo, Identity e outbox existentes. Perfil próprio em infra/pi deriva do ensaio NAS e mantém isolamento/recuperação; não alterar o perfil histórico nem copiar configuração privada. Build e execução num runner GitHub ubuntu-24.04-arm nativo, verificando arquitetura de todas as bases/dependências e imagens exportadas. Sem QEMU, binfmt ou reutilização AMD64; falhar explicitamente se ARM64 não estiver disponível.

Quatro contentores: app 768 MiB/1,5 CPU, PostgreSQL 512 MiB/1 CPU, Caddy 64 MiB/0,25 CPU e Mailpit 128 MiB/0,25 CPU. Total 1472 MiB/3 CPU, swap limitado a zero por contentor e logs limitados. Limites iniciais sujeitos a inventário pós-Docker e medições, não previsão de consumo. Exigir pelo menos 2 GiB MemAvailable e 8 GiB livres antes do arranque. Não instalar monitorização, SDKs ou build tools no Pi.

Rede interna própria, sem portas no host, acesso Web/Mailpit por encaminhamento SSH do PC para a bridge, sujeito à configuração efetiva sshd. TLS local explícito, sem DNS, router ou Cloudflare. Banco/mail em volumes próprios; key ring persistente cifrado com PFX separado de TLS, ambos em configuração privada externa. Contas sintéticas, SMTP capturado sem relay. Backup/restauro CREATE-only conservam a fonte; cópia na mesma microSD não protege contra perda do suporte/equipamento.

O harness de CI executa migração, ativação, convites, aprovação, worker, reinício, recuperação autenticada e medidas curtas. É restrito ao runner descartável; nunca executar verify.py no Pi, pois o cleanup remove os volumes de teste do runner. Resultados ARM64 não certificam performance do Pi, resistência da microSD, comportamento térmico ou produção. [Proposta](../HO-012-PILOT.md), [recursos e comandos para revisão](../../infra/pi/README.md). PR #37 draft, HO-012 aberta.

Adenda 2026-09-11: [inventário](../HO-012-PI-INVENTORY.md) confirma SSH/Docker ARM64, mas controlador memory desativado. Manter limites e recusa do preflight. Ativação/reinício do host ficam para decisão separada; nenhuma instalação por esta adenda.
