#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_files=(
  "AGENTS.md"
  "ARCHITECTURE.md"
  "livememory.md"
  "project_evolution.md"
  "roadmap.md"
  "AUDIT_REPORT.md"
  "docs/07-workflow-codex.md"
  "docs/memory/PROJECT_STATE.md"
  "docs/memory/DECISIONS.md"
  "docs/memory/CHANGELOG.md"
  "docs/memory/RUNBOOK_DEV.md"
  ".agent/memory/CONTEXT_PACK.md"
  ".agent/memory/MEMORY_INDEX.md"
  ".agent/rules/global.md"
  ".agent/rules/security.md"
  ".agent/workflows/WF_NovoProjeto.md"
  ".antigravity/GLOBAL_RULE.md"
  ".antigravity/GLOBAL_SYNC_RULE.md"
)

check_required() {
  local missing=0
  for path in "${required_files[@]}"; do
    if [[ ! -f "${ROOT_DIR}/${path}" ]]; then
      echo "[sync_memory] ausente: ${path}" >&2
      missing=1
    fi
  done
  return "${missing}"
}

case "${1:-}" in
  --check)
    if check_required; then
      echo "[sync_memory] check ok"
    else
      exit 1
    fi
    ;;
  *)
    echo "uso: bash scripts/sync_memory.sh --check" >&2
    exit 1
    ;;
esac
