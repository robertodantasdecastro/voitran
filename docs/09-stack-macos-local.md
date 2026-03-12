# Stack macOS Local

## Objetivo
Detalhar a base tecnica da `Etapa 1` no `macOS`.

## Stack alvo
- `SwiftUI`
- `AVAudioEngine`
- `WhisperKit` como referencia principal de `STT`
- `whisper.cpp` como fallback e benchmark
- engine de traducao plugavel
- `TTSKit` como base de sintese local

## Principios
- priorizar latencia percebida pelo usuario;
- segmentar a pipeline para medir gargalos;
- desacoplar UI, servicos e core;
- manter modelos e caches fora do repo.

## Jobs associados
- `J02_preflight_local`
- `J05_benchmark_stt_mt_tts`
- `J06_voice_lab_ingest`
- `J07_voice_lab_eval`
