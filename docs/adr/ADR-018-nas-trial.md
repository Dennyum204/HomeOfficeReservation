# ADR-018 — Ensaio isolado no NAS antes de decidir alojamento

Data: 2026-09-11. Estado: **preparação autorizada; instalação e adequação por validar**. Substitui a proposta corrente de fornecedor/topologia de [ADR-013](ADR-013-pilot-hosting.md), preservando o histórico. Não muda Identity, contratos ou regras de negócio.

DS218+ de 2 GB candidato em avaliação. Conectividade cloudflared reportada; aplicação não instalada/medida. Reutilizar imagem Linux amd64 React/ASP.NET Core, workers no mesmo host. Caddy só TLS local, PostgreSQL próprio e Mailpit SMTP autenticado. Sem VM, Kubernetes, worker duplicado ou monitorização pesada.

Nenhuma porta publicada no NAS. Rede Docker interna sem saída e encaminhamento SSH para IPs internos de edge/Mailpit dispensam DNS, router, Cloudflare e garantias loopback de Engines antigos. Health/DB/DSM fora do proxy. Certificado TLS específico para o ensaio; não ignorar validação na aplicação. Data Protection persistente cifrado por PFX separado do TLS preserva sessões e convites após reinício/restauro.

Build/exportação fora do NAS; manifesto com SHA do código, IDs/digests e hash do archive. Configuração privada gerada no PC em diretório novo, fora do Git/artifact. Compose 2.4 sem extensões recentes; versões/kernel/seccomp/cgroups efetivos continuam gates. Não instalar Engine alternativo nem enfraquecer seccomp.

Limites iniciais: 896 MiB, 1,6 CPU; hipóteses a medir com carga DSM, não dimensionamento de produção. Restart automático desligado para tornar falhas visíveis. Backup próprio e restauro CREATE-only preservam fonte. Cópia local não protege contra perda do NAS.

Acesso Web exige SSH e confiança explícita no certificado local. Não valida Android físico/FCM, HTTPS externo ou entrega real. Um Staging sintético não satisfaz isolamento staging/produção nem aceitação final. [Runbook/fontes datadas](../../infra/nas/README.md). PR #37 draft, issue aberta.

## Evidência posterior — 2026-09-11

[Inventário SSH autorizado](../HO-012-NAS-INVENTORY.md) confirma Engine 20.10.3, Compose 1.28.5 e kernel 4.4.180+. Não há suporte de quotas CFS nem encaminhamento SSH; a memória disponível no baseline curto fica abaixo da margem proposta. RAID1 de dados saudável, mas arrays de sistema/swap degradados, ainda por esclarecer. Não se atribui a causa à atualização DSM efetuada pelo responsável.

A topologia acima continua uma proposta bloqueada, não uma decisão de instalação nem prova de adequação. Não basta atualizar o Engine. Preservam-se preflight, limites e proibição de alterações não autorizadas; qualquer adaptação terá de documentar proteção dos serviços existentes e evidência nova. Nenhuma reparação, alteração DSM/SSH ou execução HomeOffice no NAS nesta revisão. O inventário foi concluído sem exigir uma cópia externa como pré-condição dessas leituras; recuperação do piloto permanece um critério próprio.
