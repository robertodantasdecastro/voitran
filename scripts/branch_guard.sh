#!/usr/bin/env bash
set -euo pipefail

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
echo "[branch_guard] branch atual: ${branch}"
