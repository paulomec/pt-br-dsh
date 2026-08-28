# pt-br-dsh 🇧🇷

<p align="center">
  <strong>Tradução completa do DeepSeek Harness para Português Brasileiro</strong><br>
  <em>Dicionários completos — sem fallbacks, sem strings quebradas</em>
</p>

<p align="center">
  <a href="https://github.com/paulomec/pt-br-dsh"><img src="https://img.shields.io/github/stars/paulomec/pt-br-dsh?style=flat&label=stars" alt="GitHub stars"></a>
  <a href="https://github.com/paulomec/pt-br-dsh/commits/main"><img src="https://img.shields.io/github/last-commit/paulomec/pt-br-dsh" alt="last commit"></a>
  <img src="https://img.shields.io/badge/node-%3E%3D22-brightgreen" alt="Node 22+">
  <img src="https://img.shields.io/badge/pnpm-required-F69220" alt="pnpm">
  <img src="https://img.shields.io/badge/namespaces-24-blueviolet" alt="24 namespaces">
  <img src="https://img.shields.io/badge/i18n-pt--BR-009739" alt="pt-BR">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="MIT"></a>
</p>

<p align="center">
  <a href="https://github.com/deepseek-ai/deepseek-harness">DeepSeek Harness</a> • <a href="#-instalação">Instalação</a> • <a href="#-cobertura">Cobertura</a> • <a href="#-desenvolvimento">Desenvolvimento</a>
</p>

> **EN Summary:** Complete Brazilian Portuguese translation for [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) — full dictionaries for all 24 UI namespaces, type-checked against the `zh` source of truth. Apply via `git apply pt-br.patch` + `pnpm run build`.

---

## Índice

