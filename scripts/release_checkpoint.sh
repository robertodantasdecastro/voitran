#!/usr/bin/env bash
set -euo pipefail

bash scripts/sync_memory.sh --check
git status --short
