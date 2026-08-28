#!/usr/bin/env bash
# install.sh — Instala pt-BR no DSH clonando do GitHub
# Uso: bash scripts/install.sh [caminho-para-dsh]

set -euo pipefail

GITHUB_REPO="https://github.com/paulomec/pt-br-dsh.git"
WORK_DIR="/tmp/pt-br-dsh-install"
PATCH_PATH="$WORK_DIR/pt-br.patch"
BRANCH="${BRANCH:-main}"

echo "╔══════════════════════════════════════════════╗"
echo "║  pt-br-dsh: instalação pelo GitHub          ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Step 0: Clone from GitHub
echo "[1/4] Baixando do GitHub..."
rm -rf "$WORK_DIR"
git clone --depth 1 --branch "$BRANCH" "$GITHUB_REPO" "$WORK_DIR"
if [[ ! -f "$PATCH_PATH" ]]; then
  echo "ERRO: patch não encontrado em $PATCH_PATH" >&2
  exit 1
fi
echo "  Patch baixado."

# Step 1: Resolve DSH path
DSH_PATH="${1:-}"
if [[ -z "$DSH_PATH" ]]; then
  SIBLING="$(dirname "$PWD")/deepseek-harness"
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

# Step 2: Apply patch
echo ""
echo "[2/4] Aplicando patch..."
git -C "$DSH_PATH" apply "$PATCH_PATH"
echo "  Patch aplicado."

# Step 3: Install deps
echo ""
echo "[3/4] Instalando dependências..."
pnpm --dir "$DSH_PATH" install
echo "  Dependências instaladas."

# Step 4: Build
echo ""
echo "[4/4] Fazendo build..."
pnpm --dir "$DSH_PATH" run build

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  Instalação concluída!                       ║"
echo "║                                              ║"
echo "║  Para rodar: cd $DSH_PATH                    ║"
echo "║  pnpm dsh web                                 ║"
echo "║                                              ║"
echo "║  Selecione Português (BR) em:                ║"
echo "║  Configurações > Geral > Idioma              ║"
echo "╚══════════════════════════════════════════════╝"