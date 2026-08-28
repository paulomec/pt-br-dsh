#!/usr/bin/env bash
# uninstall.sh — Reverte as traduções pt-BR aplicadas ao DSH
# Uso: bash scripts/uninstall.sh [caminho-para-dsh] [flags]
#   Sem caminho: procura sibling ../deepseek-harness
# Flags:
#   --branch <branch>   ramo do GitHub para baixar o patch (default: main)
#   --patch <file>      usa este patch local em vez de baixar
#   --dry-run           lista o que faria sem alterar nada
#   --force / -y        pula a confirmação
#   --purge            remove órfão pt.ts (default: não remove)
#   --no-rebuild        não executa pnpm run build

set -euo pipefail

DSH_PATH=""
BRANCH="main"
PATCH_PATH=""
WHATIF=0
FORCE=0
NOREBUILD=0
PURGE=0

# parse args (primeiro positional = DSH path)
while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch) BRANCH="$2"; shift 2;;
    --patch)  PATCH_PATH="$2"; shift 2;;
    --dry-run|--what-if) WHATIF=1; shift;;
    --purge) PURGE=1; shift;;
    --force|-y) FORCE=1; shift;;
    --no-rebuild) NOREBUILD=1; shift;;
    --*) echo "Flag desconhecida: $1" >&2; exit 2;;
    *)
      if [[ -z "$DSH_PATH" ]]; then DSH_PATH="$1"; shift
      else echo "Argumento inesperado: $1" >&2; exit 2; fi
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_DIR="$(dirname "$SCRIPT_DIR")"
GITHUB_REPO="https://raw.githubusercontent.com/paulomec/pt-br-dsh"

# 1) Resolve o patch: local primeiro, senão baixa do GitHub
if [[ -z "$PATCH_PATH" ]]; then
  LOCAL_PATCH="$PROJ_DIR/pt-br.patch"
  if [[ -f "$LOCAL_PATCH" ]]; then
    PATCH_PATH="$LOCAL_PATCH"
  else
    PATCH_PATH="/tmp/pt-br-dsh-uninstall.patch"
    echo "[*] Baixando patch do GitHub (branch=$BRANCH)..."
    curl -fsSL "$GITHUB_REPO/$BRANCH/pt-br.patch" -o "$PATCH_PATH"
  fi
fi
if [[ ! -f "$PATCH_PATH" ]]; then
  echo "ERRO: patch não encontrado em $PATCH_PATH" >&2
  exit 1
fi

# 2) Resolve o diretório do DSH
if [[ -z "$DSH_PATH" ]]; then
  SIBLING="$(dirname "$PROJ_DIR")/deepseek-harness"
  if [[ -d "$SIBLING" ]]; then DSH_PATH="$SIBLING"
  else echo "ERRO: especifique o caminho do DSH como argumento" >&2; exit 1; fi
fi
if [[ ! -d "$DSH_PATH/.git" ]]; then
  echo "ERRO: $DSH_PATH não parece ser um repo git do DSH" >&2
  exit 1
fi

