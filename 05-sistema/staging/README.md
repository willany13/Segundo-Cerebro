---
tags:
  - grupo/sistema
---
# Staging

Pasta temporária de captura dinâmica.

- Todo input novo primeiro vem para cá
- Depois passa por validação (duplicidade, formato, links)
- Só então é movido para o pilar definitivo

## Expurgo automático

- Arquivos com **mais de 7 dias sem modificação** são movidos para `archive/`
- Arquivos em `archive/` com **mais de 30 dias** são candidatos a exclusão (confirmar antes de apagar)
- O expurgo é executado ao iniciar uma sessão se houver arquivos no staging

Modos:
- staging normal: arquivos pendentes
- archive: arquivos já processados ou cancelados
