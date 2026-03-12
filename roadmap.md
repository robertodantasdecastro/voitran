# Roadmap do Voitran

Este roadmap e editavel e deve ser atualizado a cada fechamento de fase ou mudanca relevante de escopo.

## Janela de 90 dias

| Horizonte | Inicio | Fim | Objetivo | Status | Owner | Gate | Saida | Risco | Proximo passo |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Sprint 0 | 2026-03-09 | 2026-03-15 | Bootstrap do repo, governanca, workflows e esqueletos tecnicos | ativo | Mac | memoria viva e scripts base validos | repo inicial publicado | push inicial e validacao do shell `SwiftUI` | iniciar `Etapa 1A` |
| Sprint 1 | 2026-03-16 | 2026-04-07 | Captura de audio, `VAD` e `STT` local no macOS | planejado | Mac | benchmark de latencia aprovado | pipeline parcial local | custo de CPU e memoria | integrar WhisperKit |
| Sprint 2 | 2026-04-08 | 2026-05-07 | Traducao local, `TTS`, leitura de texto e `Voice Lab` baseline | planejado | Mac | traducao `PT-BR <-> EN` validada | experiencia local ponta a ponta | qualidade de voz e prosodia | consolidar politicas de identidade vocal |
| Sprint 3 | 2026-05-08 | 2026-06-07 | Backend/control-plane, dual-band e smoke de duas pontas | planejado | Backend | sessao e reconexao funcionando | alpha desktop-to-desktop | integracao `RTC` | ativar E2EE e capability negotiation |

## Visao de 12 meses

| Horizonte | Inicio | Fim | Objetivo | Status | Owner | Gate | Saida | Risco | Proximo passo |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-Q2 | 2026-03-09 | 2026-06-30 | `macOS MVP` local-first com `Voice Lab` governado | ativo | Mac | smoke PT/EN e TTS aprovados | MVP de desktop | latencia e UX | iniciar beta backend |
| 2026-Q3 | 2026-07-01 | 2026-09-30 | backend beta com sessao, presenca, eventos e `E2EE` | planejado | Backend | room e reconexao estaveis | beta desktop-to-desktop | operacao `RTC` | preparar alpha iOS |
| 2026-Q4 | 2026-10-01 | 2026-12-31 | alpha `iOS` e base nativa `Android` | planejado | Mac + Backend | capability tiers definidos | alpha cross-device | fragmentacao Android | validar degradacao segura |
| 2027-Q1 | 2027-01-01 | 2027-03-31 | beta multi-plataforma e gates para `GA` | planejado | Produto | testes beta fechados | release candidate | custo operacional | revisar readiness comercial |
