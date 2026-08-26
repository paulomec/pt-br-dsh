# pt-br-dsh â€” pt-BR (PortuguÃªs Brasileiro) para o DSH

Traduz o frontend do [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) para PortuguÃªs Brasileiro.

Suporta **todas as 24 namespaces** da UI (conversation, workspace, subagent, settings-models, settings-plugins, etc.) â€” dicionÃ¡rios completos, nÃ£o fallbacks.

## InstalaÃ§Ã£o rÃ¡pida (via GitHub â€” sem precisar clonar este repositÃ³rio)

**Windows (PowerShell):**
```powershell
Invoke-WebRequest https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/pt-br.patch -OutFile pt-br.patch
cd C:\caminhoh\para\deepseek-harness
git apply ..\pt-br.patch
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

Depois: `pnpm dsh web` â†’ ConfiguraÃ§Ãµes â†’ Geral â†’ Idioma â†’ **PortuguÃªs (BR)**.

## InstalaÃ§Ã£o automÃ¡tica (script tudo-em-um)

**Windows:**
```powershell
powershell -Command "iwr -useb https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/scripts/install.ps1 | iex" -ArgumentList "C:\caminhoh\para\deepseek-harness"
```

**Linux / macOS:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/scripts/install.sh) /caminho/para/deepseek-harness
```

## InstalaÃ§Ã£o local (clone + patch + build)

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
.\scripts\apply-and-build.ps1 -DshPath "C:\Users\seuusuario\deepseek-harness"
```

```bash
# Linux/macOS
bash scripts/apply-and-build.sh /caminho/para/deepseek-harness
```

## O que o patch altera

- `packages/client/locale/` â€” adiciona `pt` ao `LOCALE_IDS`, dicionÃ¡rio `common` (`pt.ts`), lista de idiomas, `<html lang="pt-BR">`.
- `packages/client/ui-*` â€” 24 pacotes com dicionÃ¡rios pt-BR completos.
- Arquivos `lib/` sÃ£o gerados pelo `pnpm run build`.

## Requisitos

- Node.js 22+ e pnpm
- Patch gerado contra `main` do DSH

## Estrutura

```
pt-br-dsh/
â”œâ”€â”€ README.md
â”œâ”€â”€ pt-br.patch
â””â”€â”€ scripts/
    â”œâ”€â”€ apply-and-build.ps1      # patch + build (Windows)
    â”œâ”€â”€ apply-and-build.sh       # patch + build (Linux/macOS)
    â”œâ”€â”€ install.ps1              # instalaÃ§Ã£o via GitHub (Windows)
    â””â”€â”€ install.sh               # instalaÃ§Ã£o via GitHub (Linux/macOS)
```

## Desenvolvimento

Para editar traduÃ§Ãµes: edite os `locales.ts` nos pacotes e o `locale/src/locales/pt.ts`, depois:

```bash
cd packages/client/ui-conversation && pnpm exec tsdown   # pacote especÃ­fico
# ou
pnpm run build                                            # rebuild geral
```
