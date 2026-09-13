# HO-012 — SMTP real: proposta para revisão

2026-09-13. Preparação apenas, PR #37 draft. Conta gratuita agora preparada pelo responsável; sessão confirmada e registos reais obtidos. Nenhuma chave SMTP obtida, alteração DNS/Pi ou mensagem enviada pelo agente. Backups, timers e monitorização não alterados nem executados.

## Estado inspecionado

AccountEmail.cs usa MailKit e MIME de texto simples para ativação/recuperação Identity. STARTTLS obrigatório, autenticação SMTP e timeout de 10 s já existem; logs omitem destinatário/código/credenciais. A entrega de convites reutiliza o worker/outbox de HO-014. SMTP aceite não prova entrega, leitura ou ativação; não existe feedback automático de bounces do fornecedor. Não são emails de aprovação/resumos (HO-101), nem alertas Healthchecks.

A preparação instalada usa Mailpit autenticado em mailpit:1025. Não foi identificado fornecedor SMTP externo configurado nos ficheiros do projeto. Isto não demonstra ausência de contas pessoais do responsável. Preservar Mailpit, contas sintéticas, chaves e dados.

Consulta GET autenticada Cloudflare em 2026-09-13: cinco registos, CNAME no apex, www e homeoffice, dois TXT de verificação Vercel. Nenhum MX, SPF, DKIM ou DMARC listado; nenhum registo no subdomínio proposto. Valores de verificação e identificadores omitidos. Reconsultar antes de eventual publicação. Não converter o CNAME apex nem tocar nos cinco registos existentes.

## Fornecedor e remetente propostos

**Brevo Free, SMTP partilhado, sem IP dedicado ou upgrade pago.** Plano gratuito anuncia 300 envios/dia, sem acumulação de quota; custo previsto zero dentro do plano. Conta e habilitação transacional estão por confirmar, limites/branding e aprovação anti-abuso podem afetar utilização. Não é garantia de entrega/SLA. Não comprar créditos ou ativar plano pago automaticamente. Para duas pessoas, o volume esperado de convites/recuperações é reduzido, mas abuso e retries também contam.

Remetente: **HomeOffice <no-reply@notificacoes.ferbatech.com>**. É um subdomínio de ferbatech.com dedicado ao envio, evitando alterações no apex/site e separando reputação/política. Não existe mailbox de resposta demonstrada: a proposta é apenas de envio. Não prometer receção de respostas nem inventar Reply-To; um contacto de suporte dependerá de endereço confirmado posteriormente.

Reutilizar eventual conta Brevo do responsável se existir e for adequada. Caso contrário, criar conta gratuita só após aprovação. A conta administrativa não tem de usar o endereço remetente. Não solicitar passwords/chaves no chat. Guardar SMTP login e chave SMTP (não API key) no diretório privado e kit de recuperação.

## Manifesto DNS para revisão — ainda não publicável

Adicionar domínio notificacoes.ferbatech.com em Settings → Senders, Domains, IPs → Domains, escolhendo autenticação manual. Não autorizar ligação automática que publique DNS. O painel gera os valores únicos abaixo; sem conta não se podem inventar valores DKIM ou código Brevo.

| Tipo | Nome relativo à zona ferbatech.com | Conteúdo / ação proposta |
|---|---|---|
| TXT | notificacoes | brevo-code=<valor real fornecido pelo painel> |
| CNAME (dois) ou TXT (um) | <seletor real>._domainkey.notificacoes | Seletores e destinos/chave exatos do painel; CNAME DNS only, sem proxy |
| TXT | _dmarc.notificacoes | v=DMARC1; p=none; adkim=r; aspf=r |

TTL Auto. DMARC p=none é observação inicial, não bloqueia falsificações; endurecer só após evidência de alinhamento e inventário de remetentes. Não acrescentar rua/ruf ou transmitir relatórios a terceiros sem decisão específica. Se o painel exigir relatório para uma funcionalidade, rever essa exigência, não inserir silenciosamente um destinatário.

No fluxo de autenticação partilhado documentado pela Brevo, SPF/MX adicionais não são necessários: o envelope usa infraestrutura do fornecedor e DKIM alinhado autentica o domínio visível. Preservar qualquer SPF/MX/DMARC encontrado numa releitura, nunca criar dois SPF/DMARC no mesmo nome. Um novo fluxo de branded subdomain pode propor registos adicionais: capturar o manifesto real e rever antes de publicar; não presumir que estes placeholders o substituem. Não criar MX no apex, mudar nameservers, routes Cloudflare ou instalar servidor de email no Pi.

## Configuração aplicacional proposta