- [Sobre](#sobre)
- [Destaques](#-destaques)
- [Cobertura](#-cobertura)
- [Compatibilidade](#compatibilidade)
- [Instalação](#instalação)
- [Uso](#uso)
- [Desinstalação](#desinstalação)
- [O que o patch altera](#o-que-o-patch-altera)
- [Estrutura](#estrutura)
- [Desenvolvimento](#desenvolvimento)
- [FAQ / Solução de problemas](#faq--solução-de-problemas)
- [Contribuindo](#contribuindo)
- [Nota sobre IA](#nota-sobre-ia)
- [Licença](#licença)

## Sobre

O **pt-br-dsh** traduz o frontend do [DeepSeek Harness (DSH)](https://github.com/deepseek-ai/deepseek-harness) para **Português Brasileiro (pt-BR)** via patch Git.

Diferente de traduções parciais, este projeto entrega **dicionários completos** para cada namespace da UI — cada chave `pt` é verificada em tempo de compilação contra o `zh` (fonte da verdade do DSH). Sem `en` como fallback, sem chaves faltando.

> **Preview:** após a instalação, vá em `Configurações → Geral → Idioma → Português (BR)` e toda a interface — conversas, workspace, subagentes, modelos, plugins — passa a pt-BR.

## ✨ Destaques

- 🌐 **Cobertura total** — 24 pacotes de UI traduzidos, incluindo `common` e `settings`
- ✅ **Type-safe** — `satisfies Record<ZhKey, string>` garante que nenhuma chave falte ou sobre
- 🧩 **Patch cirúrgico** — só toca `packages/client/**`; `pnpm-lock.yaml`, `node_modules` e `cordis.yml` ficam intactos
- 🔄 **Undo seguro** — `scripts/uninstall.{ps1,sh}` com `--dry-run`/`-WhatIf` e verificação fail-safe
- ⚡ **Instalação em 1 linha** — via GitHub sem clonar este repo, ou local com build automático

## 📖 Cobertura

24 pacotes com dicionários `pt` completos:

| Pacote | Namespace(s) | Descrição |
|---|---|---|
| `locale` | `common`, `settings.locale` | Núcleo i18n + seletor de idioma (`<html lang="pt-BR">`) |
| `ui-conversation` | `conversation` | Chat, fila, aprovação, terminal, compactação |
| `ui-workspace` | `workspace` | Espaços de trabalho |
| `ui-subagent` | `subagent` | Subagentes |
| `ui-agent-preset` | `settings.agentPreset` | Presets de agente |
| `ui-model-selection` | `model` | Seleção de modelo e esforço |
| `ui-permission-presets` | `settings.permission` + gate `Full access` | Permissões |
| `ui-settings-general` | `settings.general` | Configurações gerais |
| `ui-settings-models` | `settings.models` | Modelos |
| `ui-settings-plugins` | `settings.plugins` | Plugins |
| `ui-settings-plugin-inventory` | `settings.pluginInventory` | Inventário |
| `ui-commands` | `commands` | Comandos `/` |
| `ui-input-trigger` | `inputTrigger` | Menu `@`/`/`/`!` |
| `ui-reference` | `reference` | Menções `@arquivo` e `@sessão` |
| `ui-plan` | `plan` | Modo plano |
| `ui-goal` | `goal` | Objetivos |
| `ui-deliverables` | `deliverables` | Arquivos gerados |
| `ui-jobs` | `job` | Tarefas em segundo plano |
| `ui-message-feedback` | `messageFeedback` | Avaliação de mensagens |
| `ui-directory-picker-browse` | `directoryPicker` | Seletor de diretório |
| `ui-sidebar` | `sidebar` | Barra lateral |
| `ui-skill` | `skill` | Skills |
| `ui-theme` | `theme` | Tema |
| `ui-trajectory` | `trajectory` | Trajetória |
| `ui-user-questions` | `userQuestions` | Perguntas do usuário |
| `ui-workflow-run` | `workflowRun` | Execuções de workflow |

> Todos os `pt.ts`/`locales.ts` são `Record<ZhKey, string>` — se o DSH adicionar uma chave em `zh`, o build quebra até a tradução ser adicionada.

## 🔧 Compatibilidade

| Dependência | Versão |
|---|---|
| **DeepSeek Harness** | `main` (patch gerado em 2026-08-28) — reaplique após `git pull` se houver conflitos |
| **Node.js** | `>= 22` |
| **pnpm** | `>= 9` (gerenciador oficial do DSH) |
| **Git** | `>= 2.30` (`git apply`) |

> [!NOTE]
> O patch é regenerado contra o `main` do DSH. Se `git apply` falhar após atualizar o DSH, faça um fork e regenere o patch localmente a partir do commit do DSH que você utiliza.

## 🚀 Instalação

> Todos os comandos abaixo assumem branch `main` deste repo. Use `--branch`/`-Branch` para outro ramo.

### Opção 1 — Recomendado: 1-liner via GitHub (sem clonar)

**Windows (PowerShell):**

```powershell
powershell -Command "iwr -useb https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/scripts/install.ps1 | iex" -ArgumentList "C:/caminho/para/deepseek-harness"
```

**Linux / macOS:**

```bash
bash <(curl -sL https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/scripts/install.sh) /caminho/para/deepseek-harness
```

O script clona este repo em `/tmp`, aplica o patch, roda `pnpm install` e `pnpm run build`.

### Opção 2 — Manual (sem script)

**Windows (PowerShell):**

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/pt-br.patch -OutFile pt-br.patch
cd C:/caminho/para/deepseek-harness
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

### Opção 3 — Local (clone deste repo + patch + build)

```bash
git clone https://github.com/deepseek-ai/deepseek-harness.git
git clone https://github.com/paulomec/pt-br-dsh.git
cd deepseek-harness
git apply ../pt-br-dsh/pt-br.patch
pnpm install
pnpm run build
```

Ou via wrappers deste repo:

```powershell
# Windows
./scripts/apply-and-build.ps1 -DshPath "C:/caminho/para/deepseek-harness"
```
```bash
# Linux / macOS
bash scripts/apply-and-build.sh /caminho/para/deepseek-harness
```

## ▶️ Uso

Após o build:

```bash
pnpm dsh web
```

Abra o DSH → **Configurações → Geral → Idioma → Português (BR)**.

No modo dev com HMR, basta recarregar a página após trocar o idioma.

## 🗑️ Desinstalação

<details>
<summary><strong>Reverter o patch de forma cirúrgica (clique para expandir)</strong></summary>

Remove **apenas** os arquivos que o `pt-br.patch` toca. `pnpm-lock.yaml`, `node_modules`, `cordis.yml` e demais arquivos do DSH não são alterados.

**O que faz, em ordem:**

1. `git apply --reverse` no repo do DSH; se a árvore foi editada após o patch, faz fallback para `git checkout HEAD -- <arquivos-do-patch>` e verifica (fail-safe) que a reversão completou.
2. `pt.ts` é um órfão (não rastreado) — **não é removido por padrão**. Use `-Purge` / `--purge` para deletar. Arquivos versionados nunca são apagados.
3. Opcionalmente `pnpm run build` para regenerar `lib/` sem pt-BR.

**Comandos:**

```powershell
# Dentro do clone deste repo — Windows
powershell -ExecutionPolicy Bypass -File scripts/uninstall.ps1 -DshPath "C:/caminho/para/deepseek-harness" -Force
# -WhatIf    : simula sem alterar
# -NoRebuild : pula o build
# -Purge     : remove pt.ts órfão (default: mantém)
# -Branch main : ramo do GitHub para baixar o patch
```

```bash
# Linux / macOS
bash scripts/uninstall.sh /caminho/para/deepseek-harness --force
# --dry-run    : simula sem alterar
# --no-rebuild : pula o build
# --purge      : remove pt.ts órfão (default: mantém)
# --branch main : ramo do GitHub
```

**Via GitHub (sem clonar este repo):**

```powershell
# Windows
powershell -Command "iwr -useb https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/scripts/uninstall.ps1 | iex" -DshPath "C:/caminho/para/deepseek-harness"
```
```bash
# Linux / macOS
bash <(curl -sL https://raw.githubusercontent.com/paulomec/pt-br-dsh/main/scripts/uninstall.sh) /caminho/para/deepseek-harness
```

**Segurança:**

- Valida que o alvo é um repo git do DSH.
- `git apply --reverse --check` antes de reverter; se já revertido, é no-op.
- `pt.ts` só é removido se for órfão **e** com `-Purge`/`--purge`.
- Verificação fail-safe aborta se a reversão ficar parcial.

> Depois: `Configurações → Geral → Idioma → English`.

</details>

## 🔍 O que o patch altera

<details>
<summary><strong>Arquivos tocados (clique para expandir)</strong></summary>

- `packages/client/locale/` — adiciona `pt` a `LOCALE_IDS`, dicionário `common` (`pt.ts`), lista de idiomas, `<html lang="pt-BR">`
- `packages/client/ui-*` — 24 pacotes com dicionários pt-BR completos (ver tabela de [Cobertura](#-cobertura))
- `lib/` — gerado por `pnpm run build`, não versionado

O patch não altera `pnpm-lock.yaml`, `node_modules`, `cordis.yml` ou qualquer arquivo fora de `packages/client/`.

</details>

## 📁 Estrutura

```
pt-br-dsh/
├── README.md
├── pt-br.patch                  # patch Git aplicável ao DSH
└── scripts/
    ├── apply-and-build.ps1/.sh  # patch + build (uso local)
    ├── install.ps1/.sh          # instalação via GitHub (1-liner)
    └── uninstall.ps1/.sh        # desinstalação / undo cirúrgico
```

## 🛠️ Desenvolvimento

Para editar traduções, altere os `locales.ts` dos pacotes e `locale/src/locales/pt.ts`:

```bash
# Rebuild de um pacote específico
cd packages/client/ui-conversation && pnpm exec tsdown

# Ou rebuild geral
pnpm run build
```

> [!TIP]
> Sempre confira contra o `zh.ts` do pacote — ele é a fonte da verdade. O type-check `satisfies Record<ZhKey, string>` vai acusar chaves faltando.

## ❓ FAQ / Solução de problemas

**`git apply` falhou com `patch does not apply`?**
O DSH avançou desde que o patch foi gerado. Atualize este repo (`git pull`) e tente novamente. Se persistir, faça um fork e regenere o patch localmente — informe o commit do DSH (`git rev-parse HEAD` no `deepseek-harness`) no seu fork.

**`pnpm run build` falhou?**
Garanta Node 22+ e `pnpm install` limpo. O erro mais comum é `ERR_PNPM_NO_IMPORTER_MANIFEST` — rode `pnpm install` na raiz do DSH.

**Troquei o idioma mas algumas strings continuam em inglês?**
Faça hard reload (`Ctrl+Shift+R`) ou reinicie `pnpm dsh web`. Em dev com HMR, o `lib/` precisa ser regenerado.

**Como sei que o patch está aplicado?**
```bash
git -C /caminho/para/deepseek-harness apply --check ../pt-br-dsh/pt-br.patch
# sem saída = aplicável (ainda não aplicado); erro = já aplicado
```

**Posso contribuir com correções de tradução?**
Este repo não aceita Issues/PRs — faça um fork e aplique as correções no seu fork. Veja [Contribuindo](#contribuindo).

## 🤝 Contribuindo

Este é um projeto pessoal e **não recebe Issues ou Pull Requests**.

Se quiser corrigir traduções, adaptar para uma versão mais nova do DSH ou personalizar, faça um **fork** e mantenha sua própria cópia — o patch é aberto e livre para isso.

## 🤖 Nota sobre IA

Este projeto foi criado com assistência de IA **utilizando o próprio DeepSeek Harness (DSH)** como ambiente de desenvolvimento, com diversos modelos ao longo do processo — do **DeepSeek V4 Flash** a outros modelos abertos.

## 📄 Licença

[MIT](LICENSE) — mesmo licenciamento do DeepSeek Harness. Sinta-se livre para forkar e adaptar.
