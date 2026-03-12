# Workflow do Codex - Voitran

## Base obrigatoria de contexto
Antes de qualquer tarefa:
- `AGENTS.md`
- `docs/memory/PROJECT_STATE.md`
- `docs/memory/DECISIONS.md`
- `docs/memory/CHANGELOG.md`
- `docs/memory/RUNBOOK_DEV.md`
- `.agent/memory/CONTEXT_PACK.md`

## Workflow de entrada
O bootstrap oficial deste repositorio e:
- `.agent/workflows/WF_NovoProjeto.md`

Fluxo recomendado:
1. `WF_NovoProjeto`
2. `W10_iniciar_sessao`
3. `W11_continuar_sessao`
4. `W26_gestao_triagente_voitran`
5. `W27_sync_mac_backend_antigravity`
6. `W17_atualizar_documentacao_memoria`
7. `W21_sync_codex_antigravity`
8. `W12_salvar_checkpoint`

## Topologia operacional
- `Mac`: workspace local, inferencia, benchmark e shell do produto.
- `Backend`: controle de sessao, token, presenca, eventos e observabilidade.
- `AntigravityIDE`: sincronizacao de contexto e continuidade estrutural.

## Comandos base
No root do projeto:

```bash
bash scripts/preflight.sh
bash scripts/sync_memory.sh --check
bash scripts/session.sh start
bash scripts/session.sh continue
bash scripts/session.sh save
bash scripts/session.sh sync
bash scripts/session.sh triad
```

## Regras globais de sincronizacao
- toda mudanca em `scripts/`, `backend/`, `apps/`, `packages/`, `.agent/`, `.antigravity/` ou `docs/memory/` exige revisao da memoria viva;
- todo agente novo entra pelo `W28_onboard_novo_agente`;
- toda divergencia entre `Mac`, `Backend` e `AntigravityIDE` deve entrar no `AGENT_SYNC_BOARD`.