O ficheiro de exemplo infra/pi/smtp/email.example.json é apenas um fragmento para revisão, NÃO uma configuração completa e NÃO carregado pelo Compose. Após autorização futura, atualizar só Email em private/https/application.json, preservando DB/Identity/Hosting/worker/DP. Não mudar Staging nem o purpose/key ring. Host smtp-relay.brevo.com, porta 587, STARTTLS já imposto no código. Não usar 465: o cliente atual não seleciona TLS implícito. Não usar Email:Transport=LocalSmtp.

O Compose atual deixa app apenas na rede interna trial e define SSL_CERT_FILE=/run/config/ca.pem para o Mailpit. Na ativação futura, juntar APENAS app a uma bridge de saída smtp_egress (sem portas publicadas, sem partilhar a rede de origem/conector), mantendo trial e limites atuais. Remover a variável SSL_CERT_FILE do ambiente efetivo para usar as CAs públicas da imagem; validar cadeia e hostname do fornecedor sem callbacks inseguros. Não apagar ca.pem: permanece necessário ao rollback Mailpit.

A bridge permite saída geral do app, não é uma firewall limitada ao host/porta SMTP. Rever esse aumento de acesso na autorização; PostgreSQL e Mailpit permanecem só internos. Cloudflare Tunnel não transporta este SMTP: ligação direta de saída TCP 587, sem router/port forwarding. Se bloqueada, parar e diagnosticar, não desativar TLS.

Não acrescentar ficheiros de configuração efetiva fora do conjunto de recuperação já existente: aplicação e compose privados HTTPS já estão incluídos no backup. Na futura aplicação, incorporar a rede na configuração privada HTTPS existente e atualizar a estratégia de SSL_CERT_FILE de forma explícita; o exemplo não deve ser acrescentado automaticamente a serviços systemd/trial.sh. Não alterar os backups nesta preparação.

## Sequência futura, condicionada a aprovação

1. Confirmar fornecedor/remetente, conta gratuita e ativação transacional. Obter manifesto DNS real e chave SMTP privada, sem enviar mensagens.
2. Rever/publicar apenas os registos aprovados; confirmar domínio e DKIM no fornecedor, sem substituir o site. DNS validado não prova entrega.
3. Antes de trocar o transporte, inventariar entregas pendentes/retries e destinatários no ambiente. Não liberar mensagens sintéticas .example ou convites antigos para a Internet. Resolver pelo mecanismo administrativo autorizado; nunca apagar filas ou dados diretamente. Só destinatários explicitamente autorizados para ensaio real.
4. Preservar cópia privada da configuração anterior; coordenar janela com timers existentes, sem forçar backup para substituir evidência agendada. Parar apenas app, aplicar configuração/rede/CA revistas e recriar apenas app. Nenhuma migração necessária. Não mudar chaves, contas ou reiniciar DB.
5. Verificar saúde e TLS/auth SMTP; depois de autorização de envio, testar um convite/aceitação e recuperação, falha/reenvio, quota/bounce e revogação. Examinar privadamente Authentication-Results: DKIM alinhado e DMARC pass, pasta spam e mensagem recebida; confirmar Web/Android aceitam o código. Não publicar cabeçalhos/código.
6. Falha: parar app, repor configuração/Compose anterior e confiança CA privada, recriar apenas app. Mailpit e volumes continuam existentes. Atenção: mensagens pendentes podem retomar no transporte reposto; confirmar estado antes de qualquer reenvio. Rollback não retira emails já enviados nem revoga automaticamente códigos; usar cancelamento autorizado.

## Verificação desta etapa e limitações

Revisão do adaptador, configuração base/HTTPS, rede e caminhos já capturados pelo backup; leitura DNS via API e documentação oficial. Exemplo JSON validado localmente, validator documental e diff check. Sem ligação/autenticação SMTP, entrega externa, DNS novo ou teste de rede no Pi. Sem alteração da aplicação, dos backups ou do disparo agendado. Valores únicos DNS e credenciais permanecem bloqueados pela escolha/conta do fornecedor; não há manifesto pronto a publicar até os obter.

## Fontes oficiais consultadas em 2026-09-13