# 3) Extrai a lista de caminhos que o patch toca (lado a/)
mapfile -t PATCH_PATHS < <(grep '^diff --git a/' "$PATCH_PATH" | sed -E 's#^diff --git a/(.+) b/.+#\1#')
if [[ ${#PATCH_PATHS[@]} -eq 0 ]]; then
  echo "ERRO: não foi possível extrair caminhos do patch" >&2
  exit 1
fi

echo "╔══════════════════════════════════════════════╗"
echo "║  pt-br-dsh: desinstalando / revertendo       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "DSH target : $DSH_PATH"
echo "Patch      : $PATCH_PATH"
echo "Arquivos   : ${#PATCH_PATHS[@]} (cirúrgico — não toca em outros)"

# 4) Detecta se o patch está aplicado e se há órfão pt.ts
PT_REL="packages/client/locale/src/locales/pt.ts"
ORPHAN_PT=0
if [[ -e "$DSH_PATH/$PT_REL" ]]; then
  if ! git -C "$DSH_PATH" ls-files --error-unmatch "$PT_REL" >/dev/null 2>&1; then
    ORPHAN_PT=1   # não rastreado → órfão
  fi
fi

APPLIED=0
if git -C "$DSH_PATH" apply --reverse --check "$PATCH_PATH" >/dev/null 2>&1; then
  APPLIED=1
fi

# 5) --dry-run: apenas lista
if [[ "$WHATIF" -eq 1 ]]; then
  echo ""
  echo "[WhatIf] O que seria feito:"
  if [[ "$APPLIED" -eq 1 ]]; then
    echo "  - git apply --reverse  (reverte ${#PATCH_PATHS[@]} arquivos rastreados)"
  else
    echo "  - (patch já revertido — nada a reverter)"
  fi
  if [[ "$ORPHAN_PT" -eq 1 ]]; then
    if [[ "$PURGE" -eq 1 ]]; then echo "  - rm -f $PT_REL  (órfão, --purge)"
    else echo "  - pt.ts órfão mantido (use --purge para remover)"
    fi
  else
    echo "  - pt.ts órfão mantido por padrão (use --purge para remover)"
  fi
  if [[ "$NOREBUILD" -eq 0 ]]; then
    echo "  - pnpm run build   (regenera lib/)"
  else
    echo "  - build pulado (--no-rebuild)"
  fi
  exit 0
fi

# 6) Nada a fazer?
if [[ "$APPLIED" -eq 0 && "$ORPHAN_PT" -eq 0 ]]; then
  echo ""
  echo "Nada a desinstalar: patch já revertido e não há órfão pt.ts."
  exit 0
fi

# 7) Confirmação (a menos --force)
if [[ "$FORCE" -eq 0 ]]; then
  echo ""
  echo "Isso reverterá as traduções pt-BR do DSH em '$DSH_PATH'."
  echo "Arquivos externos ao patch (ex.: node_modules, pnpm-lock.yaml, cordis.yml) NÃO são tocados."
  read -r -p "Confirmar desinstalação? (s/n) " confirm
  case "$confirm" in
    [sS]|[sS][iI][mM]|[yY]|[yY][eE][sS]) :;;
    *) echo "Cancelado."; exit 0;;
  esac
fi

# 8) Passo 1 — reverter o patch
echo ""
echo "[1/3] Revertendo patch..."
if [[ "$APPLIED" -eq 1 ]]; then
  if ! git -C "$DSH_PATH" apply --reverse "$PATCH_PATH"; then
    echo "  git apply --reverse falhou (árvore modificada após aplicação). Usando fallback..." >&2
    if ! git -C "$DSH_PATH" checkout HEAD -- "${PATCH_PATHS[@]}"; then
      echo "FALHA: não foi possível reverter os arquivos do patch" >&2
      exit 1
    fi
  fi
  echo "  ${#PATCH_PATHS[@]} arquivos revertidos para o estado original do DSH."
  else
    echo "  Patch já revertido — nada a reverter."
  fi

# 9) Passo 2 — verificar órfão pt.ts (remove só com --purge)
echo ""
echo "[2/3] Verificando órfão pt.ts..."
if [[ "$ORPHAN_PT" -eq 1 ]]; then
  if [[ "$PURGE" -eq 1 ]]; then
    rm -f "$DSH_PATH/$PT_REL"
    echo "  Removido órfão não rastreado: $PT_REL (--purge)"
  else
    echo "  pt.ts órfão mantido (não gerenciado pelo patch). Use --purge para remover."
  fi
else
  echo "  Sem órfão pt.ts para remover (não existe ou é rastreado — mantido)."
fi

# 10) Passo 3 — rebuild opcional
echo ""
echo "[3/3] Build..."
if [[ "$NOREBUILD" -eq 1 ]]; then
  echo "  Pulado (--no-rebuild). Para regenerar lib/: cd $DSH_PATH && pnpm run build"
else
  echo "  Executando pnpm run build (pode levar alguns minutos)..."
  if pnpm --dir "$DSH_PATH" run build; then
    echo "  Build concluído — lib/ regenerada sem pt-BR."
  else
    echo "  AVISO: build retornou não-zero, mas a fonte já foi revertida." >&2
  fi
fi

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  Desinstalação concluída!                    ║"
echo "║                                              ║"
echo "║  Em Configurações > Geral > Idioma,          ║"
echo "║  volte para English.                         ║"
echo "╚══════════════════════════════════════════════╝"
