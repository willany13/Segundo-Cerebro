---
tags:
  - grupo/sistema
---
# Inputs recorrentes da operação

Formato padrão para registrar pontos importantes da operação durante o dia.

## Formato

- fonte: (PDF / imagem / link / site / nota)
- tipo: (decisão / projeto / conhecimento / dado operacional)
- resumo em 1–2 linhas

## Regras automáticas

- todo conteúdo novo que vire nota → atualizar [[index.md]]
- se houver sobreposição natural → adicionar links cruzados
- nunca criar nota solta na raiz; sempre em um pilar correspondente

## Fluxo operacional

1. registrar o ponto
2. rotear conforme tabela do vault
3. atualizar [[index.md]]
4. em fechamento de dia, usar regra de fim de sessão:
   - atualizar [[05-sistema/memory.md]]
   - atualizar [[index.md]]
   - registrar em `04-capturas/<YYYY-MM-DD>.md`

## Notas

- usar [[05-sistema/comandos/input-rec-ouperacao.md]] como fonte única da verdade para inputs recorrentes
- guardar decisões e dados válidos em [[05-sistema/memory.md]]