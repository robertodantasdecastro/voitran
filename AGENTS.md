# Instrucoes do Projeto (Voitran)

Este repositorio usa o padrao de memoria, governanca e continuidade estrutural inspirado no projeto `MrQuentinha`.

## Objetivo
Preparar e evoluir um produto de chamadas com traducao de voz em tempo real, sintese de voz e governanca de identidade vocal, com operacao `local-first` e compatibilidade com `Antigravity IDE`.

## Regras inegociaveis
1. Toda mudanca estrutural ou operacional relevante deve atualizar memoria viva.
2. O workflow de entrada deste projeto e `WF_NovoProjeto`.
3. O estado oficial do projeto vive em `docs/memory/` e `.agent/memory/`.
4. Toda documentacao operacional e memoria deste projeto devem ficar em portugues.
5. Nenhum segredo, token, chave privada, audio sensivel ou amostra real de voz pode ser versionado.
6. O runtime pesado do produto deve ficar fora do workspace versionado.
7. Toda nova capacidade deve declarar owner de camada, criterio de aceite e impacto de latencia.
8. Toda funcionalidade de identidade vocal exige consentimento explicito e rastreavel.
9. Sempre preferir automacao por script a passos manuais repetitivos.
10. O backend de controle prioriza velocidade operacional, baixa latencia e concorrencia previsivel.

## Base obrigatoria antes de qualquer ciclo
- `AGENTS.md`
- `docs/07-workflow-codex.md`
- `docs/memory/PROJECT_STATE.md`
- `docs/memory/DECISIONS.md`
- `docs/memory/CHANGELOG.md`
- `docs/memory/RUNBOOK_DEV.md`
- `.agent/memory/CONTEXT_PACK.md`

## Definition of Done
Uma tarefa so fecha quando:
- o comportamento foi validado;
- a memoria afetada foi atualizada;
- `bash scripts/sync_memory.sh --check` foi executado;
- os agentes afetados foram sincronizados no board;
- novos riscos, decisoes ou proximos passos foram registrados.

## Topologia oficial de agentes
- `Mac` -> shell do produto, inferencia local, testes e benchmark.
- `Backend` -> controle de sessao, presenca, tokens, eventos e observabilidade.
- `AntigravityIDE` -> continuidade estrutural, revisao paralela e sincronizacao de contexto.

## Arquivos de referencia
- `ARCHITECTURE.md`
- `livememory.md`
- `project_evolution.md`
- `roadmap.md`
- `AUDIT_REPORT.md`
- `docs/07-workflow-codex.md`
- `docs/memory/PROJECT_STATE.md`
- `docs/memory/AGENT_REGISTRY.md`
- `.agent/workflows/WF_NovoProjeto.md`
