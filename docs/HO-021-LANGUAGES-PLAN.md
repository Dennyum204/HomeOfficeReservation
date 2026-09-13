# HO-021 — Português, inglês e alemão (planeamento)

[Issue #50](https://github.com/Dennyum204/HomeOfficeReservation/issues/50). Segundo PR, apenas para registar o âmbito; implementação **não iniciada**, após revisão de [HO-020 / PR #51](https://github.com/Dennyum204/HomeOfficeReservation/pull/51). O inventário canónico dos dois itens é atualizado no primeiro PR; esta proposta documental será reconciliada com main quando HO-020 for integrada.

## Critérios preservados

- Manter português e acrescentar inglês e alemão na Web e no Android.
- Seleção de idioma em Definições, preferência persistente e comportamento inicial documentado.
- Traduzir navegação, formulários, modais, estados, validações e mensagens visíveis, incluindo acessibilidade e plurais.
- Formatar datas e números de acordo com o idioma, preservando valores date-only, instantes e regras de fuso horário do domínio.
- Não traduzir conteúdo dos utilizadores nem modificar códigos de estados ou contratos da API.
- Reutilizar a infraestrutura de localização existente; verificar textos alemães longos, truncagem e strings sem tradução.
- Definir explicitamente o tratamento de emails e notificações produzidos no servidor. Não declarar suporte completo enquanto essas mensagens estiverem por tratar.

## Entrega posterior

Inspecionar o estado real após a revisão de HO-020, selecionar a abordagem mínima de localização, implementar Web/Android e testar os percursos com dados sintéticos. Atualizar tracking, contratos apenas se necessários e os quatro checks obrigatórios no commit final. Este registo não significa que qualquer idioma novo esteja disponível.

PR #37, piloto Pi, contas e configuração privadas mantêm-se independentes. Sem deployment, merge, auto-merge ou implementação de iOS/Outlook.
