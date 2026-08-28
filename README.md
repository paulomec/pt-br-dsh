# pt-br-dsh — pt-BR (Português Brasileiro) para o DSH

Traduz o frontend do [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) para Português Brasileiro.

Suporta **todas as 24 namespaces** da UI (conversation, workspace, subagent, settings-models, settings-plugins, etc.) — dicionários completos, não fallbacks.

## Instalação rápida (via GitHub — sem precisar clonar este repositório)

**Windows (PowerShell):**
```powershell
Invoke-WebRequest https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/pt-br.patch -OutFile pt-br.patch
cd C:/caminhoh/para/deepseek-harness
git apply ../pt-br.patch
pnpm install
pnpm run build
```

**Linux / macOS:**
```bash
curl -LO https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/pt-br.patch
cd /caminho/para/deepseek-harness
git apply ../pt-br.patch
pnpm install
pnpm run build
```

Depois: `pnpm dsh web` → Configurações → Geral → Idioma → **Português (BR)**.

## Instalação automática (script tudo-em-um)

**Windows:**
```powershell
powershell -Command "iwr -useb https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/scripts/install.ps1 | iex" -ArgumentList "C:/caminhoh/para/deepseek-harness"
```

**Linux / macOS:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/scripts/install.sh) /caminho/para/deepseek-harness
```

## Instalação local (clone + patch + build)

```bash
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
git apply ../pt-br-dsh/pt-br.patch
pnpm install
pnpm run build
pnpm dsh web
```

Ou via script:

```powershell
# Windows
./scripts/apply-and-build.ps1 -DshPath "C:/Users/seuusuario/deepseek-harness"
```

```bash
# Linux/macOS
bash scripts/apply-and-build.sh /caminho/para/deepseek-harness
```

## Desinstalação (modo undo)

Remove **todas** as alterações que o pt-br-dsh aplica ao DSH, de forma **cirúrgica** — só os arquivos que o `pt-br.patch` toca. **Nada fora disso é modificado**: o `pnpm-lock.yaml`, `node_modules`, `cordis.yml` e demais arquivos do DSH ficam intocados.

O que o comando faz, em ordem:
1. Reverte o patch no repositório do DSH (`git apply --reverse`). Se a árvore já foi editada após a aplicação e o reversão falhar, usa como fallback `git checkout HEAD -- <arquivos-do-patch>`, em seguida verifica (fail-safe) que a reversão realmente completou.
2. `pt.ts` é um órfão (não rastreado pelo git e **não** criado pelo patch) que fica no disco após a instalação. **Não é removido por padrão** — use `-Purge` (ps1) ou `--purge` (sh) para deletar; se estiver versionado, avisa e mantém.
3. Opcionalmente faz `pnpm run build` para regenerar `lib/` sem pt-BR (necessário se roda instância já construída; no modo dev/HMR basta reiniciar).

### Comandos

```powershell
# De onde estiver (baixa o patch do GitHub, igual install.ps1)
powershell -ExecutionPolicy Bypass -File scripts/uninstall.ps1 -DshPath "C:/caminho/para/deepseek-harness" -Force
# -WhatIf    : mostra o que faria sem alterar nada
# -NoRebuild : pula o build
# -Purge     : remove órfão pt.ts (default: mantém)
# -Branch main : ramo do GitHub para baixar o patch (default: main)
```

```bash
# Linux / macOS
bash scripts/uninstall.sh /caminho/para/deepseek-harness --force
# --dry-run    : mostra o que faria sem alterar nada
# --no-rebuild : pula o build
# --purge      : remove órfão pt.ts (default: mantém)
# --branch main : ramo do GitHub para baixar o patch (default: main)
```

```powershell
# Via GitHub (sem clonar este repo) — Windows
powershell -Command "iwr -useb https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/scripts/uninstall.ps1 | iex" -DshPath "C:/caminho/para/deepseek-harness"
```

```bash
# Via GitHub (sem clonar este repo) — Linux/macOS
bash <(curl -sL https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/scripts/uninstall.sh) /caminho/para/deepseek-harness
```

### Segurança

- Sempre resolve o caminho do DSH e valida que é um repo git.
- Usa `git apply --reverse --check` antes de reverter; se o patch já estiver revertido, é um **no-op** (não erro).
- `pt.ts` só é apagado se for órfão (não rastreado) **e** com `-Purge` (ps1) / `--purge` (sh); arquivos versionados nunca são deletados.
- O reverse verifica (fail-safe) que a reversão completou antes de seguir; se falhar, aborta e indica o comando manual.
- O build é revertido para que o DSH volte ao seu estado original.

**Nota:** todos os scripts e URLs deste README usam o ramo `main` (branch padrão deste repo). Use `-Branch`/`--branch` para outro ramo. Rodando dentro da pasta `pt-br-dsh`, o script detecta o `pt-br.patch` local automaticamente (sem precisar baixar do GitHub).

Depois: em `Configurações → Geral → Idioma`, volte para `English`.

## O que o patch altera

- `packages/client/locale/` — adiciona `pt` ao `LOCALE_IDS`, dicionário `common` (`pt.ts`), lista de idiomas, `<html lang="pt-BR">`.
- `packages/client/ui-*` — 24 pacotes com dicionários pt-BR completos.
- Arquivos `lib/` são gerados pelo `pnpm run build`.

## Requisitos

- Node.js 22+ e pnpm
- Patch gerado contra `main` do DSH

## Estrutura

```
pt-br-dsh/
├── README.md
├── pt-br.patch
└── scripts/
    ├── apply-and-build.ps1      # patch + build (Windows)
    ├── apply-and-build.sh       # patch + build (Linux/macOS)
    ├── install.ps1              # instalação via GitHub (Windows)
    ├── install.sh               # instalação via GitHub (Linux/macOS)
    ├── uninstall.ps1            # desinstalação/undo (Windows)
    └── uninstall.sh             # desinstalação/undo (Linux/macOS)
```

## Desenvolvimento

Para editar traduções: edite os `locales.ts` nos pacotes e o `locale/src/locales/pt.ts`, depois:

```bash
cd packages/client/ui-conversation && pnpm exec tsdown   # pacote específico
# ou
pnpm run build                                            # rebuild geral
```
