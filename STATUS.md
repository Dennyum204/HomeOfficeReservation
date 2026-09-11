# Estado do projeto

Atualizado: 2026-09-11.

HO-015 selecionado na [issue #40](https://github.com/Dennyum204/HomeOfficeReservation/issues/40), branch `codex/ho-015-web-administration`, worktree próprio a partir de `origin/main` após fetch. [Histórico anterior preservado](docs/history/HO-015-status-before-reconciliation.md).

HO-014 foi integrado pelo responsável em [PR #43](https://github.com/Dennyum204/HomeOfficeReservation/pull/43), em 2026-09-11T07:56:17Z, commit `e12d5ccafaa8a2e336743eacf6f2b1ef5a1ee8e9` confirmado no histórico remoto. Teste manual aprovado. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34576735019) passou; a primeira [integração core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34576735065) passou backend/Web mas falhou Android após o teste terminar, numa consulta push durante encerramento. Repetição na mesma base em curso para registar a intermitência; correção e regressões no âmbito dos checks de HO-015. A falha inicial não conta como sucesso. Dependências HO-011/013 já integradas, com evidência preservada no histórico/backlog; o código HO-014 está na base, com esta ressalva de integração.

HO-015 em implementação: administração Web por clientes gerados, convites/entrega, papéis/suspensão e chefias; recuperação de escritas incertas e controlo de versão administrativo. Migração aditiva `20260911080127_WebAdministrationConcurrency`, contratos regenerados. [Guia](docs/HO-015-WEB-ADMINISTRATION.md), [ADR-016](docs/adr/ADR-016-web-administration.md). Verificação final e quatro checks remotos ainda por concluir; nenhum PR está pronto por inferência de resultados locais.

HO-012 permanece incompleta no [PR draft #37](https://github.com/Dennyum204/HomeOfficeReservation/pull/37), sem alterações nesta tarefa. NAS DS218+, Celeron J3355, 2 GB, Docker: teste reportado do túnel `nas-connectivity-test` demonstrou só conectividade Cloudflare Tunnel, sem hostname/rotas, ensaio terminado, sem alterações no router. HomeOffice não instalado nem medido; alojamento pago não escolhido/contratado. Sem deployment, DNS, emails reais, distribuição APK, merge ou auto-merge.

Contas, configuração privada, bases e emuladores habituais preservados. HO-015 usa ambiente sintético isolado com email local. Administração Android, redesign HO-016, iOS e Outlook fora do âmbito. Próxima tarefa exige seleção explícita após revisão/merge humano.
