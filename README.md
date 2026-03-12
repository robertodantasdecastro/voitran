# Voitran

Voitran e uma linha de produto para chamadas com traducao em tempo real, sintese de voz e governanca de identidade vocal orientada por IA.

## Objetivo
- entregar uma base `local-first` para traducao de voz em tempo real entre `PT-BR` e `EN`;
- comecar pelo `macOS` em `Apple Silicon`;
- evoluir para backend de sessao/controle em `Go` com transporte `RTC`;
- expandir para `iOS` e `Android` nativos.

## Etapas do produto
1. `macOS`: captura de audio, `STT`, traducao local, `TTS`, leitura de texto e `Voice Lab`.
2. `backend`: controle de sessao, presenca, dual-band, eventos e observabilidade.
3. `mobile`: `iOS` e `Android` nativos com negociacao de capacidade por dispositivo.

## Stack base
- `SwiftUI` no `macOS` e, depois, no `iOS`
- `Go` no `backend/control-plane`
- `WhisperKit` e `whisper.cpp` como referencias de `STT`
- `TranslateGemma` e benchmarks com `Seamless`
- `TTSKit` como base de sintese local
- `LiveKit` como referencia de transporte/sinalizacao

## Governanca operacional
- workflow oficial de entrada: `.agent/workflows/WF_NovoProjeto.md`
- memoria viva versionada: `docs/memory/`
- memoria operacional: `.agent/memory/`
- compatibilidade Antigravity: `.antigravity/`
- regra local de projeto: `AGENTS.md`

## Bootstrap do ciclo
1. Ler `AGENTS.md`.
2. Ler `docs/07-workflow-codex.md`.
3. Ler `docs/memory/PROJECT_STATE.md`, `DECISIONS.md` e `CHANGELOG.md`.
4. Ler `.agent/memory/CONTEXT_PACK.md`.
5. Rodar `bash scripts/sync_memory.sh --check`.
6. Seguir `.agent/workflows/WF_NovoProjeto.md`.

## Estrutura principal
- `apps/macos/VoitranMac`
- `apps/ios`
- `apps/android`
- `backend/control-plane`
- `packages/realtime-core-swift`
- `docs/`
- `.agent/`
- `.antigravity/`
- `scripts/`

## Estado inicial do lote 1
- documentacao viva criada;
- workflows e regras globais publicados;
- `backend/control-plane` stubado em `Go`;
- shell `SwiftUI` do `VoitranMac` publicado;
- placeholders de `iOS` e `Android` criados.

## Instalacao macOS
- gerar bundle local: `bash scripts/build_voitran_macos_app.sh`
- gerar pacote instalavel: `bash scripts/package_voitran_macos.sh`
- instalar localmente: `bash scripts/install_voitran_macos.sh`

## Lifecycle local do app
- ao abrir, o `VoitranMac` inicia as dependencias reais da fase atual via `scripts/voitran_services.sh start-all`
- ao fechar, o app encerra os servicos gerenciados via `scripts/voitran_services.sh stop-all`
- o painel `Settings` exibe e gerencia `Voice Runtime`, `Voice Sidecar CLI` e `Control Plane`
