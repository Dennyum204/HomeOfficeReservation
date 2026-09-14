# Correção da navegação do piloto

O responsável identificou caracteres estranhos e seleção fora da largura do menu, particularmente nos textos alemães. O componente tinha símbolos literalmente mal descodificados (`â€º`, `Â·`) e a grelha mantinha o tamanho mínimo pelo conteúdo, ultrapassando a barra de 206 px. Não era erro dos dados da conta nem dos tokens de idioma.

Removida a seta decorativa; a linha PT–CH usa uma borda pontilhada CSS e o separador do rodapé está em UTF-8 correto. A navegação ocupa uma coluna explícita, os botões ficam contidos e os nomes longos podem quebrar linha. Ícones e seleção ficam alinhados dentro da barra, sem sobrepor o conteúdo.

Por pedido explícito, a barra abre por defeito e tem um botão de recolher/expandir. Recolhida mostra logótipo e ícones com nomes acessíveis, tooltip e badge de notificações; expandida mostra os nomes. Mantém seleção e foco ao alternar pelo teclado. Em viewport estreito adapta-se à grelha superior existente, sem overflow. Não altera dados, permissões ou API.

Seis testes browser locais com API/PostgreSQL isolados passaram: PT/EN/DE × desktop/viewport estreito, em claro e escuro, contenção dos itens, ausência de caracteres mal descodificados, navegação recolhida, Enter/Espaço e foco. [24 capturas sintéticas](evidence/ho012-sidebar/README.md). As capturas recebidas do responsável são a referência anterior; não foram publicadas com dados da sua conta.

A publicação deve usar nova imagem ARM64 nativa verificada na CI, com captura local prévia e troca exclusiva de `app`. Reutilizar o procedimento de atualização, exigindo a imagem anterior `9dcc371` e sem alterar os backups agendados. PR #37 permanece draft até os gates operacionais acordados; esta correção não acrescenta gates ao piloto.
