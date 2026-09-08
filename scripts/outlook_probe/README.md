# Probe local HO-001 — referência opcional

> **Execução real e onboarding suspensos por decisão de produto.** O core não precisa deste probe, dependências Python extra, conta Microsoft ou consentimento. [ADR-004](../../docs/adr/ADR-004-independent-core.md) substitui o âmbito anterior. O ensaio real foi adiado, não passou. Este probe legado inclui leituras delta além da primeira publicação opcional; não o executar integralmente em HO-008 sem adaptar/reautorizar esse acesso. HO-009 preserva os ensaios avançados. Os passos abaixo são referência para uma futura tarefa explicitamente selecionada.

Ferramenta de ensaio isolada; não cria a aplicação .NET/React/Flutter. **Não foi executada contra Graph nesta entrega.** O [estudo](../../docs/HO-001-MICROSOFT-OUTLOOK-STUDY.md) distingue desenho, simulação e evidência em falta.

## Preparação e testes sem conta

Python 3.12 foi testado. Criar ambiente virtual **fora do repositório**, pois o validador documental percorre ficheiros locais. Dependências diretas em `requirements.in` e resolução completa fixada em `requirements.txt` (MSAL Python 1.38.0). Os testes usam unittest e Graph simulado; não precisam de credenciais.

PowerShell, a partir da raiz:

```powershell
python -m venv "$env:LOCALAPPDATA\HomeOfficeReservation\ho001-venv"
$probePython = "$env:LOCALAPPDATA\HomeOfficeReservation\ho001-venv\Scripts\python.exe"
& $probePython -m pip install -r scripts/outlook_probe/requirements.txt
& $probePython -m pip check
& $probePython -m unittest discover -s scripts/outlook_probe -p 'test_*.py' -v
& $probePython scripts/outlook_probe/probe.py plan
```

Linux/macOS:

```bash
python3 -m venv "$HOME/.cache/ho001-venv"
"$HOME/.cache/ho001-venv/bin/python" -m pip install -r scripts/outlook_probe/requirements.txt
"$HOME/.cache/ho001-venv/bin/python" -m pip check
"$HOME/.cache/ho001-venv/bin/python" -m unittest discover -s scripts/outlook_probe -p 'test_*.py' -v
"$HOME/.cache/ho001-venv/bin/python" scripts/outlook_probe/probe.py plan
```

Os comandos do workflow são executados em Linux pela CI; a preparação local foi executada em Windows com o Python do ambiente Codex e venv externo. `plan` apresenta seis fixtures e durações UTC `[23,25,23,25]`; zero chamadas de rede. Só a execução manual opcional da CI instala dependências PyPI; os testes/plan não contactam Microsoft. A CI normal executa o validador documental sem este ambiente.

## Gate de execução real

