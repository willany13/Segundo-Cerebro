---
titulo: autonomous-ai-agents — Orquestrador Mixture of Agents para Hermes
fonte: skill local `autonomous-ai-agents` v1.1.0
data: 2026-06-18
tags:
  - grupo/skills
  - area/programacao
  - conceito/agente-ia
  - conceito/api
  - conceito/cli
  - conceito/inteligencia-artificial
  - conceito/skill
  - fluxo/validacao
  - linguagem/python
  - projeto/hermes
  - tipo/projeto
---

# 🔑 autonomous-ai-agents — Orquestrador Mixture of Agents para Hermes

> [!abstract] TL;DR
> Skill que decide automaticamente qual agente/provedor executar por tipo de tarefa:
> `parallel`, `openai`, `codex`, `claude-code`, `opencode`, `hermes-agent`, `anthropic`, `google`, `xai`, `openrouter`, `ollama`/`lmstudio`.
>
> Suporta paralelismo com até 3 agentes ao mesmo tempo via `delegate_task` + `tasks`.

> [!info] Fonte
> **Nome da skill:** `autonomous-ai-agents`
> **Versão:** 1.2.0
> **Caminho no Hermes:** `~/AppData\Local\hermes\skills\autonomous-ai-agents\`

---

## 🧠 Filosofia

- **Tarefa → agente → toolset.** Não delegar no escuro.
- Ferramentas primeiro. Não inventar saídas.
- Agentes são folhas (`leaf`), sem nested delegation para este usuário.
- Saída sempre verificável: arquivo, diff, caminho, status.
- Quando a tarefa permitir, paralelizar até **3 agentes** para comparar modelos ou dividir trabalho.

---

## 🤖 Agentes / provedores

| Código | Provedor | Quando usar |
|---|---|---|
| `parallel` | Parallel AI | Tarefas paralelas em massa, orquestração de múltiplas chamadas simultâneas e pipeline de prompts em larga escala. |
| `openai` | OpenAI API direta (GPT) | Integrações GPT puras, embeddings, function calling. |
| `codex` | OpenAI Codex CLI | Código OpenAI/GPT, integrações com ecossistema OpenAI. |
| `claude-code` | Claude Code CLI | Código genérico, refatoração, testes, PRs, qualquer stack. |
| `opencode` | OpenCode CLI | Fluxos abertos, automação browser, exploração livre. |
| `hermes-agent` | Hermes subagente | Config/extensão do próprio Hermes, skills, vault. |
| `anthropic` | Anthropic Claude (API) | Raciocínio avançado, análise longa, revisão estruturada. |
| `google` | Google Gemini (API) | Multimodalidade (imagem + texto), resumo rápido, tarefas gerais. |
| `xai` | xAI Grok (API) | Pesquisa, síntese web, respostas diretas. |
| `openrouter` | OpenRouter | Comparar modelos ou usar modelos específicos sem trocar de provedor. |
| `ollama` / `lmstudio` | Local | Privacidade, custo zero, tarefas simples, offline. |

---

## 🗺️ Mapa: tarefa → agente

| Tipo de tarefa | Agente(s) preferido(s) | Toolsets recomendados |
|---|---|---|
| Código geral, refatoração, testes, PRs | `claude-code`, `codex`, `anthropic` | `terminal`, `file`, `web` |
| Código OpenAI / GPT / integrações | `codex`, `openai` | `terminal`, `file`, `web` |
| Fluxos abertos, browser, automação web | `opencode` | `browser`, `file`, `terminal` |
| Multimodalidade (imagem + texto) | `google` | `web`, `file` |
| Raciocínio avançado, análise longa | `anthropic` | `terminal`, `file`, `web` |
| Pesquisa, síntese web, respostas diretas | `xai`, `openrouter` | `web`, `terminal` |
| Comparar modelos por qualidade/custo | `openrouter` | `terminal`, `web` |
| Offline / sem envio para nuvem | `ollama`, `lmstudio` | `terminal`, `file` |
| Config/extensão do próprio Hermes | `hermes-agent` | `file`, `terminal`, `skills` |

---

## ⚙️ Workflow de delegação

1. **Classificar** a tarefa por classe:
   - `code` — escrever/refatorar/testar código, gerar PR
   - `hermes-config` — ajustar config, skills, plugins, cronjobs
   - `web/automation` — scraping, automação browser, fluxos web
   - `experiment` — POC, protótipo, exploração livre
   - `analysis` — raciocínio longo, revisão, síntese

2. **Selecionar agente e toolsets** conforme a tabela acima.

3. **Montar o prompt** do subagente:
   - Específico: arquivos, caminhos, restrições, critérios de aceite
   - Formato de saída esperado: caminho, diff, relatório, status
   - Não delegar contexto frágil além do necessário; não embutir histórico longo
   - Quando a tarefa envolver Projetos de IA, referencie `D:\IA\PROJETOS DE IA`, não reimplemente escopo

4. **Chamar `delegate_task`** com:
   - `goal` claro e autossuficiente
   - `toolsets` coerentes com o agente
   - `role` = `leaf`
   - Quando múltiplos agentes couberem, escolher o mais simples que resolver

5. **Validar saída**:
   - Caminho/relatório → `read_file`
   - Código → `terminal`
   - Resultado web → `browser`/`curl`

---

## 🧪 Exemplos

### Exemplo 1: feature nova em repositório do Kennedy

- Classe: `code`
- Agente: `claude-code`
- Toolsets: `terminal`, `file`
- Prompt: "Implementar X em `D:\IA\PROJETOS DE IA\repo-xyz\` seguindo o padrão do projeto. Retorne diff e caminho dos arquivos alterados."

### Exemplo 2: automação de browser para site XYZ

- Classe: `web/automation`
- Agente: `opencode`
- Toolsets: `browser`, `file`, `terminal`
- Prompt: "Criar script em Python que acessa https://example.com, extrai dados e salva em CSV em `D:\IA\...`. Retorne o código e como rodar."

### Exemplo 3: configurar nova skill do Hermes

- Classe: `hermes-config`
- Agente: `hermes-agent`
- Toolsets: `file`, `terminal`, `skills`
- Prompt: "Criar skill `xyz` em `~/AppData\Local\hermes\skills\xyz\` com template canônico (SKILL.md, setup.ps1, scripts/). Retorne árvore de arquivos criada."

### Exemplo 4: análise longa de repositório

- Classe: `analysis`
- Agente: `anthropic`
- Toolsets: `terminal`, `file`, `web`
- Prompt: "Analisar `D:\IA\PROJETOS DE IA\xyz\` e produzir relatório de arquitetura, pontos fortes e riscos. Retorne caminho do relatório."

---

## 🚀 Paralelismo (Mixture of Agents)

Quando a tarefa permitir, execute **até 3 agentes em paralelo** para:
- Comparar resultados de modelos diferentes no mesmo problema
- Dividir trabalho em subtarefas independentes
- Benchmark de qualidade/custo/latência

### Uso com `delegate_task`

Use `tasks` (array de até 3) em vez de `goal`:

```json
{
  "tasks": [
    {
      "goal": "Analisar repositório X",
      "toolsets": ["terminal", "file"],
      "role": "leaf"
    },
    {
      "goal": "Analisar repositório X",
      "toolsets": ["terminal", "file"],
      "role": "leaf"
    },
    {
      "goal": "Analisar repositório X",
      "toolsets": ["terminal", "file"],
      "role": "leaf"
    }
  ]
}
```

Cada item pode ter `model`/`provider` diferente. Os resumos voltam juntos.

### Regras

- Máximo 3 paralelos por chamada (limite deste usuário)
- Subtarefas devem ser **verdadeiramente independentes**
- Não paralelizar etapas que precisam de resultado anterior
- Em benchmark, usar mesma `toolsets` para todos
-leaf` não chama `leaf` novamente

