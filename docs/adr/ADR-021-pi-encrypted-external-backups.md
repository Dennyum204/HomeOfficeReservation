# ADR-021 — Backups cifrados do Pi com restic e destino externo

Data: 2026-09-13. Estado: preparação adotada; destino R2 proposto, ativação/envio por autorizar. Complementa ADR-019/020 sem declarar o piloto concluído.

O responsável exige backups automáticos independentes do PC, recuperação após perda total do Pi e restauro sem sobrescrever a base usada. O NAS tem uma discrepância de armazenamento ainda não esclarecida; a cópia manual cifrada no PC permanece complementar. O acesso HTTPS e a aceitação parcial Web no telemóvel são preservados.

Usar restic 0.19.1, binário nativo ARM64 verificado por SHA256, em serviço/timer systemd no Pi. Repositório cifrado antes do envio; a chave restic é independente das credenciais do armazenamento. Destino proposto: bucket Cloudflare R2 Standard privado, jurisdição UE, sem domínio público. A leitura da API devolveu 10042 (R2 não ativado); não existe destino R2 utilizável confirmado. Não ativar faturação/criar bucket/enviar dados sem autorização.

Captura consistente: pausar só app/worker durante pg_dump e cópia de configuração/key ring/PFX. PostgreSQL continua ativo. Retomar o mesmo perfil Compose (incluindo HTTPS) em finally, com marcador e ExecStopPost para recuperar interrupções. Incluir imagens runtime ARM64 exportadas, configuração base/HTTPS, passwords de serviço, PFX e respetiva password na configuração, chaves Data Protection e identidade do ensaio. Não depender de artifacts CI de sete dias para recuperar uma instalação perdida. Mailpit é captura transitória; não faz parte da recuperação de negócio.

Diariamente às 03:15 UTC com atraso aleatório até 15 minutos, sem depender do PC; 7 diários, 4 semanais e 6 mensais, até 17 snapshots distintos. Validar identidade do repositório, metadados e download/hash do SQL/configuração/chaves antes de podar. Leitura integral semanal. Sem lifecycle R2 que apague packs partilhados; sem apagar dados/backups locais preexistentes. Restauro exige snapshot explícito e CREATE de base ho012_restore_* nova, sem DROP, --clean ou alteração de configuração da aplicação em uso.

Configuração/credenciais root-only; token S3 só leitura/escrita de objetos no bucket dedicado, sem administração Cloudflare. Kit independente sob controlo do responsável: password restic, endpoint/bucket/ID, acesso de recuperação à conta Cloudflare com MFA e comandos. Não colocar a única chave dentro do próprio repositório cifrado. O token S3 pode ser reemitido; a password restic perdida não. Guardar o kit fora do Pi e uma cópia independente do PC (gestor de passwords com recuperação ou suporte offline).

Falhas ficam em systemd/journal e recibo privado com última execução/último sucesso; status falha após 36 h ou erro. Um Pi desligado não consegue alertar: monitorização externa da frescura continua gate separado de HO-012. Não há garantia de imutabilidade contra um Pi comprometido: a credencial de retenção consegue eliminar objetos. Avaliar cópia imutável independente antes de alargar o risco do piloto.

RPO proposto de 24 h (até 15 min de jitter mais duração); RTO pretendido de 4 h após existir hardware substituto, ainda não medido. Limite adicional 512 MiB/0,5 CPU, swap zero, prioridade baixa e upload máximo 2 MiB/s; medir impacto antes de ativação regular. [Runbook, fontes, custo, testes e gates](../HO-012-BACKUPS.md).