1. Alvo confirmado por Fernando: **Outlook.com pessoal**; registo/consentimento ainda não preparados. Selecionar explicitamente mailbox de teste dedicada, sem dados privados de produção, e obter autorização do titular. Posteriormente foi confirmada uma conta dedicada com calendário vazio; não há consentimento concedido, e o onboarding foi suspenso por decisão de produto. Não usar a conta sugerida pelo browser sem confirmar. Graph delta pode devolver conteúdo alheio mesmo sem o persistirmos; uma mailbox vazia de teste reduz esse acesso.
2. Obter acesso ao portal Entra e a um diretório com direito de registar aplicações; isto é necessário mesmo para um cliente de contas pessoais. Criar registo separado de teste com **Personal Microsoft accounts only**, tipo público desktop, redirect `http://localhost`, para code + PKCE via browser (porta local 8400 livre). Não criar client secret nem usar password/device-code como atalho. O diretório do registo não substitui o tenant consumer na configuração de autenticação. [Registo Microsoft](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app), [Configuração MSAL Python](https://learn.microsoft.com/en-us/entra/msal/python/getting-started/acquiring-tokens).
3. Configurar apenas Graph **delegado** `Calendars.ReadWrite` e obter consentimento segundo a política real. MSAL acrescenta os scopes OIDC/offline necessários; não passar estes scopes reservados manualmente à biblioteca. Não pedir permissões application, Mail, User.Read ou MailboxSettings.Read. Não iniciar consentimento empresarial sem autorização.
4. Copiar `config.example.json` para pasta privada fora do Git, por exemplo `$env:USERPROFILE\.ho001-probe\config.json`. Substituir `client_id` pelo ID do registo e marcar os dois flags apenas após confirmar conta dedicada e consentimento. Manter `mailbox_type=personal` e o UUID consumer público do exemplo; não usar o ID do diretório onde criou a aplicação. Não enviar palavra-passe, token ou ficheiro real para chat/GitHub.
5. Se já conhece o `oid` da conta através de uma ligação OIDC verificada, preencher `expected_object_id`. Caso contrário, mantê-lo a zero e executar **bind** abaixo: seleciona a conta no browser, pede consentimento delegado, exige confirmação local `BIND`, grava só o UUID OIDC na configuração privada e não chama Graph. `run`/`cleanup` exigem esse ID fixado e recusam conta diferente. Não usar email como chave de autorização. Clouds soberanas, guests/B2B e proxy empresarial não estão preparados.
6. Escolher diretório de estado privado fora do repo, com acesso apenas ao operador (ACL no Windows). Não editar os eventos durante o ensaio. O probe exige `--allow-live` e recusa o estado dentro do Git antes de abrir login.

Exemplos a executar **apenas depois deste gate**. Primeiro vincular a conta, se o object ID ainda estiver a zero; depois executar com journal novo:

```powershell
& $probePython scripts/outlook_probe/probe.py bind --config "$env:USERPROFILE\.ho001-probe\config.json" --allow-live
& $probePython scripts/outlook_probe/probe.py run --config "$env:USERPROFILE\.ho001-probe\config.json" --state "$env:USERPROFILE\.ho001-probe\run-01\state.json" --allow-live
```

Não executar `run` novamente sobre um journal existente. Se o ensaio terminou com limpeza confirmada, um novo ensaio usa outro diretório (`run-02`). Se falhou, recuperar primeiro com o mesmo journal. Uma falha antes de criar eventos pode deixar journal vazio; confirmar o resumo/limpeza antes de iniciar nova execução.

## Operações e limites

O browser pede seleção explícita; tenant e object ID têm de coincidir com a configuração antes de Graph. Cache de tokens apenas em memória. O ensaio cria quatro eventos all-day e duas séries diárias de três ocorrências, apenas no calendário principal, sobre transições de DST em 2026. Sem attendees/convites, online meeting ou reminders. Assunto sintético, privado, `showAs=free`. Verifica leitura das datas, ocorrências, initial delta, alterações incrementais, update de um assunto e remoção de tudo o que criou. Pede páginas pequenas; só reporta paginação observada quando recebe mais de uma página. Graph pode ignorar a preferência; não transformar `not_observed` em sucesso de paginação.

IDs e intenções de criação ficam num journal privado para recuperar POST ambíguo. Cada mutação relê ID, transactionId, marcador e attendees; sem correspondência, recusa. Não pesquisa por título nem altera outros eventos. `If-Match` é enviado e erro interrompe a operação: suporte/412 real não está validado e não é contornado. O operador não deve adicionar participantes nem editar eventos em paralelo.

Delta segue links opacos depois de validar origem/caminho, descarta conteúdo de eventos alheios e mantém cursors só em memória. Requests tem TLS normal, sem redirects, timeout e sem proxies/.netrc implícitos. Falhas 429/5xx, cursor expirado ou consistência eventual além da espera limitada falham explicitamente; o probe não implementa o worker resiliente de produção. Tokens, URLs de delta e payloads não são impressos/persistidos. MSAL/HTTP logging fica desativado.

## Limpeza e recuperação

Limpeza é tentada no fim e em caso de falha, sempre com as mesmas guardas. Se o output disser `pending_use_same_journal`, preservar o ficheiro e executar após resolver autenticação/rede:

```powershell
& $probePython scripts/outlook_probe/probe.py cleanup --config "$env:USERPROFILE\.ho001-probe\config.json" --state "$env:USERPROFILE\.ho001-probe\run-01\state.json" --allow-live
```

O fingerprint liga o journal à mesma conta, tenant e registo. Um POST sem resposta é recuperado por marcador aleatório e transactionId guardados antes da chamada. Zero ou vários resultados deixam `ambiguous_create_requires_operator_recovery`: não repetir POST nem apagar por título; inspecionar privadamente apenas os identificadores registados. Erro de propriedade/attendees exige intervenção privada do operador. A ferramenta nunca contorna a guarda para limpar. Eventos ausentes (404) contam como removidos. Manter journal até confirmar todas as intenções resolvidas.

O resumo stdout e `evidence.json` no mesmo diretório contêm só etapas/códigos agregados. O journal contém IDs técnicos sensíveis: nunca o anexar ao PR. `calendar_probe_passed=true` cobre apenas o ciclo do calendário; conferir também `pagination`, `revocation`, `cleanup` e login dos clientes. `integration_verified` fica sempre falso neste probe, porque não pode certificar o conjunto da integração.

## Revogação opcional e reconexão

Acrescentar `--revocation-check` ao `run` autorizado. **Depois da limpeza**, o probe pausa para o operador revogar apenas o consentimento deste registo de teste no portal da conta (My Apps/gestão de aplicações organizacional ou permissões de aplicações da conta pessoal, conforme o tipo e política). Não usar uma operação de revogação de todas as sessões do utilizador. Retomar localmente com Enter.

O probe força refresh, elimina cache local e inicia seleção/consentimento novamente. `refresh_denied_then_reconnected` significa refresh recusado e login repetido, não prova causal exclusiva de revogação: Conditional Access também pode exigir interação. `revocation_not_observed_reconnected` significa que o efeito não foi observado; propagação pode demorar. Logout/apagar cache não é evidência de revogação. No final, verifica leitura do calendário sem imprimir conteúdo. Se revogação/reconexão não for permitida ou não tiver efeito observável, registar a limitação e manter esse critério pendente.

## Evidência desta entrega

19 testes locais passaram com fixtures sintéticas. Cobrem vinculação explícita MSA, propriedade, recusa de attendees/conta errada, journal fora do Git, recuperação de POST ambíguo, paginação/URLs não confiáveis, descarte de dados privados simulados, DST, ciclo CRUD/delta simulado e falhas redigidas. **Não há evidência Graph real, login Web/Flutter real ou webhook real.** HO-001 fecha apenas a mudança documental de âmbito. Critérios reais adiados pertencem a HO-008/HO-009; este probe não valida futuros clientes Web/Flutter.
