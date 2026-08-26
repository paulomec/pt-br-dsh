# pt-br-dsh — pt-BR (Português Brasileiro) para o DSH

Traduz o frontend do [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) para Português Brasileiro.

Suporta **todas as 24 namespaces** da UI (conversation, workspace, subagent, settings-models, settings-plugins, etc.) — dicionários completos, não fallbacks.

## Instalação rápida (via GitHub — sem precisar clonar este repositório)

**Windows (PowerShell):**
```powershell
Invoke-WebRequest https://raw.githubusercontent.com/paulomec/pt-br-dsh/master/pt-br.patch -OutFile pt-br.patch
cd C:\caminhoh\para\deepseek-harness
git apply ..\pt-br.patch
pnpm install
pnpm run build
```

**Linux / macOS:**
```bash
curl -LO https://raw.githubusercontent.com/paulomec/pt-br-dsh/master/pt-br.patch
cd /caminho/para/deepseek-harness
git apply ../pt-br.patch
pnpm install
pnpm run build
```

Depois: `pnpm dsh web` → Configurações → Geral → Idioma → **Português (BR)**.

## Instalação automática (script tudo-em-um)

**Windows:**
```powershell
powershell -Command "iwr -useb https://raw.githubusercontent.com/paulomec/pt-br-dsh/master/scripts/install.ps1 | iex" -ArgumentList "C:\caminhoh\para\deepseek-harness"
```

**Linux / macOS:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/paulomec/pt-br-dsh/master/scripts/install.sh) /caminho/para/deepseek-harness
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
.\scripts\apply-and-build.ps1 -DshPath "C:\Users\seuusuario\deepseek-harness"
```

```bash
# Linux/macOS
bash scripts/apply-and-build.sh /caminho/para/deepseek-harness
```

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
    └── install.sh               # instalação via GitHub (Linux/macOS)
```

## Desenvolvimento

Para editar traduções: edite os `locales.ts` nos pacotes e o `locale/src/locales/pt.ts`, depois:

```bash
cd packages/client/ui-conversation && pnpm exec tsdown   # pacote específico
# ou
pnpm run build                                            # rebuild geral
```