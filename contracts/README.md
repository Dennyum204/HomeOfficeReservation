# Contrato entre backend, Web e Mobile

Estado: desenho. HO-002 cria a especificação OpenAPI gerada pelo backend e a configuração reprodutível de geração dos clientes TypeScript/Dart. Não existe aqui uma especificação fictícia apresentada como completa.

## Convenções propostas

| Grupo | Operações esperadas |
|---|---|
| `/api/v1/me` | Identidade, papéis e relações visíveis |
| `/api/v1/calendar` | Projeção por intervalo, versão e avisos |
| `/api/v1/remote-requests` | Rascunho, submeter, detalhe, decisão por dias, retirar |
| `/api/v1/change-proposals` | Propor e resolver alteração de datas aprovadas |
| `/api/v1/onsite-requirements` | Criar, alterar, reconhecer leitura e resolver conflito |
| `/api/v1/tasks` | Atribuir, consultar e atualizar estado |
| `/api/v1/notifications` | Listar e marcar lida |
| `/api/v1/devices` | Registar/atualizar/remover token push do próprio utilizador |
| `/api/v1/integrations/outlook` | Ligar, estado, desligar e resolver divergência |

Estes são grupos de desenho, não endpoints implementados. Endpoints de decisão usam comandos explícitos; não expor um PATCH genérico que permita mudar `Approved=true` ignorando regras.

- IDs estáveis, datas date-only e instantes distintos.
- ETag/versão esperada e Idempotency-Key nos comandos relevantes.
- Erros Problem Details com código de negócio e correlation ID.
- Paginação e limites explícitos; nullability consistente.
- OpenAPI e clientes regenerados no mesmo PR da mudança.
- Alterações compatíveis/aditivas por defeito. Remoção/renomeação requer transição de clientes e decisão de versão.
- CI regenera e deteta diff; não editar manualmente código gerado.
