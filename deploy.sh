#!/usr/bin/env bash
set -euo pipefail

# Wrapper para o script de deploy principal
# Este arquivo fica na raiz para ser acessível via Docker exec

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Se o script principal existir, execute-o
if [[ -f "$SCRIPT_DIR/scripts/deploy.sh" ]]; then
  exec "$SCRIPT_DIR/scripts/deploy.sh" "$@"
else
  echo "❌ Script scripts/deploy.sh não encontrado"
  exit 1
fi
