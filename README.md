# HomeOfficeReservation

Planeamento de trabalho presencial na Suíça e home office em Portugal, com aprovações, tarefas e sincronização Outlook.

**Estado: fundação documental HO-000. A aplicação ainda não está implementada.** Repositório público: [Dennyum204/HomeOfficeReservation](https://github.com/Dennyum204/HomeOfficeReservation). A stack confirmada é ASP.NET Core/.NET 10, PostgreSQL com EF Core, React/TypeScript Web e Flutter para Android/iOS. A sincronização Outlook é obrigatória na V1.

A entrega HO-000 está no [PR #25](https://github.com/Dennyum204/HomeOfficeReservation/pull/25), para revisão e merge humano. O estado verificável está em [STATUS.md](STATUS.md). O tracking usa [issues](https://github.com/Dennyum204/HomeOfficeReservation/issues) e [milestones](https://github.com/Dennyum204/HomeOfficeReservation/milestones) para os 24 trabalhos, incluindo releases futuras. Foram criadas 24 issues, 12 labels de release/área e quatro milestones; os URLs reais estão em [docs/backlog.json](docs/backlog.json).

## Começar

1. Ler [PLANO.md](PLANO.md) para a visão geral.
2. Ler [AGENTS.md](AGENTS.md) e [STATUS.md](STATUS.md) antes de trabalhar.
3. Consultar [ROADMAP.md](ROADMAP.md) e [BACKLOG.md](docs/BACKLOG.md).
4. Seguir [DEVELOPMENT.md](docs/DEVELOPMENT.md) para branches, PRs e continuidade.
5. Para clonar o repositório ou integrar novamente o starter, seguir [GIT_IMPORT.md](docs/GIT_IMPORT.md); nunca importar o histórico do bundle sobre o repositório real.

## Documentação

| Ficheiro | Responsabilidade |
|---|---|
| [PRODUCT.md](docs/PRODUCT.md) | V1, permissões e comportamento esperado |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Tecnologias, componentes e fronteiras |
| [DOMAIN.md](docs/DOMAIN.md) | Estados, dados e invariantes |
| [OUTLOOK.md](docs/OUTLOOK.md) | Contrato de sincronização e recuperação |
| [UX.md](docs/UX.md) | Ecrãs e comportamento Web/Mobile |
| [QUALITY.md](docs/QUALITY.md) | Testes, segurança e critérios de lançamento |
| [Decisões](docs/adr/README.md) | Decisões técnicas e pressupostos |
| [Prompts](docs/CODEX_TASKS.md) | Arranque e tarefas para Codex Astra |
| [Prompt HO-000 recebido](docs/CODEX_PROMPTS.md) | Pedido de fundação fornecido para esta entrega |
| [Sources](docs/SOURCES.md) | Documentação oficial consultada |

## Validação disponível agora

Requer Python 3.10 ou superior; sem pacotes externos.

```bash
python3 scripts/check_project.py
```

No Windows, usar `python scripts/check_project.py` se o executável instalado se chamar `python`; os mesmos argumentos aplicam-se a `--write`.

O comando valida o backlog, dependências, cobertura das funcionalidades, documentos gerados e ligações locais. O workflow incluído executa apenas esta validação documental. Compilação e testes da aplicação serão adicionados com os respetivos projetos em HO-002; não existem ainda.

Após editar `docs/backlog.json`, regenerar os documentos derivados:

```bash
python3 scripts/check_project.py --write
python3 scripts/check_project.py
```

## Estrutura preparada

| Caminho | Trabalho futuro |
|---|---|
| `apps/api/` | ASP.NET Core, domínio, casos de uso, persistência e integrações |
| `apps/web/` | React e TypeScript |
| `apps/mobile/` | Flutter para Android/iOS |
| `contracts/` | OpenAPI e instruções de geração dos clientes |
| `infra/` | Ambiente local e configuração de deploy |
| `docs/` | Produto, arquitetura, backlog e decisões |

Não foram escolhidos nome comercial, domínio, alojamento pago, conta de publicação mobile ou licença de distribuição. A ausência de uma licença aberta não concede autorização de distribuição.

## Dados locais e colaboração

Manter segredos, dados privados do calendário, chaves de assinatura, configurações locais e outputs de build fora do Git. Versionar lockfiles, migrações e exemplos de configuração revistos e sem segredos. Os diretórios de aplicações contêm apenas instruções; HO-002 criará os projetos e os comandos reais de setup/build/test.

O Codex prepara branches, commits, issues e PRs; Fernando revê e faz merge. O trabalho mantém-se em `review` até existir evidência de integração. Cada tarefa verifica essa evidência e reconcilia estados antigos antes de avaliar dependências. Não fazer merge automático.
