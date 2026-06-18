---
tags:
  - grupo/sistema
---
# Fechar dia

Persiste decisões, valida staging e atualiza índice e captura do dia.

## Pré-condição

Se houver arquivos em `05-sistema/staging/`, executar `validar-staging.md` primeiro.

## Fluxo

1. Executar expurgo do staging: arquivos com >7 dias sem modificação → `archive/`
2. Ler `05-sistema/memory.md`, `index.md` e `04-capturas/<YYYY-MM-DD>.md`
3. Consolidar decisões e aprendizados do dia em `05-sistema/memory.md`
4. Se houver fatos do dia sem registro → criar/atualizar `04-capturas/<YYYY-MM-DD>.md`
5. Atualizar `index.md` com notas novas/renomeadas/excluídas
6. Verificar se há novos links quebrados no vault
7. Responder com resumo do que foi ajustado

Como usar:
- Diga: "Fechar dia"
- Eu executo o fluxo completo.
