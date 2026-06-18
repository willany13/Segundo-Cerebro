---
tags:
  - grupo/sistema
---
# validar-staging — Fluxo de validação de staging

Antes de mover um arquivo de `05-sistema/staging/` para o pilar definitivo, executar os passos abaixo na ordem.

## 1. Duplicidade

- Grep no vault inteiro por trechos-chave do conteúdo (título, termos únicos)
- Se existir nota com o mesmo conteúdo: descartar a entrada do staging ou fundir na nota existente
- Se existir nota similar mas não idêntica: criar link cruzado entre a nova e a existente

## 2. Formato

- Nome do arquivo em kebab-case: `meu-arquivo.md`
- NÃO pode conter: espaços, acentos, caracteres especiais (exceto `-`)
- NÃO pode ser: `Sem título`, `Untitled`, `.base`, `.canvas`
- Se for PDF/imagem: confirmar que é um arquivo válido e não corrompido

## 3. Conteúdo similar

- Verificar se o tema já está coberto em algum pilar (`02-projetos/`, `03-conhecimento/`)
- Se sim: atualizar a nota existente com a nova informação em vez de criar nota nova
- Se não: rotear conforme `05-sistema/roteamento.md`

## 4. Roteamento

- Consultar `05-sistema/roteamento.md` e mover o arquivo para o pilar correspondente
- Atualizar `index.md` se for nota nova
- Criar links cruzados para notas relacionadas

## 5. Pós-validação

- Mover o arquivo validado para `05-sistema/staging/archive/`
- Se arquivo for descartado por duplicidade: mover para `archive/` com sufixo `-duplicata`
