---
tags:
  - grupo/sistema
---
# revisao-semanal — Manutenção periódica do vault

Executar semanalmente para evitar deterioração do vault.

## Checklist

1. **Staging** — verificar se há arquivos parados >7 dias, executar expurgo
2. **Links quebrados** — escanear wikilinks de todo o vault e corrigir os quebrados
3. **Index vs disco** — comparar `index.md` com os arquivos reais nos pilares; adicionar/remover entradas
4. **Conhecimento órfão** — notas em `03-conhecimento/` sem link de volta para nenhum projeto
5. **Projetos órfãos** — arquivos em `02-projetos/` sem `Conhecimento relacionado:`
6. **Capturas antigas** — notas em `04-capturas/` com >30 dias que podem ser arquivadas ou sintetizadas em conhecimento

## Como usar

- Diga: "Revisão semanal"
- Eu executo o checklist completo e reporto o que foi ajustado
