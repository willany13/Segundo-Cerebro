---
title: "Achado — OpenCode no Windows"
data: 2026-06-18
tags:
  - tipo/achado
  - tema/agentes
  - tema/hermes
  - tema/opencode
---

# Achado — OpenCode no Windows

## Instalação real
- Desktop App
  - Executável: `C:\Users\Willany-PC\AppData\Local\Programs\@opencode-aidesktop\OpenCode.exe`
  - Config global: `C:\Users\Willany-PC\.config\opencode\opencode.jsonc`
  - Estado: instalado e funcional no Windows

## Observação
- `delegate_task` espera integração pela skill `opencode` do Hermes, e não `where`.
- O teste direto por `opencode.exe --help` trava porque ele inicializa a UI desktop.

## Como usar pragmaticamente
- Spawn via Hermes deve apontar para o caminho completo do `.exe`
- Não usar apenas `opencode`, senão o sistema não encontra o binário

## Decisão
Registrar como agente disponível, com caminho canônico fixo para uso.
