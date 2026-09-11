# ADR-020 — Origem HTTPS do Pi através de Cloudflare Tunnel

Data: 2026-09-12. Estado: preparação autorizada; publicação sujeita a autorização final. Complementa ADR-019, preservando o ensaio local/NAS como histórico.

O responsável aceitou manualmente submissão pelo titular, aprovação pela chefia e resultado no calendário/notificação do Pi. Para acesso sem PC/router, preparar túnel remoto próprio homeoffice-pi com conector ARM64 no Pi e apenas Web/API em homeoffice.ferbatech.com. Sem reutilizar o túnel NAS, sem portas publicadas no Pi, sem rotas de PostgreSQL/Mailpit/SSH/administração de infraestrutura.

Separar rede conector–Caddy da rede app/DB/mail; dar saída apenas ao conector através de bridge adicional. Autenticação continua Identity, cookies CSRF na Web e bearer/refresh Android; não introduzir Access SSO obrigatório nem registo público. API confia apenas no Caddy existente, que normaliza headers apenas do conector conhecido. TLS verificado por CA privada no salto conector–Caddy, diferente de SMTP/PFX/keys. Preservar Staging e o nome Data Protection para não invalidar dados protegidos.

O overlay privado substitui mounts, sem editar originais. Backup antes da troca, validação privada com conector simulado e retorno ao acesso localhost; conector real, DNS, redirect HTTPS e cache ficam para publicação autorizada. Restart unless-stopped, imagem fixada e limites adicionais de 128 MiB/0,25 CPU. Certificado de origem de 30 dias exige renovação acompanhada; não declarar solução de produção.

[Configuração, critérios, comandos e fontes oficiais](../HO-012-HTTPS.md). CI nativa e testes HTTP não demonstram conectividade Cloudflare nem Android físico. HO-012 continua incompleta até SMTP real, backup externo automatizado, monitorização, distribuição Android e aceitação final, além dos gates HTTPS/ambientes.