### Benchmark rápido

Comparar `claude-code`, `codex` e `anthropic`:

```json
{
  "tasks": [
    {
      "model": "claude-code",
      "goal": "...",
      "toolsets": ["terminal", "file"]
    },
    {
      "model": "codex",
      "goal": "...",
      "toolsets": ["terminal", "file"]
    },
    {
      "model": "anthropic",
      "goal": "...",
      "toolsets": ["terminal", "file"]
    }
  ]
}
```

Objetivo: medir qualidade, velocidade e custo relativo no mesmo problema.

---

## 📌 Cola rápida

| Problema | Agente recomendado |
|---|---|
| Código em qualquer linguagem | `claude-code` |
| Código OpenAI / GPT específico | `codex`, `openai` |
| Browser / automação web | `opencode` |
| Claude com máxima capacidade de raciocínio | `anthropic` |
| Multimodal (imagem + texto) | `google` |
| Pesquisa rápida na web | `xai` |
| Comparar 3 modelos na mesma tarefa | `openrouter` (ou paralelo) |
| Rodar sem internet / privado | `ollama`, `lmstudio` |
| Ajustar o próprio Hermes | `hermes-agent` |

---

## ❌ O que não fazer

- Não delegar tarefa frágil ou dependente de contexto da sessão atual.
- Não criar loops de delegação: leaf não chama leaf novamente.
- Não aceitar saída não verificada: sempre pedir caminho, diff ou status.
- Não paralelizar etapas sequenciais.
- Não ultrapassar 3 agentes por chamada.

---

> [!quote] Kennedy
> "Use a ferramenta certa para o trabalho. Não adianta ter o melhor modelo se a delegação é cega."
