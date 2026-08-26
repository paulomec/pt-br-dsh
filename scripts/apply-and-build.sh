#!/usr/bin/env bash
# apply-and-build.sh — Aplica o patch pt-BR e faz build do DSH
# Uso: bash scripts/apply-and-build.sh [caminho-para-dsh]
# Se omitido, procura em ../deepseek-harness

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_DIR="$(dirname "$SCRIPT_DIR")"
PATCH_FILE="$PROJ_DIR/pt-br.patch"

if [[ ! -f "$PATCH_FILE" ]]; then
  echo "ERRO: pt-br.patch não encontrado em $PATCH_FILE" >&2
  exit 1
fi

# Resolve DSH path
DSH_PATH="${1:-}"
if [[ -z "$DSH_PATH" ]]; then
  SIBLING="$(dirname "$PROJ_DIR")/deepseek-harness"
  if [[ -d "$SIBLING" ]]; then
    DSH_PATH="$SIBLING"
  else
    echo "ERRO: especifique o caminho do DSH como argumento" >&2
    exit 1
  fi
fi

if [[ ! -d "$DSH_PATH" ]]; then
  echo "ERRO: diretório DSH não encontrado em $DSH_PATH" >&2
  exit 1
fi

echo "╔══════════════════════════════════════════════╗"
echo "║  pt-br-dsh: aplicando e buildando           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Step 1: Apply patch
echo "[1/3] Aplicando patch pt-BR..."
git -C "$DSH_PATH" apply "$PATCH_FILE"
echo "  Patch aplicado com sucesso."

# Step 2: Install deps
echo ""
echo "[2/3] Instalando dependências..."
pnpm --dir "$DSH_PATH" install
echo "  Dependências instaladas."

# Step 3: Build
echo ""
echo "[3/3] Fazendo build..."
pnpm --dir "$DSH_PATH" run build

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  Build concluído com sucesso!                ║"
echo "║                                              ║"
echo "║  Para rodar: cd $DSH_PATH                    ║"
echo "║  pnpm dsh web                                 ║"
echo "║                                              ║"
echo "║  Depois selecione Português (BR) em          ║"
echo "║  Configurações > Geral > Idioma              ║"
echo "╚══════════════════════════════════════════════╝"