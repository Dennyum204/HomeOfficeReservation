# Estado do projeto

Atualizado: 2026-09-08.

## Estado verificável

- HO-000 integrado pelo [PR #25](https://github.com/Dennyum204/HomeOfficeReservation/pull/25), merge humano `7257a7b0c88f456b4322da396d45bd4c0aa0e862`, 2026-09-08T18:39:50Z; [CI de integração verde](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34264376475). Estado canónico done.
- HO-001 integrado pelo [PR #27](https://github.com/Dennyum204/HomeOfficeReservation/pull/27), merge humano `7f783bf9bde5a72ac8271c42cc2916b054170d17`, 2026-09-08T20:02:47Z. Commit confirmado em origin/main após fetch; [CI de integração verde](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34272493270). Estado canónico reconciliado para **done** nesta branch.
- HO-001 concluiu apenas o âmbito documental revisto: calendário próprio, autenticação independente Identity e Outlook opcional. **Validação Graph real adiada, não aprovada**. Onboarding parado, sem novo registo/consentimento/chamadas Graph. HO-008/HO-009 mantêm issues e milestones opcionais; pesquisa/probe/configuração privada preservados.
- **HO-002 em review** no [PR #28](https://github.com/Dennyum204/HomeOfficeReservation/pull/28), branch `feat/ho-002-project-scaffolding`, issue [#3](https://github.com/Dennyum204/HomeOfficeReservation/issues/3). Backend .NET 10/EF Core/PostgreSQL, shells React/Flutter PT-PT, clientes gerados e Compose criados. Sem autenticação funcional, calendário, aprovações, notificações ou migrations de negócio. Ver [fundação](docs/HO-002-FOUNDATION.md) e guias de área.
- Evidência local: build backend sem warnings, 2 testes API; Web typecheck/lint/build, 2 testes UI sintéticos e 4 E2E browser com API real; Flutter análise e 2 widget tests sintéticos; cliente Dart fez chamada real ao Kestrel. Contratos reproduzíveis. Nenhuma destas verificações é Graph ou validação de futuros fluxos de negócio.
- CI HO-002 exige `project-docs`, `backend-contracts`, `web`, `flutter-android` e `flutter-ios`; probe Outlook apenas manual opcional. Inclui PostgreSQL Compose real, builds Android/iOS e ligação nativa à API. A conclusão e o SHA do commit final são registados no [PR #28](https://github.com/Dennyum204/HomeOfficeReservation/pull/28/checks), antes de retirar draft; uma tentativa anterior com erro não conta como check verde. No Windows atual não há Docker/Android SDK; iOS requer macOS. Assinatura, lojas, dispositivos físicos e push são tarefas posteriores.
- Proteções main confirmadas por API: PR, os cinco checks acima com `strict: true` e GitHub Actions (`app_id: 15368`), conversas resolvidas, histórico linear, admins incluídos, zero aprovações independentes obrigatórias, sem force-push/deletion. Sem auto-merge.

## Continuidade

HO-002 propõe a conclusão do scaffold no mesmo PR e issue #3. A entrega exige CI do último commit verde e ausência de conflitos; o PR mantém draft enquanto existir algum critério pendente. O estado canónico fica em **review**, nunca done, até merge humano e CI de integração verificados. Nenhum deployment/merge/auto-merge pelo Codex.

Após revisão/merge humano de HO-002 e reconciliação de merge/CI: **HO-003 — autenticação própria, membros e relações de gestão**, conforme ADR-004. Não foi iniciada.

## Decisões externas pendentes

Alojamento/região/domínio, entrega de recuperação de conta, assinatura/distribuição mobile e piloto pertencem a tarefas core posteriores. Microsoft apenas se for selecionado um marco opcional. Nenhum recurso foi contratado ou publicado nesta entrega.
