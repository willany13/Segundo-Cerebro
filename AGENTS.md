---
tags:
  - grupo/nucleo
---
# AGENTS.md — Regras-mestras do Segundo Cérebro

Este arquivo é a fonte de verdade do vault. Toda sessão começa por ele.

> **Regra de proteção:** `AGENTS.md` e `05-sistema/agent.md` só podem ser alterados com autorização explícita do usuário. Se uma tarefa pedir mudança nestes arquivos, pergunte antes de executar.

## 1. Início de sessão
Sempre leia, na ordem:
- `05-sistema/agent.md` (personagem / regras de voz)
- `01-eu/perfil.md` (quem eu sou)
- `05-sistema/memory.md` (decisões, preferências, correções datadas)
- `05-sistema/roteamento.md` (tabela de roteamento)
- `index.md` (o que existe no vault)

Depois desse carregamento, execute automaticamente:
- `pwsh 05-sistema/comandos/iniciar-sessao.ps1` (expurga staging, conta pendentes — leva < 2s)
- Se houver capturas pendentes, processe em **segundo plano** enquanto já responde
- Exemplo: "Segundo Cérebro ativo. X capturas pendentes sendo processadas."

## 2. Fim de sessão (automático — não perguntar)
Ao encerrar, execute TUDO abaixo sem perguntar:
1. atualize `05-sistema/memory.md` com decisões relevantes;
2. atualize `index.md` para refletir qualquer nota nova/renomeada/excluída;
3. se houver fatos do dia, registre também em `04-capturas/<YYYY-MM-DD>.md`;
4. **rode `pwsh 05-sistema/comandos/encerrar-sessao.ps1`** (expurgo → backup → validar links);
5. se o backup ou validação falhar, avise — mas só pergunte se for algo crítico (ex.: broken link que não sabe como corrigir).

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

**Antes de salvar qualquer `[[wikilink]]`, verificar se o destino existe no disco.** `[[link]]` só deve ser usado para arquivos dentro do vault. Para arquivos fora do vault (ex.: `D:\IA\Skill-Hermes\...`), usar markdown: `[desc](file:///D:/caminho/para/arquivo)`.

**Nunca usar `[[placeholder]]` em templates.** Usar `\`placeholder\`` no lugar.

## 9. Captura dinâmica

O vault tem 4 mecanismos de captura rápida. Prioridade: detecção automática > atalho > comando > bookmarklet.

### 9.1 Vigia Clipboard (automático)
- Script: `05-sistema/comandos/vigia-clipboard.py`
- Roda em segundo plano (iniciar com `05-sistema/comandos/iniciar-vigia.bat`)
- **Detecta URLs copiadas** automaticamente e salva em `05-sistema/staging/`
- **Ctrl+Shift+C** (qualquer app): captura o que estiver na clipboard
- Dependências: `pip install pyperclip pynput`

### 9.2 Quick Capture (comando)
- Script: `05-sistema/comandos/captura-rapida.ps1`
- Uso: `pwsh captura-rapida.ps1 -Texto "URL ou nota"`
- Aceita pipeline: `echo "nota" | pwsh captura-rapida.ps1`
- Gera arquivo em `05-sistema/staging/` com frontmatter automático

### 9.3 Marcador Web (bookmarklet)
- Instruções: `05-sistema/comandos/marcador-web.md`
- Arraste o bookmarklet para a barra de favoritos
- Um clique: copia título + URL + seleção para clipboard
- O Vigia detecta a URL e captura automaticamente

### 9.4 Daily Note (Obsidian)
- Template: `05-sistema/templates/daily.md` (configurado no app.json)
- Atalho padrão do Obsidian para daily note
- Criar em `04-capturas/` com `Ctrl+Shift+D` no Obsidian

Ao iniciar sessão, se o Vigia estiver rodando, verificar `05-sistema/staging/` por novas capturas e processá-las.

### 9.5 Staging automático
- `05-sistema/comandos/observar-staging.ps1` — vigia a pasta staging e processa novos `.md` com `processar-staging.ps1 -AutoApprove`
- `05-sistema/comandos/expurgar-staging.ps1` — limpa staging (>7d archive, >30d candidato exclusão)
- Executar `expurgar-staging.ps1 -Executar` ao iniciar sessão

### 9.6 PDF automático
- `05-sistema/comandos/extrair-pdf.ps1` — extrai texto de PDFs em staging e gera `.md`
- Dependência: Python + pdfplumber (já instalado)

### 9.7 Bot Telegram (mobile)
- Script: `05-sistema/comandos/bot-telegram.py`
- Setup: `05-sistema/comandos/bot-telegram.md`
- Envia mensagem, URL, foto ou documento do celular → cai direto em staging
- Comandos: `/capturar`, `/processar`, `/status`

### 9.8 Auto-tagging
- `05-sistema/comandos/auto-tag.py` — sugere tags para uma nota baseado no conteudo
- Uso: `python auto-tag.py nota.md` ou `python auto-tag.py --dir staging/`

### 9.9 CI (GitHub Actions)
- `.github/workflows/validate.yml` — roda `validar-links.ps1` em todo push
- Se houver broken link, o PR/push e bloqueado automaticamente

### 9.10 Atalhos Windows
- `captura-rapida.bat` — duplo clique, pergunta texto, salva em staging
- `processar-staging.bat` — duplo clique, processa staging
- `backup.bat` — duplo clique, commit + push
- `revisao-semanal.bat` — duplo clique, mostra relatorio

### 9.11 Busca rápida
- `05-sistema/comandos/busca-vault.ps1` — busca termo no vault com trechos
- `pwsh busca-vault.ps1 -Termo "skill hermes" -Pilar "03-conhecimento" -Contexto 3`

## 10. Automação agendada (Windows Task Scheduler)
Para rodar expurgo e backup mesmo sem agente, configure com:
- `pwsh 05-sistema/comandos/setup-agendamento.ps1` (executar como Administrador UMA VEZ)
- Cria tarefas: Cerebro-Expurgo (09:00) e Cerebro-Backup (18:00)

## 11. Regra de decisão: automático vs manual
**Tudo é automático por padrão.** Eu só pergunto se:
1. A tarefa pede alteração em `AGENTS.md` ou `05-sistema/agent.md` (regra de proteção)
2. Uma decisão do vault conflita com o que está sendo pedido
3. Um comando crítico falhou e não sei como resolver sozinho

Fora isso, eu simplesmente **faço** — expurgo, backup, validação, captura, roteamento, consolidação. Sem perguntar.

## 12. Regra anti-dump para skills
Skills que geram documentos (ex.: `notebook-to-md`, `yt-to-notebook`) devem produzir **um documento de saída por assunto**, não fazer dump de arquivos.
Cada documento deve conter:
- **modelo/abstract mínimo** (3-5 linhas);
- **campo(s) de origem explícitos** (id do notebook, título, data);
- **destino escolhido** antes da formatação;
- resumo ou síntese, ao invés de enumeração de arquivos/caminhos.

Use isso como bloqueio pré-escrita: se o modelo/abstract ficar vazio, a saída não deve ser salva.
