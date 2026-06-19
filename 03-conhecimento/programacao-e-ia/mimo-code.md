---
title: "Achado — MiMo Code e Hermes"
data: 2026-06-18
tags:
  - tipo/achado
  - tema/agentes
  - tema/hermes
  - tema/mimo
---

# Achado — MiMo Code e Hermes

## Repo
- https://github.com/XiaomiMiMo/MiMo-Code

## O que é
- CLI/TUI autônoma (`mimo`) baseada em fork do OpenCode
- Agentes próprios: `build`, `plan`, `compose`
- Memória persistente em SQLite FTS5
- Config própria: `.mimocode/mimocode.json` ou `~/.config/mimocode/mimocode.json`

## Conclusão
**Não integrável como subagente do Hermes.**

Motivo: projeto é uma ferramenta standalone, não expõe SDK/API
para delegação programática nem modelo de provedor compatível com
OpenAI. Também não consta na lista de provedores do Hermes.

## Caminhos possíveis (somente orquestração externa)
- Spawn por tmux com captura de stdout
- Wrapper shell que executa `mimo` e parseia a saída

## Decisão
Tratar como ferramenta externa. Não adicionar ao MoA/fallback.
