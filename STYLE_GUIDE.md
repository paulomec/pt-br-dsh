# Guia de Estilo — pt-br-dsh

Como traduzir o DeepSeek Harness para pt-BR sem quebrar a UI ou o tom.

## Princípios

1.  **Contexto > literal** — traduza o que o usuário *faz*, não o que o `zh`/`en` diz palavra por palavra. `steer` não é “interceptar em fila”, é “enviar como intervenção”.
2.  **Cabível na UI** — títulos de seção, tabs e pickers têm ~14–20 caracteres. Prefira termo curto e familiar a tradução completa. Foi por isso que `Espaços de Trabalho` → `Workspaces`.
3.  **Type-safe** — todo `pt` deve ter `satisfies Record<ZhKey, string>`. Chave faltando = build quebrado. Nunca deixe fallback para `en`.

## Tom

- **Formalidade:** `você` (não `tu`), imperativo curto: `Salvar`, `Cancelar`, `Tentar novamente`.
- **Voz:** direta, sem floreio. `Falha ao carregar` > `Não foi possível carregar com sucesso`.
- **Pontuação:** use `…` (elipse) apenas quando o original usa `…` para loading. Não abrevie com `...`.

## Loanwords — quando manter inglês

| Manter em inglês | Por quê |
|---|---|
| `Workspace` / `Workspaces` | Termo de produto, universal em dev (VS Code, JetBrains). `Espaço de trabalho` estoura container. |
| `Skills` | Nome de feature do DSH (`agent.cordis.yml`). Traduzir para `Habilidades` confunde. |
| `Prompt`, `Cache hit`, `TTFT`, `LLM`, `tok/s` | Siglas/métricas técnicas — usuário espera ver igual. |
| `one-shot` / `continuable` (subagentes) | Modos de execução do motor. Traduzir perde busca na doc. Manter com tooltip se precisar. |

| Traduzir | Exemplo |
|---|---|
| `Subagent` → `Subagente(s)` | Já aportuguesado, cabe |
| `Goal` → `Objetivo` | Claro em pt-BR |
| `Command` → `Comando` | Ação do usuário |

**Regra de ouro:** se o termo aparece na documentação oficial do DSH em inglês e o usuário precisa googlar, mantenha inglês. Se é ação cotidiana, traduza.

## Workspace — decisão A)

| Antes (literal) | Depois (guia) | Chaves afetadas |
|---|---|---|
| `Espaços de Trabalho` | `Workspaces` | `section.workspaces`, `picker.title` |
| `Espaço de trabalho` | `Workspace` | `groupBy.workspace`, `field.workspaceName`, `placeholder.workspace`, `hero.chooseWorkspace` |
| `Selecionar Diretório do Espaço de Trabalho` | `Selecionar Diretório` | `browser.title` |
| `Adicionar espaço de trabalho` | `Adicionar workspace` | `workspace.add`, `menu.addWorkspace` |

Chaves com `workspace` singular/plural devem usar `Workspace`/`Workspaces` consistentemente. `Pasta sem título`, `Nova pasta` continuam pt-BR.

## Comprimento

- **Títulos de seção/nav:** ≤ 16 caracteres (`Workspaces` 10, `Sessões` 7, `Tarefas` 7).
- **Botões:** verbo único (`Salvar`, `Criar`, `Duplicar`).
- **Placeholders/hints:** frase curta em minúsculas, sem ponto final (`descreva sua tarefa para gerar um plano`).

## Padrões já corrigidos (exemplos)

| Chave | Antes | Depois | Motivo |
|---|---|---|---|
| `command.description` | `Select the model for this conversation` (não traduzido) | `Selecione o modelo para esta conversa` | Faltava tradução |
| `ui-jobs: status.killed` | `cancelada` | `encerrada` | Distingue `killed` (sistema) de `cancelled` (usuário) |
| `placeholder.steerQueue` | `Cmd/Ctrl+Enter intercepta todas as mensagens em fila` | `Cmd/Ctrl+Enter envia como intervenção (fura a fila)` | Contexto > literal |
| `stats.cacheHit` | `Cache hit {percent}%` | `Cache {percent}%` | Remove inglês redundante, mantém métrica |
| `appearance.dark` / `toolbar.search` | `Dark` / `Search trajectory` (não traduzido em `ui-subagent`/`ui-theme`) | `Escuro` / `Pesquisar trajetória` | Consistência |

## Como contribuir via fork

Este repo não recebe Issues/PRs. Para propor correções:

1.  Fork → edite `pt-br.patch` seguindo este guia.
2.  Verifique `git apply --check ../pt-br-dsh/pt-br.patch` no DSH não retorna erro.
3.  Garanta `pnpm run build` sem erro de `satisfies Record<ZhKey, string>`.

## Nota sobre IA

Patch gerado com assistência de IA no próprio DSH (DeepSeek V4 Flash e outros modelos abertos). Revisão humana obrigatória para nuance e comprimento.