- [Plano Free e limites](https://help.brevo.com/hc/en-us/articles/208580669-FAQs-What-are-the-limits-of-the-Free-plan).
- [Configuração SMTP e chave específica](https://help.brevo.com/hc/en-us/articles/7924908994450-Send-transactional-emails-using-Brevo-SMTP).
- [Autenticação DNS: código, DKIM e DMARC](https://help.brevo.com/hc/en-us/articles/12163873383186-Authenticate-your-domain-with-Brevo-Brevo-code-DKIM-DMARC).
- [Novo fluxo de domínio, em disponibilização gradual](https://help.brevo.com/hc/en-us/articles/35337929909778-Set-up-your-domain-in-Brevo).

HO-012 permanece incompleta: além do SMTP, evidência correlacionada de ciclos agendados, renovação TLS/monitorização geral, ambientes definitivos, Android físico/distribuição e aceitação final.

## Evolução da preparação da conta

Brevo Free e remetente aprovados; sessão da conta confirmada e registos reais obtidos no fluxo manual em 2026-09-13. Manifesto guardado fora do Git para revisão; nenhum DNS publicado. Painel pede verificação de telefone antes de envio. SMTP key não criada/obtida; remetente ainda não confirmado. DMARC sugerido pelo fornecedor inclui rua para Brevo, sujeito a decisão distinta. Pi/backups/envios preservados.

O fluxo novo permitiu omitir branded subdomain, escolher Individual DNS records e Manual. Registos obtidos: TXT de verificação com prefixo real `brevo-code:` (dois pontos, substitui o placeholder anterior com igual), CNAME brevo1._domainkey.notificacoes → b1.notificacoes-ferbatech-com.dkim.brevo.com e brevo2._domainkey.notificacoes → b2.notificacoes-ferbatech-com.dkim.brevo.com, TXT _dmarc.notificacoes. Sem delegação NS ou ligação automática Cloudflare. Valor único de verificação guardado no manifesto privado. O DMARC do painel é `v=DMARC1; p=none; rua=mailto:rua@dmarc.brevo.com`; alternativa proposta sem relatórios conserva `v=DMARC1; p=none; adkim=r; aspf=r`. Publicação e escolha de relatórios ainda pendentes; não clicar Authenticate como se o DNS estivesse validado.

## Publicação autorizada — validação pendente

Publicação DNS autorizada em 2026-09-13: quatro registos adicionados, TTL Auto/DNS only, DMARC v=DMARC1; p=none; adkim=r; aspf=r sem rua/ruf. Releitura API confirmou nove registos e preservação exata dos cinco anteriores. DNS público devolve CNAME corretos. Brevo reconhece código, mas DKIM/DMARC ainda pendentes; autenticação não declarada concluída. Nenhum SMTP/envio/Pi/backup alterado.

Recuperação futura: remover apenas os quatro registos de notificacoes e respetivos seletores, após rever dependências; IDs guardados no recibo privado quando disponíveis. Não remover registos do site ou túnel.

Reverificação: código e ambos DKIM reconhecidos pelo Brevo. DMARC público confirmado correto pelo resolvedor 1.1.1.1, mas o assistente Brevo exige uma tag rua; não é apenas propagação. Mantido DMARC aprovado sem relatórios. Conclusão da autenticação pendente de resolver exigência do fornecedor ou obter aprovação específica para relatórios, sem alteração silenciosa.

## Autenticação concluída após aprovação dos relatórios

DMARC rua=mailto:rua@dmarc.brevo.com acrescentado por autorização explícita em 2026-09-13, preservando p=none/adkim=r/aspf=r. DNS público confirmado; Brevo reconheceu os quatro registos e apresentou Your domain has been authenticated. Autenticação DNS concluída, não equivale a envio SMTP. Sem alteração no Pi/backups ou mensagens da aplicação; chave SMTP e verificação de telefone continuam pendentes.

Preparação SMTP concluída no fornecedor: verificação de telefone reportada pelo responsável e aviso removido; remetente HomeOffice <no-reply@notificacoes.ferbatech.com> Verified. Chave HomeOffice Pi SMTP criada pelo responsável, Active, expira em 2027-09-13 (também após 90 dias de inatividade segundo painel). Login/chave guardados apenas na pasta privada do PC com ACL restrita, transferência cifrada e releitura validada. Cópia Bitwarden confirmada pelo responsável. Sem aplicação ao Pi, autenticação SMTP ou envio de teste; estes continuam pendentes de autorização.

Ensaio SMTP isolado autorizado em 2026-09-13: Python 3.13.5 no host Pi, STARTTLS com validação pública, autenticação Brevo e uma única mensagem sintética aceite pelo relay; destinatário autorizado e recibo mantidos privados. Exit 0 e recibo descarregado no PC. Receção da mensagem confirmada pelo responsável em 2026-09-13; pasta inbox/spam não especificada e cabeçalhos DKIM/DMARC não inspecionados. Não valida MailKit nem rede do contentor: configuração da aplicação e backups/timers não alterados, nenhum convite/conta criado.
