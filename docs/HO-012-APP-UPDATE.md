# Atualização da aplicação no piloto Pi

2026-09-14: atualização autorizada após aceitação e merge humano de HO-021, PR #52, commit `bda687c76428eb854aef43c65e7de049e0ca394f`. HO-020 já integrada por PR #51. A imagem será construída pela preparação nativa ARM64 do PR #37, com a versão integrada; não reutilizar o artefacto antigo nem usar emulação.

## Procedimento

1. Confirmar CI de integração e da revisão operacional, incluindo `pi-preparation`, manifesto, SHA256 e arquitetura. Transferir os artefactos públicos para o diretório privado do PC antes de importar no Pi.
2. Inventariar por SSH a stack `homeoffice-pi-trial`, a imagem efetiva, mounts, limites e espaço. Validar os ficheiros Compose em uso, incluindo `private/https/compose.json`, sem imprimir configuração ou credenciais. Não executar o instalador inicial nem `verify.py` no Pi.
3. Coordenar a atualização com `/var/lib/homeoffice-backup/operation.lock`. Se existir backup em curso, adiar; não interromper nem alterar timers. Fazer uma captura local prévia consistente de PostgreSQL e configuração/chaves, com retoma da aplicação e cópia privada de recuperação. Este backup manual não é evidência de disparo agendado.
4. Comparar migrações com a versão efetiva. HO-020/021 não acrescentam migrações; qualquer diferença anterior tem de ser identificada antes da atualização. Carregar a imagem Linux ARM64 verificada e alterar apenas a referência da imagem `app`. Preservar PostgreSQL, Caddy, Mailpit, cloudflared, SMTP, volumes, chaves e redes.
5. Recriar somente `app`, sem dependências nem pulls. Confirmar saúde, limites, HTTPS e recursos Web de idiomas. Se falhar, restaurar a referência anterior e recriar apenas `app`; não restaurar a base por cima da original.
6. Registar imagem anterior/nova, instante e resultados reais. Confirmar no browser calendário e seletor de idioma, sem enviar novos emails de teste. PR #37 mantém os gates acordados; nenhuma alteração de DNS, NAS, boot ou distribuição Android.

## Estado observado

As primeiras tentativas SSH a `192.168.1.105:22` expiraram antes da autenticação. Não houve inventário atual, backup prévio nem substituição da aplicação nesta tentativa. A preparação/CI não substitui a verificação no equipamento. O responsável foi informado para confirmar rede/endereço do Pi; não foram solicitadas passwords.
