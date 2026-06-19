---
tags:
  - tipo/indice
  - conceito/inteligencia-artificial
  - conceito/skill
  - ferramenta/notebooklm
  - projeto/hermes
  - tipo/projeto
---

# YouTube — Notas de vídeos

Notas geradas a partir de vídeos do YouTube, processadas via pipeline
`yt-to-notebook` → NotebookLM → markdown.

## Projetos relacionados

- [[02-projetos/skill-hermes.md]] — skill yt-to-notebook
- [[02-projetos/sistema-criacao-conteudo-ia.md]] — pipeline YouTube → conteúdo

## Origem
- Skill: [yt-to-notebook](file:///D:/IA/Skill-Hermes/yt-to-notebook/SKILL.md)
- Pipeline: URL → NotebookLM → extração → formatação (via `notebook-to-md`)

## Estrutura
Cada nota segue o formato: `YYYY-MM-DD-titulo.md`
- Frontmatter com `tags: [fonte/youtube]`, `origem` (notebook ID), `data`
- TL;DR, tópicos, exemplos e dados do vídeo
- Timestamps preservados nas citações
