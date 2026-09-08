# Estado do projeto

Atualizado: 2026-09-08.

## Estado verificável

- HO-000 integrado pelo [PR #25](https://github.com/Dennyum204/HomeOfficeReservation/pull/25), merge humano `7257a7b0c88f456b4322da396d45bd4c0aa0e862`, 2026-09-08T18:39:50Z; [CI de integração verde](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34264376475). Estado canónico done.
- HO-001 integrado pelo [PR #27](https://github.com/Dennyum204/HomeOfficeReservation/pull/27), merge humano `7f783bf9bde5a72ac8271c42cc2916b054170d17`, 2026-09-08T20:02:47Z. Commit confirmado em origin/main após fetch; [CI de integração verde](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34272493270). Estado canónico reconciliado para **done** nesta branch.
- HO-001 concluiu apenas o âmbito documental revisto: calendário próprio, autenticação independente Identity e Outlook opcional. **Validação Graph real adiada, não aprovada**. Onboarding parado, sem novo registo/consentimento/chamadas Graph. HO-008/HO-009 mantêm issues e milestones opcionais; pesquisa/probe/configuração privada preservados.
- **HO-002 em curso** na branch `feat/ho-002-project-scaffolding`, issue [#3](https://github.com/Dennyum204/HomeOfficeReservation/issues/3). Backend .NET 10/EF Core/PostgreSQL, shells React/Flutter PT-PT, clientes gerados e Compose criados. Sem autenticação funcional, calendário, aprovações, notificações ou migrations de negócio. Ver [fundação](docs/HO-002-FOUNDATION.md) e guias de área.
- Evidência local: build backend sem warnings, 2 testes API; Web typecheck/lint/build, 2 testes UI sintéticos e 4 E2E browser com API real; Flutter análise e 2 widget tests sintéticos; cliente Dart fez chamada real ao Kestrel. Contratos reproduzíveis. Nenhuma destas verificações é Graph ou validação de futuros fluxos de negócio.
- CI HO-002 acrescenta backend-contracts, web, flutter-android e flutter-ios, mantendo project-docs e probe opcional manual. Builds Android/iOS, PostgreSQL Compose e smoke nativos aguardam execução remota; conclusão do último SHA/URLs registadas no PR antes de retirar draft. No Windows atual não há Docker/Android SDK; iOS requer macOS. Assinatura, lojas, dispositivos físicos e push são tarefas posteriores.
- Proteções main existentes: PR, check estrito project-docs, conversas resolvidas, histórico linear, admins incluídos, zero aprovações independentes obrigatórias, sem force-push/deletion. Novos checks só serão acrescentados como obrigatórios após verificar nomes e resultados reais. Sem auto-merge.

## Continuidade

Concluir validação remota de HO-002, atualizar o mesmo PR e issue #3; só entregar pronto para revisão com CI do último commit verde e sem conflitos. A implementação fica em review até merge humano verificado. Nenhum deployment/merge/auto-merge pelo Codex.

Após revisão/merge humano de HO-002 e reconciliação de merge/CI: **HO-003 — autenticação própria, membros e relações de gestão**, conforme ADR-004. Não foi iniciada.

## Decisões externas pendentes

Alojamento/região/domínio, entrega de recuperação de conta, assinatura/distribuição mobile e piloto pertencem a tarefas core posteriores. Microsoft apenas se for selecionado um marco opcional. Nenhum recurso foi contratado ou publicado nesta entrega.
