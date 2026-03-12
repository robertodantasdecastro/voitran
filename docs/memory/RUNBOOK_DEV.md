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
bash scripts/voice_lab.sh ingest
bash scripts/voice_lab.sh eval
```
