# Estado do projeto

Atualizado: 2026-09-08.

## Estado verificável

- HO-000 integrado pelo [PR #25](https://github.com/Dennyum204/HomeOfficeReservation/pull/25), merge humano `7257a7b0c88f456b4322da396d45bd4c0aa0e862`, 2026-09-08 18:39:50Z. Commit confirmado em main após fetch e [CI de integração verde](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34264376475); estado canónico `done`.
- HO-001 reformulado por instrução explícita do responsável: **core autónomo com calendário e contas próprios; Outlook opcional**. Mesmo [PR #27](https://github.com/Dennyum204/HomeOfficeReservation/pull/27), branch `docs/ho-001-microsoft-outlook-study`; estado canónico `review`, não `done` antes do merge verificado.
- [ADR-004](docs/adr/ADR-004-independent-core.md) escolhe ASP.NET Core Identity/EF Core/PostgreSQL, cookie Web e bearer/refresh opacos do framework no Flutter. Sem Microsoft obrigatório nem infraestrutura de identidade adicional. Aplicação ainda não implementada.
- HO-008 mantém issue/ID, agora no marco `outlook-publish` posterior ao core. HO-009 mantém issue/ID no marco `outlook-sync`, posterior à publicação. Gates de scaffold, autenticação, calendário, aceitação e piloto não exigem acesso Microsoft. As versões v1.1/v1.2/v2.0 preservam os restantes trabalhos.
- Onboarding Microsoft e probe real **parados**. O utilizador confirmou uma mailbox dedicada vazia; houve erro de acesso ao diretório no portal Entra. Nenhum registo/consentimento Graph confirmado, evento ou leitura Graph real executado. A conta anteriormente indicada não é presumida como mailbox de teste; nenhum endereço publicado.
- Configuração privada permanece fora do repositório, sem consentimento marcado. [Estudo](docs/HO-001-MICROSOFT-OUTLOOK-STUDY.md), ADR-002 e probe preservados como referência histórica opcional. **Validação Graph adiada por âmbito, não aprovada.** Próximas verificações reais pertencem a HO-008/HO-009, sem exigir implementar clientes completos para fechar HO-001.
- Evidência local anterior: 19 testes sintéticos do probe, pip check e plano offline de seis fixtures/DST 23/25 horas passaram. CI normal passa a executar apenas `project-docs`; testes do probe são opção manual explícita, nunca chamam Microsoft. Resultado do último SHA e ausência de conflitos registados no PR após o último push.
- Repositório público e stack .NET 10/PostgreSQL/React/Flutter preservados. 24 issues estáveis, milestones core e dois marcos Outlook opcionais; URLs reais no JSON. HO-002 não iniciado; sem projetos compiláveis, migrações ou deployment.
- Proteções main mantidas: PR/check estrito `project-docs`, conversas resolvidas, histórico linear, admins incluídos, zero aprovações independentes obrigatórias, force-push/deletion proibidos; sem auto-merge.

## Próxima tarefa

**HO-002 — Monorepo compilável, contratos e CI.** Após revisão/merge humano do PR #27, fazer fetch, verificar merge e CI, reconciliar HO-001 para `done` e criar branch de scaffold. Preparar .NET/React/Flutter, PostgreSQL local, versões/lockfiles e geração OpenAPI sem conta Microsoft. HO-003 implementará autenticação própria; não implementar já a aplicação inteira.

A issue #2 fecha a reformulação documental quando este PR for integrado; nunca significa que Graph foi validado. HO-008/HO-009 permanecem planeados/abertos. Codex não faz merge nem ativa auto-merge.

## Decisões externas pendentes

Alojamento/região/domínio, entrega de recuperação de conta, assinatura/distribuição mobile e piloto são trabalhos core posteriores. Configuração Microsoft só será retomada se o responsável selecionar o milestone opcional. Nenhum destes recursos foi contratado nesta entrega.
