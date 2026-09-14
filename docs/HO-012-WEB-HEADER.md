# Web: conteúdo sem cabeçalhos globais

Refinamento solicitado pelo responsável em 2026-09-14, no PR #37. A Web deixa de apresentar o painel global de sessão e a barra de contexto/tema. A navegação expansível mantém-se; o conteúdo começa pelo título da secção. O slogan do calendário foi substituído por **Calendário / Calendar / Kalender**.

**Definições → Conta e sessão** reúne a identidade autenticada, email, organização, papéis, Verificar sessão e Terminar sessão. Tema e idioma continuam em Definições. Os nomes de conta/organização do ensaio são dados existentes, não uma faixa de estado da aplicação; ficam preservados e deixam de aparecer no topo de cada página. Esta alteração visual não renomeia contas nem converte o piloto numa instalação de produção separada (HO-018).

A leitura inicial da sessão, atualização ao receber foco, tratamento de sessão expirada/proibida, CSRF, logout e limpeza de dados continuam no AuthGate. Apenas a apresentação usa um contexto de ações. Desmontar Definições não desliga a validação automática. A troca de membro mantém a remontagem por MemberId; a chefia conserva o seletor de colaborador. Sem alteração de contratos, API, base de dados ou Android.

## Verificação

- TypeScript, ESLint e 19 testes unitários passaram.
- Seis novos percursos browser com API/PostgreSQL locais reais: PT/EN/DE, desktop e viewport estreito, claro/escuro; sessão manual, falha de logout simulada sem falso sucesso, logout real, limpeza do rascunho, persistência do logout após reload, nova conta de chefia e expiração automática fora de Definições.
- Regressão local de navegação, idiomas, editor, administração e tema/contraste: 16 percursos existentes. Testes antigos de sessão/ativação/aceitação foram adaptados para chegar às ações por Definições, preservando as verificações funcionais. A expiração natural com cookie curto permanece no teste específico da CI.
- [24 capturas sintéticas](evidence/ho012-web-header/README.md). Referências anteriores: capturas privadas enviadas pelo responsável e [navegação anterior](evidence/ho012-sidebar/README.md). Alvos táteis de sessão com pelo menos 44 px, foco e contraste existentes preservados.

## Atualização e recuperação

Publicação autorizada para o Pi: imagem Linux ARM64 compilada nativamente fora do Pi, checks do commit exato e ausência de conflitos antes da troca. Exigir a imagem atualmente instalada `3f8e8ace3ee6720c77a83ce9deffcfdc365362b0`. O procedimento privado reutiliza a atualização exclusiva da app, com captura local SQL/configuração/chaves e recuperação da imagem anterior se a saúde falhar. Credenciais e comandos com caminhos privados ficam fora do Git.

Até existir recibo de instalação e verificação pública dos assets, a nova publicação continua pendente. Não executar backup remoto, disparar timers ou enviar sinais à monitorização para esta alteração. PR #37 permanece draft enquanto faltar a evidência operacional já acordada; sem merge ou auto-merge.
