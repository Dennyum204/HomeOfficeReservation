# PostgreSQL local

Docker Engine/Desktop com **Compose v2** e containers Linux. PostgreSQL **18.6-alpine3.24** fixado; volume em `/var/lib/postgresql`, conforme imagem oficial 18+. Porta **5432 só em loopback**. Hostnames/credenciais de desenvolvimento, sem Microsoft/Azure/Outlook.

Na raiz:

```sh
python scripts/init_local.py
docker compose -f infra/compose.yaml up -d --wait
docker compose -f infra/compose.yaml ps
```

`init_local.py` cria `infra/.env` e `apps/api/src/HomeOffice.Api/appsettings.Local.json`, ambos ignorados, com uma password local aleatória. Não a imprime e recusa sobrescrever configuração existente. Se preferir configuração manual, copiar `.env.example` e `appsettings.Local.example.json` para esses nomes e substituir o placeholder pela **mesma** password local. Nunca usar credenciais pessoais nem publicar ficheiros reais.

```sh
docker compose -f infra/compose.yaml stop
docker compose -f infra/compose.yaml start --wait
docker compose -f infra/compose.yaml down
```

`stop` e `down` preservam o volume. Não acrescentar `--volumes` sem pretender apagar os dados locais. Alterar POSTGRES_PASSWORD no ficheiro não muda a password de uma base já inicializada; alinhar a configuração com a base existente. Nunca apagar volumes para resolver isto sem verificar se contêm trabalho a preservar.

A imagem usa um utilizador PostgreSQL de desenvolvimento com privilégios administrativos de inicialização. Não é desenho de credenciais de produção. HO-003/HO-004 acrescentarão migrações explícitas; readiness HO-002 mede conexão, não esquema de tabelas. Não executar Graph nem carregar calendários para validar este ambiente.

CI executa este mesmo Compose num runner descartável, com password sintética, verifica readiness/consulta EF real e encerra os containers. O PC atual não tem Docker instalado; a execução local de Compose exige instalar/iniciar Docker. Os resultados remotos ficam no PR, sem apresentar simulação como base de dados real.

HO-012 escolherá alojamento/região/domínio, credenciais restritas, backups/restauro, keyring protegido, entrega de email e push. API/Web/worker mantêm o host Linux previsto; nenhum recurso foi contratado ou deployed.

Fonte oficial consultada em 2026-09-08: [imagem PostgreSQL](https://hub.docker.com/_/postgres), [Docker Compose](https://docs.docker.com/compose/gettingstarted/).
