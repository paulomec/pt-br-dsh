# pt-br-dsh — pt-BR (Português Brasileiro) para o DSH

Traduz o frontend do [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) para Português Brasileiro.

Suporta **todas as 24 namespaces** da UI (conversation, workspace, subagent, settings-models, settings-plugins, etc.) — dicionários completos, não fallbacks.

## Uso rápido

```bash
# 1. Clone o DSH (se ainda não tiver)
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness

# 2. Aplique o patch pt-BR (do repositório pt-br-dsh)
git apply ../pt-br-dsh/pt-br.patch

# 3. Instale dependências e faça o build
pnpm install
pnpm run build

# 4. Rode
pnpm dsh web
```

Depois, nas Configurações → Geral → Idioma, selecione **Português (BR)**.

## Detalhes

### O que o patch altera

- `packages/client/locale/` — sistema de locale: adiciona `pt` ao `LOCALE_IDS`, cria o dicionário `common` (`pt.ts`), registra `Português (BR)` na lista de idiomas, define `<html lang="pt-BR">`.
- `packages/client/ui-*` — 24 pacotes de UI recebem dicionários pt-BR e seus calls de `locale.register()` são atualizados.
- Arquivos compilados (`lib/`) precisam ser rebuildados via `pnpm run build` (o patch só altera a fonte `.ts`).

### Requisitos

- Node.js 22+ e pnpm (gerenciador de pacotes do DSH)
- O patch foi gerado contra a versão principal do DSH. Se o repositório tiver divergido muito, pode ser necessário ajustar o patch manualmente.

### Estrutura

```
pt-br-dsh/
├── README.md          # este arquivo
├── pt-br.patch        # git diff para aplicar ao DSH
└── scripts/
    ├── apply-and-build.sh   # Linux/macOS
    └── apply-and-build.ps1  # Windows
```

## Para desenvolvedores

Para modificar as traduções, edite os arquivos `locales.ts` nos pacotes `packages/client/ui-*/src/client/` e o `locale/src/locales/pt.ts`. Depois reconstrua:

```bash
# Apenas o pacote que mudou
cd packages/client/ui-conversation && pnpm exec tsdown

# Ou tudo de uma vez
pnpm run build
```