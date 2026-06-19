---
title: Mapa de Conhecimento
tags:
  - grupo/nucleo
---

# Mapa de Conhecimento

Visão consolidada de todo o conhecimento do vault, organizado por tema e com links entre áreas.

## 🧠 Programação e IA

`03-conhecimento/programacao-e-ia/`

| Nota | Síntese |
|------|---------|
| [[programacao-e-ia/powershell-pratico.md]] | **PowerShell** — try/catch, logging, debug, modular, exit code |
| [[programacao-e-ia/python-pratico.md]] | **Python** — automação de arquivos, requests, PDF, argparse |
| [[programacao-e-ia/git-pratico.md]] | **Git** — fluxos, hooks, aliases, CI/CD com GitHub Actions |
| [[programacao-e-ia/apis-pratico.md]] | **APIs** — REST, autenticação, rate limiting, GitHub API |
| [[programacao-e-ia/cli-pratico.md]] | **CLI** — argparse, entry points, cores, template híbrido |
| [[programacao-e-ia/mao-na-massa.md]] | **Padrões do vault** — PowerShell, git hooks, pipeline, regex |
| [[programacao-e-ia/captura-de-conhecimento.md]] | **Staging dinâmico** — buffer → validar → commit |
| [[programacao-e-ia/segundo-cerebro-completo.md]] | **Arquitetura** — Obsidian + Claude + skills |
| [[programacao-e-ia/infinite-memory-system.md]] | **Memória infinita** — NotebookLM + Claude + Obsidian |
| [[programacao-e-ia/notebooklm-vai-mudar-notebooklm-claude.md]] | **Integração** — NotebookLM como base de conhecimento |

**Aplicação direta:** [[02-projetos/skill-hermes.md]], [[02-projetos/projetos-de-ia.md]]

## 🤖 Skills e Agentes

`03-conhecimento/skills/`

| Nota | Síntese |
|------|---------|
| [[skills/autonomous-ai-agents.md]] | **Orquestrador Mixture of Agents** — delega tarefas entre provedores com paralelismo |
| [[skills/limites-e-fallback-provedores.md]] | **Tabela de limites** — RPM, custo, fallback de cada provedor (OpenAI, Claude, Gemini, Grok, OpenRouter, Ollama) |

**Aplicação direta:** [[02-projetos/skill-hermes.md]], [[02-projetos/skill-nota-corretagem.md]]

## 🎯 Prompt Engineering

`03-conhecimento/youtube/`

| Nota | Síntese |
|------|---------|
| [[youtube/2026-06-18-o-guia-definitivo-de-engenharia-de-prompt.md]] | **Guia completo** — técnicas, chain-of-thought, few-shot, personas |
| [[youtube/2026-06-18-como-eu-uso-ia-pra-programar-em-2026.md]] | **IA no dia a dia** — fluxo real de programação com assistência de IA |
| [[youtube/2026-06-18-aprenda-a-criar-infograficos-profissionais-com-ia-usando-1-prompt.md]] | **Geração visual** — infográficos com IA em 1 prompt |
| [[youtube/2026-06-18-o-jeito-certo-de-usar-ia-para-programar.md]] | **Jeito certo** — boas práticas de IA para programação |
| [[youtube/2026-06-18-automacao-para-afiliados-com-python-e-github-actions.md]] | **Automação** — Python + GitHub Actions para afiliados |

**Aplicação direta:** [[02-projetos/sistema-criacao-conteudo-ia.md]]

## 🔗 Conexões entre áreas

```
Programação e IA ──────► Skills ──────► Prompt Engineering
       │                      │                │
       │              (agentes usam           (prompts
       │               provedores)          estruturam
       │                                      tarefas)
       ▼                      ▼                ▼
   skill-hermes ───────► skill-nota ─────► sistema-conteudo
```

## 📥 De onde vem

- [[notebooklm/README.md]] — notas importadas do NotebookLM
- [[youtube/README.md]] — notas de vídeos do YouTube
- [[skills/README.md]] — documentação de skills instaladas
- [[informacoes-filtradas/README.md]] — dados processados e filtrados
