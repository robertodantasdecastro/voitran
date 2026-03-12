# Project State - Voitran

## Objetivo atual
Criar e evoluir um produto `local-first` de chamada com traducao de voz em tempo real, sintese local e governanca de identidade vocal.

## Root oficial
- `/Volumes/SSDExterno/Desenvolvimento/iatools/voitran`

## Git oficial
- repositorio local dedicado na raiz do projeto;
- branch default: `main`;
- remote oficial: `git@github.com:robertodantasdecastro/voitran.git`;
- bootstrap publicado em `origin/main` em `2026-03-12`.

## Estrutura principal
- `apps/`
- `backend/`
- `packages/`
- `docs/`
- `.agent/`
- `.antigravity/`
- `scripts/`

## Runtime externo oficial
- `/Volumes/SSDExterno/Voitran_runtime`
- subpaths ativos para a fase 1 de voz local:
  - `/Volumes/SSDExterno/Voitran_runtime/voices/samples`
  - `/Volumes/SSDExterno/Voitran_runtime/voices/consents`
  - `/Volumes/SSDExterno/Voitran_runtime/voices/profiles`
  - `/Volumes/SSDExterno/Voitran_runtime/voices/outputs`
  - `/Volumes/SSDExterno/Voitran_runtime/logs/voice-sidecar`

## Topologia oficial de agentes
- `Mac`
  - papel: shell do produto, inferencia local, benchmark e memoria viva
- `Backend`
  - papel: sessao, token, presenca, eventos e observabilidade
- `AntigravityIDE`
  - papel: continuidade estrutural, revisao e sincronizacao de contexto

## Portas previstas
- `8080` -> backend/control-plane
- `7880` -> referencia comum de `RTC` quando houver integracao local de laboratorio

## Estado operacional esperado
- stack local desligado por padrao fora de trabalho;
- `WF_NovoProjeto` usado como entrada do ciclo;
- `sync_memory --check` obrigatorio antes de fechar tarefa;
- modelos e caches fora do repo;
- artefatos `AppleDouble` `._*` devem ser ignorados e removidos quando surgirem no workspace.

## Estado atual de produto
- `VoitranMac` possui fluxo guiado de `Voice Lab` para consentimento, gravacao local, build de perfil e preview de sintese;
- sidecar local em `Python` responde via CLI JSON para operacoes de voz;
- fallback atual de preview usa `system-say` se `OpenVoice V2` nao estiver instalado no runtime;
- perfil vocal local ja possui contrato pronto para reuso nas proximas fases;
- app macOS gerencia o lifecycle das dependencias da fase atual ao abrir e fechar;
- pacote instalavel `.pkg` e bundle `.app` estao preparados em `dist/`.
