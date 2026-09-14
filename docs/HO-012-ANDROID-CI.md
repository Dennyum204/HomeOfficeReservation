# HO-012 — Diagnóstico do transporte Android na CI

2026-09-11. [Run falhado, tentativas 1/2](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34641298643), commit b941947c749b55ae328250bae33e51e68e63af64.

As duas falhas terminam com `getIsolate: Service connection disposed` e `adb: device offline`. Na primeira, login/ativação passaram e a ligação caiu na abertura da suite de notificações. Na segunda, falhou antes das asserções de login. Compilação/instalação do APK e readiness real API/PostgreSQL passaram; isso não aprova as suites que não terminaram.

Comparação com [integração main verde](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34605827090): mesmo runner ubuntu-24.04 20260907.300.1, emulador 37.1.11.0 build 15917651, API 35 google_apis x86_64, pixel_6, 2560 MB e ação fixada. Não há evidência de que trocar/diminuir versão do emulador resolva a causa. O código funcional Flutter e os testes são os mesmos de main; HO-012 acrescenta a preparação de assinatura/build, mas a relação causal não foi demonstrada.

Os logs disponíveis não permitem distinguir queda/reinício do servidor ADB, problema de transporte do emulador ou pressão/OOM no host. Não declarar causa de infraestrutura ou bug da aplicação como comprovados.

`scripts/android_ci_diagnostics.py` acrescenta observação limitada ao runner descartável: consulta read-only do servidor ADB existente (sem o iniciar/reiniciar), estado apenas de emulator-5554, PIDs/RSS de ADB/emulador, memória/swap, load e contadores OOM. Amostra a cada 5 s durante no máximo 25 minutos, incluindo boot e suites. Não recolhe linha de comandos, ambiente, logs da app, screenshots adicionais, tokens ou payloads. Artifact `android-transport-diagnostics` retido 14 dias, mesmo após falha. Serve para confrontar o instante da falha com desaparecimento dos processos/mudança de PID e pressão; não é correção nem teste funcional.

Nenhum retry de mutações/suites, alteração de timeouts ou desativação de checks. Os quatro checks obrigatórios permanecem. Uma futura execução verde, por si só, não demonstra que a causa intermitente foi corrigida. PR #37 continua draft por HO-012 incompleta.

Fontes oficiais consultadas em 2026-09-11: [arquitetura e estado ADB](https://developer.android.com/tools/adb), [ação na revisão usada](https://github.com/ReactiveCircus/android-emulator-runner/blob/a421e43855164a8197daf9d8d40fe71c6996bb0d/README.md). Distinguir cliente, servidor e daemon antes de atribuir a desconexão.
