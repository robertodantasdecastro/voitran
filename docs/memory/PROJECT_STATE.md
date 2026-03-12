# Project State - Voitran

## Objetivo atual
Criar e evoluir um produto `local-first` de chamada com traducao de voz em tempo real, sintese local e governanca de identidade vocal.

## Root oficial
- `/Volumes/SSDExterno/Desenvolvimento/iatools/voitran`

## Git oficial
- repositorio local dedicado na raiz do projeto;
- branch default: `main`;
- remote esperado: `git@github.com:robertodantasdecastro/voitran.git`.

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
- modelos e caches fora do repo.
