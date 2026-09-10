# ADR-013 — Preparação do piloto Web/Android

Data: 2026-09-10. Estado: **proposta técnica implementada para ensaio; contratação e deployment por aprovar**.

HO-011 foi integrado no PR #36. O piloto terá dois utilizadores, aplicação monolítica, worker no mesmo processo e PostgreSQL. As decisões anteriores de Identity, notificações e adiamento de iOS/Outlook mantêm-se.

Propõe-se um pequeno servidor Linux Hetzner por ambiente, em Nuremberga: Caddy termina HTTPS e encaminha Web/API para a mesma origem; a imagem ASP.NET inclui os assets React. PostgreSQL e a API não publicam portas no host. O worker permanece ativo com a API. Staging e produção têm máquinas, volumes, contas, passwords, key rings, certificados e configuração Firebase separados. Não se importam contas, dispositivos ou eventos de desenvolvimento para produção.

A proposta privilegia custo previsível, memória suficiente e uma configuração reproduzível, com três contentores por ambiente. Implica assumir atualizações Linux/PostgreSQL, vigilância e restauros; não há alta disponibilidade. A alternativa gerida Render reduz essa manutenção e tem recuperação PostgreSQL integrada, mas custa mais para dois ambientes e oferece menos memória nos planos de entrada. [Comparação, orçamento e limitações](../HO-012-PILOT.md).

Só Caddy (`10.77.0.2` na rede dedicada) é proxy confiável. Não se usa confiança irrestrita em headers enviados pelo cliente. O hostname permitido é explícito; cookies e CSRF seguros mantêm o desenho Identity. Rotas React conhecidas têm fallback; rotas API desconhecidas continuam 404. Health/readiness são operacionais e bloqueados no proxy público; readiness em produção também exige migrações aplicadas. Configuração privada absoluta substitui ficheiros locais de desenvolvimento em produção. Não há migração ou contas sintéticas automáticas.

As chaves Data Protection são persistidas e cifradas por certificado PFX. O nome da aplicação inclui o ambiente. A recuperação preserva ambiente, chaves antigas, certificado e password; trocar apenas a imagem não deve terminar sessões. O certificado cifrado acompanha o backup, mas a sua password e os acessos de recuperação ficam também num cofre independente. Restic cifra a cópia fora do servidor. Restaurar exige uma base nova e validação da aplicação; um comando SQL bem-sucedido não basta.

Android mantém `dev.homeoffice.homeoffice_mobile`. Proposta de distribuição: APK assinado, Firebase App Distribution, grupo privado de dois participantes, sem loja pública. A chave real é externa e estável; a chave descartável da CI prova apenas o mecanismo. Uma versão assinada de forma diferente não substitui a instalação debug existente; não se apaga essa instalação para resolver o conflito. Usar dispositivo/perfil separado quando autorizado.

Consequências: breve manutenção durante backups consistentes/migrações, restauro manual, e acompanhamento operacional pelo responsável. RPO 24 h e RTO 4 h são objetivos propostos, não SLA. O ensaio automatizado é isolado, sem entrega externa de email, FCM ou participantes reais. HO-012 continua incompleto até aprovação, deployment e aceitação do piloto.

Fontes oficiais consultadas em 2026-09-10: [ASP.NET e proxies](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/proxy-load-balancer?view=aspnetcore-10.0), [Caddy reverse proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy), [PostgreSQL pg_dump](https://www.postgresql.org/docs/18/app-pgdump.html), [restic e repositórios cifrados](https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html), [Flutter release Android](https://docs.flutter.dev/deployment/android).
