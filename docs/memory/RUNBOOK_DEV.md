# Runbook Dev - Voitran

## Preflight
1. Garantir que o SSD externo esteja montado:
   - `/Volumes/SSDExterno/Voitran_runtime`
2. Garantir que segredos locais estejam fora do repo.
3. Rodar:

```bash
bash scripts/preflight.sh
bash scripts/sync_memory.sh --check
```

## Ciclo rapido
```bash
bash scripts/session.sh start
bash scripts/session.sh continue
bash scripts/session.sh save
bash scripts/session.sh sync
```

## Backend local
```bash
bash scripts/backend_dev.sh build
bash scripts/backend_dev.sh run
```

## Benchmark local
```bash
bash scripts/benchmark_local.sh smoke
```

## Voice Lab
```bash
bash scripts/voice_lab.sh bootstrap
bash scripts/voice_lab.sh health
bash scripts/voice_lab.sh list-profiles
bash scripts/voice_lab.sh ingest
bash scripts/voice_lab.sh eval
```

## Voice Lab sidecar
```bash
bash scripts/voice_runtime.sh health
bash scripts/voice_runtime.sh list-profiles
```

## Lifecycle e servicos
```bash
bash scripts/voitran_services.sh status-all
bash scripts/voitran_services.sh start-all
bash scripts/voitran_services.sh stop-all
```

## Build e instalacao macOS
```bash
bash scripts/build_voitran_macos_app.sh
bash scripts/package_voitran_macos.sh
bash scripts/install_voitran_macos.sh
```

## Validacao do app instalado
```bash
bash /Applications/VoitranMac.app/Contents/Resources/scripts/voice_runtime.sh health
bash /Applications/VoitranMac.app/Contents/Resources/scripts/voitran_services.sh status-all
open -a /Applications/VoitranMac.app
osascript -e 'tell application "VoitranMac" to quit'
```
