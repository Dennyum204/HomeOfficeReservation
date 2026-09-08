# Tarefas para Codex Astra

Selecionar Astra no ambiente de desenvolvimento. Estes prompts não dependem de um identificador de API do modelo. Não é necessário incorporar IA no produto para o desenvolver com o Codex.

Recomendação do projeto para a próxima tarefa HO-001: **Astra, reasoning `high`**, pelo estudo de identidade, consentimento e sincronização. É uma escolha de esforço para esta tarefa, não uma dependência do produto. `high` consta dos níveis suportados na [documentação oficial Astra](https://developers.openai.com/api/docs/models/gpt-6-astra).

Repositório: https://github.com/Dennyum204/HomeOfficeReservation. O [prompt HO-000 recebido](CODEX_PROMPTS.md) tem o âmbito autorizado desta entrega. Não foi fornecido um guia novo com os prompts completos das 24 tarefas; os exemplos seguintes pertencem ao starter e foram alinhados com o workflow confirmado.

## Arranque / importação deste pacote

```text
Estamos a desenvolver Home Office Reservation. Lê AGENTS.md, README.md,
STATUS.md, ROADMAP.md e docs/DEVELOPMENT.md. Inspeciona o estado Git e o
repositório remoto sem alterar trabalho existente.

Este pacote define a stack confirmada e o âmbito da V1, incluindo
sincronização Outlook. Prepara a integração da documentação numa branch
docs/ho-000-project-foundation e num PR para main. Usa docs/pr/HO-000-PR.md
como base. Não substituas ficheiros de um projeto existente sem os comparar.

Executa python3 scripts/check_project.py. Regista o URL real do PR no backlog
quando existir, mantendo HO-000 em review até à integração. Se não houver
repositório/acesso, conclui toda a preparação local e indica o dado exato que falta.
Não implementes já toda a aplicação a partir deste pedido de importação.
```

## Primeira tarefa técnica — HO-001

```text
Executa apenas HO-001 do backlog com Astra, reasoning high. Lê AGENTS.md,
STATUS.md, docs/OUTLOOK.md e docs/adr/ADR-002-outlook.md. Faz fetch e verifica
merge/CI de HO-000; reconcilia o backlog antigo antes de avaliar dependências.
Cria uma branch adequada a partir da base verificada.

O objetivo é validar o tipo de conta Microsoft, permissões/consentimento,
autenticação Web/Mobile e a sincronização do calendário principal. Usa apenas
contas/eventos de teste explicitamente autorizados. Não guardes tokens nem
payloads privados no repositório.

Entrega o estudo reproduzível, provas realizadas e limitações concretas.
Atualiza ADR-002 e STATUS.md. Se faltarem credenciais, prepara código/roteiro
de teste e distingue claramente o que foi simulado do que foi validado no Graph.
Abre PR com evidência; não declares a integração concluída sem testar o serviço real.
Se completo, entrega PR sem draft, CI relevante verde no último commit e sem
conflitos. Se incompleto, mantém draft com limitações concretas. Fernando revê
e faz merge; não faças merge nem atives auto-merge.
```

## Implementação de uma tarefa

```text
Implementa apenas a tarefa HO-XXX em docs/BACKLOG.md, após ler AGENTS.md,
STATUS.md e as instruções das áreas afetadas. Verifica evidência real de merge/CI,
reconcilia estados antigos e só então avalia dependências. Mantém as decisões
de arquitetura, salvo razão documentada.

Cria uma branch curta, define os ficheiros necessários e implementa o fluxo
delimitado, incluindo API/contrato/UI conforme o âmbito. Usa clientes gerados,
autorização no backend e testes dos cenários de aceitação/riscos reais.

Executa as verificações existentes e as específicas da mudança. Não inventes
comandos ou resultados. Atualiza docs/backlog.json, regenera os documentos e
mantém STATUS.md com estado real e próxima tarefa. Abre PR com o modelo,
URL da issue real, testes, impacto e capturas quando houver mudanças de UI.
Entrega trabalho completo num PR sem draft, verde no último commit e sem
conflitos. Mantém trabalho incompleto explicitamente marcado e em draft.
Fernando revê e faz merge. Não faças merge nem atives auto-merge.
```

## Revisão de um PR

```text
Revê o PR indicado contra a tarefa HO e os critérios de produto. Procura
defeitos concretos de autorização, decisões concorrentes, datas, sync Outlook,
privacidade e compatibilidade entre clientes/API. Verifica a evidência de testes.
Não marques código como correto apenas porque segue um padrão ou tem cobertura.
Apresenta findings com gravidade, efeito observável e correção proposta.
Não alteres o âmbito. Fernando faz merge; não integres o PR nem atives auto-merge.
```

## Retomar após uma pausa

```text
Retoma Home Office Reservation. Lê STATUS.md e o backlog, inspeciona branches,
PRs e estado do repositório. Resume brevemente o que está integrado, o que está
em revisão e o próximo trabalho pronto. Continua a tarefa autorizada com base
nos ficheiros e no estado remoto atual, preservando alterações existentes.
```
