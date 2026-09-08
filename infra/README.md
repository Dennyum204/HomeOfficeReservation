# Infraestrutura prevista

HO-002 prepara ambiente local reproduzível. HO-012 escolhe fornecedor e configura staging/produção conforme as condições da empresa.

Componentes core: host Linux para API/Web/worker, PostgreSQL persistente, keyring Data Protection protegido, entrega de email de ativação/recuperação e serviço push para mobile. Nenhuma conta Microsoft, callback OAuth ou webhook Graph obrigatório; estes entram só nos marcos opcionais HO-008/HO-009. Credenciais e chaves ficam fora do repositório.

O worker inicial corre continuamente no host; não configurar scale-to-zero sem alterar este desenho. Backups, restauro, logs, health checks, migrações e alertas de notificações pertencem ao gate do piloto core. Alertas Graph só se aplicam ao conector opcional.

Não há containers/deploys ativos neste pacote. Acrescentar comandos comprovados, ficheiros de exemplo sem segredos e procedimento de rollback no PR que os implementar.
