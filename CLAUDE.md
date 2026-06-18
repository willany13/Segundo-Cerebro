---
tags:
  - grupo/nucleo
---
# CLAUDE.md — Regras-mestras do Segundo Cérebro

Este arquivo é a fonte de verdade do vault. Toda sessão começa por ele.

## 1. Início de sessão
Sempre leia, na ordem:
- `05-sistema/agent.md` (personagem / regras de voz)
- `01-eu/perfil.md` (quem eu sou)
- `05-sistema/memory.md` (decisões, preferências, correções datadas)
- `05-sistema/roteamento.md` (tabela de roteamento)
- `index.md` (o que existe no vault)

Depois desse carregamento, responda normalmente.

## 2. Fim de sessão
Ao encerrar:
- atualize `05-sistema/memory.md` com decisões relevantes;
- atualize `index.md` para refletir qualquer nota nova/renomeada/excluída;
- se houver fatos do dia, registre também em `04-capturas/<YYYY-MM-DD>.md`.

## 3. Roteamento

Consulte a tabela oficial em `05-sistema/roteamento.md` — é a fonte única.

Regra de arquivo: nunca salve solto na raiz. Sempre dentro de um pilar. Se a pasta não existir, crie primeiro. Consulte `index.md` antes de criar para não duplicar.

## 4. Modos de operação
Reconheça dois modos sozinho:
- **CAPTURA** — quando eu relatar algo do dia: roteie e responda curto.
- **CHAT** — quando eu perguntar ou pedir tarefa: responda normal.

## 5. Convenção de notas
- Tema/tipo no topo (tag ou wikilink);
- nome de arquivo limpo em kebab-case;
- conteúdo em bullets curtos.

## 6. Vinculação automática
- Projetos em `02-projetos/` devem linkar para conhecimento aplicado em `03-conhecimento/`.
- Notas de conhecimento devem linkar de volta para projetos quando houver aplicação direta.
- Quando criar nota ligada a duas áreas, crie os links sem esperar pedido.
- **Padrão de organização de projetos**: cada arquivo em `02-projetos/` deve ter um campo `Conhecimento relacionado:` com wikilink para o README da área correspondente em `03-conhecimento/`. O README da área deve listar todos os projetos que a usam.

Regra: se há sobreposição natural entre pilares, deixe a conexão explícita.

## 7. Arquivos sem título
- Remover automaticamente arquivos com nome `Sem título`, `Untitled`, `.base` ou `.canvas` na raiz ou fora dos pilares.
- Nunca criar nota solta na raiz. Sempre dentro de um pilar apropriado, criando a pasta se faltar.

## 8. Revisão de links ao criar nota
Ao criar uma nota, verificar se notas existentes devem apontar para ela ou ser apontadas por ela. Os links são bidirecionais quando há aplicação direta entre áreas diferentes.

## 9. Regra anti-dump para skills
Skills que geram documentos (ex.: `notebook-to-md`, `yt-to-notebook`) devem produzir **um documento de saída por assunto**, não fazer dump de arquivos.
Cada documento deve conter:
- **modelo/abstract mínimo** (3-5 linhas);
- **campo(s) de origem explícitos** (id do notebook, título, data);
- **destino escolhido** antes da formatação;
- resumo ou síntese, ao invés de enumeração de arquivos/caminhos.

Use isso como bloqueio pré-escrita: se o modelo/abstract ficar vazio, a saída não deve ser salva.
