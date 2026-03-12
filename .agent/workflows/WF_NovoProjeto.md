---
id: WF-NovoProjeto
title: Bootstrap global do projeto
description: Workflow inicial para aplicar memoria viva, compatibilidade Antigravity e topologia oficial desde o primeiro ciclo.
outputs:
  - contexto_base_lido
  - memoria_base_validada
  - topologia_de_agentes_confirmada
---

# WF_NovoProjeto

## Objetivo
Entrar em qualquer ciclo usando a mesma base estrutural do projeto.

## Passos obrigatorios
1. Ler `AGENTS.md`.
2. Ler `docs/07-workflow-codex.md`.
3. Ler `docs/memory/PROJECT_STATE.md`.
4. Ler `docs/memory/DECISIONS.md`.
5. Ler `docs/memory/CHANGELOG.md`.
6. Ler `.agent/memory/CONTEXT_PACK.md`.
7. Executar `bash scripts/sync_memory.sh --check`.
8. Executar `bash scripts/preflight.sh`.
9. Se houver trabalho paralelo, revisar `W26` e `W27`.
10. Se entrar agente novo, executar `W28`.

## Saida esperada
- contexto unico carregado;
- regra de memoria ativa;
- topologia de agentes conhecida;
- compatibilidade com `Antigravity IDE` pronta.
