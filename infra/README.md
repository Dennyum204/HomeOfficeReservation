# Infraestrutura prevista

HO-002 prepara ambiente local reproduzível. HO-012 escolhe fornecedor e configura staging/produção conforme as condições da empresa.

Componentes mínimos: host Linux para API/BFF/worker, PostgreSQL persistente, frontend Web, endpoint HTTPS público para OAuth/webhooks e serviço push para os alvos mobile. Credenciais e chaves ficam fora do repositório.

O worker inicial corre continuamente no host; não configurar scale-to-zero sem alterar este desenho. Backups, restauro, logs, health checks, migrações e alertas de sync pertencem ao gate do piloto.

Não há containers/deploys ativos neste pacote. Acrescentar comandos comprovados, ficheiros de exemplo sem segredos e procedimento de rollback no PR que os implementar.
