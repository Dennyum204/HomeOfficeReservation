# Repositório real e importação do starter

Repositório: [Dennyum204/HomeOfficeReservation](https://github.com/Dennyum204/HomeOfficeReservation). A visibilidade pública mantém-se. O ZIP original contém os ficheiros sob `home-office-reservation/` e um bundle Git separado; apenas os ficheiros são integrados na raiz. O ZIP permanece local e ignorado.

**Não clonar nem importar o histórico do bundle sobre o repositório real.** Não substituir ficheiros existentes sem os ler e comparar.

## Trabalhar depois de HO-000

```bash
git clone https://github.com/Dennyum204/HomeOfficeReservation.git
cd HomeOfficeReservation
git status --short --branch
git remote -v
git fetch origin
```

Ler AGENTS.md e STATUS.md. Verificar merge/CI dos PRs e reconciliar estados antigos antes de avaliar dependências. Criar a branch delimitada a partir da base verificada; preservar alterações locais. Os ficheiros de HO-000 entram na `main` apenas depois do merge humano do seu PR.

## Bootstrap executado para HO-000

A inspeção inicial encontrou apenas o ZIP na workspace, sem `.git`, e nenhum commit/ref no GitHub. Foi criado localmente um repositório novo com um único commit vazio em `main`, `chore: bootstrap repository`, para estabelecer a base do PR. A branch de trabalho é `docs/ho-000-project-foundation`. Consultar [STATUS.md](../STATUS.md) para a confirmação do push e o PR real.

Se repetir o processo noutro checkout, verificar primeiro `git ls-remote origin` e a história real. Havendo commits, usar essa base, sem criar outro bootstrap ou substituir a história. Toda a integração de ficheiros deve ocorrer numa branch de âmbito definido.

## Validar a documentação

```bash
python3 scripts/check_project.py --write
python3 scripts/check_project.py
```

No Windows pode usar-se `python` em vez de `python3`, conforme a instalação. Não há ainda comandos de build/test da aplicação: HO-002 criará os projetos. Guardar os URLs reais de issues/PRs em `docs/backlog.json` e regenerar os documentos; manter HO-000 em `review` até o merge ser verificado. Proteções e revisão seguem [DEVELOPMENT.md](DEVELOPMENT.md).
