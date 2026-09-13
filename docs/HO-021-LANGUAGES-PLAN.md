# HO-021 — Português, inglês e alemão

[Issue #50](https://github.com/Dennyum204/HomeOfficeReservation/issues/50) · [PR #52](https://github.com/Dennyum204/HomeOfficeReservation/pull/52).

## Âmbito e integração da dependência

HO-020 foi testada e aceite pelo responsável e integrada pelo PR #51 em `main`, commit `e00bd1c3eb5b638a4e8dab35378ee47fd16ad8e0`, confirmado na história de `origin/main`. Documentação: [run 34784701259](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34784701259). Backend/contracts, Web e Android: [run 34784701252](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34784701252), todos verdes. Esta branch incorpora essa base, preservando o registo documental inicial de HO-021.

## Comportamento

- Web e Android disponibilizam português, inglês e alemão em **Definições → Idioma**, também acessível antes do login. O idioma inicial é português, independentemente do idioma do sistema. Uma preferência inválida regressa a português.
- A preferência pertence ao dispositivo/browser e mantém-se após logout e troca de conta. Não é uma preferência do perfil nem sincroniza Web com Android. Web usa `homeoffice.language` em localStorage e acompanha alterações de outras abas; Android reutiliza o armazenamento seguro existente, separado de tokens e da preferência de aparência. Falhas de armazenamento são visíveis e não impedem a utilização do idioma na sessão atual. As escritas Android são ordenadas e uma leitura tardia não substitui uma escolha mais recente.
- A Web reutiliza os seis catálogos tipados e o seletor existente. O React subscreve a escolha sem remontar a árvore: formulários, seleção, drafts e recuperação de operações não são apagados ao mudar idioma. O Android reutiliza ARB/gen-l10n e as localizações Material.
- Navegação, formulários, modais, permissões, erros, estados e nomes acessíveis são traduzidos. Plurais de dias e decisões respeitam singular/plural, incluindo zero.
- Apresentação regional: `pt-PT`, `en-GB` e `de-CH` (alemão adaptado à Suíça). Datas/horas mantêm a política anterior de instantes locais; planeamento mantém `Europe/Zurich`/`Europe/Lisbon` conforme o domínio. Uma data de trabalho é serializada pelos componentes ano/mês/dia, nunca por conversão de meia-noite em UTC.
- Nomes, comentários, motivos, títulos de tarefas e outros conteúdos escritos pelas pessoas permanecem no idioma original. Códigos de estados, IDs, contratos e regras da API não mudam. Não há migração, dependência nova ou alteração de autorização.

## Emails, notificações e limites explícitos

A caixa de notificações Web/Android traduz o **tipo de evento** do servidor através dos catálogos existentes. Ler conserva a semântica de HO-020: só após contexto autorizado apresentado e confirmação da API; não aprova nem confirma presenças. Conteúdo escrito pelas pessoas não é traduzido.

**Emails de ativação/recuperação e o texto discreto das push geradas no servidor continuam em português.** `AccountEmail.cs` e `PushSender.cs` não recebem uma preferência de idioma do destinatário; escolher o idioma no dispositivo não pode inferir uma preferência global de outra pessoa nem reescrever entregas duráveis pendentes. A aceitação do código Identity funciona nos três idiomas. Esta entrega disponibiliza três idiomas nas interfaces, não promete emails/push trilingues. Não foram enviados emails reais ou push externas nesta tarefa.

## Verificação reproduzível

Preparar contas sintéticas e PostgreSQL isolado conforme [Identity](HO-003-AUTHENTICATION.md). Não apontar testes para o piloto nem para bases pessoais.

```sh
python scripts/check_project.py
python scripts/generate_contracts.py --check
cd apps/web
npm ci
npm run format:check
npm run typecheck
npm run lint
npm test
npm run build
# HO_DEV_ACCOUNTS aponta para accounts.json privado; API usa base isolada
npx playwright test
cd ../mobile
flutter pub get --enforce-lockfile
flutter gen-l10n
flutter analyze
flutter test
flutter drive --driver=test_driver/languages.dart --target=integration_test/languages_test.dart -d <emulador-isolado> --dart-define-from-file=<ficheiro-privado>
```

`languages.spec.ts` usa API/PostgreSQL reais para reler rascunhos e comprovar preservação de texto e data; percorre idiomas, reload, logout e formulários administrativos em desktop/viewport estreito e claro/escuro. O teste administrativo existente passou a serializar a data pelos componentes locais: `toISOString()` podia transformar uma segunda-feira local em domingo perto da meia-noite. Não se alterou o comportamento do produto para acomodar o teste.

Os testes de catálogo comparam chaves e tipos; Flutter verifica também placeholders e persistência, concorrência de preferências e texto ampliado. Os restantes percursos de pedidos, convites, decisões, autorização e leitura automática continuam na suite funcional e nos quatro checks core.

Verificação local concluída: 18 testes unitários Web, format/typecheck/lint/build; 58 testes Flutter e análise/formatação; 178 ficheiros de contratos sem divergência. Os 36 E2E existentes passaram na campanha completa; os 4 E2E de idiomas passaram após corrigir as expectativas dos novos testes. O ensaio nativo de idiomas passou com 18 capturas. [34 capturas e condições](evidence/ho021/README.md). A CI remota do head final é verificada separadamente nos [checks do PR #52](https://github.com/Dennyum204/HomeOfficeReservation/pull/52/checks). Builds e capturas não representam deployment nem validação em Android físico. iOS e Outlook continuam adiados. PR #37, piloto Pi, dados, configuração privada e emuladores habituais são preservados.

## Revisão e recuperação

Selecionar **English** ou **Deutsch** em Definições → Idioma; percorrer calendário, pedido com dia individual, notificações e Administração. Confirmar as datas e os rótulos; voltar a português e verificar que o conteúdo escrito continua igual. Reabrir a aplicação para confirmar persistência. Credenciais sintéticas ficam apenas no guia local privado.

Para reverter, selecionar português. A reversão de código não exige reversão de base ou de chaves: não existem alterações de esquema, contratos, autenticação ou dados. Não fazer deployment sem tarefa própria.

Referências: [Flutter localization](https://docs.flutter.dev/ui/internationalization), [React useSyncExternalStore](https://react.dev/reference/react/useSyncExternalStore).
