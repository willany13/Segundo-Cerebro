---
tags:
  - grupo/sistema
---
# Memória

Perfil, preferências e decisões datadas. Atualizado em 2026-06-18.

## Quem é
- Kennedy
- Trabalha com projetos de IA e atividades relacionadas.
- Frentes principais: Skill-Hermes, PROJETOS DE IA, Controle de Ativos, Sistema de Criação de Conteúdo com IA, Skill Nota-Corretagem.

## Preferências
- Sem rodeios, direto ao ponto.
- Às vezes humorado.
- Quer links cruzados automáticos entre projetos e conhecimento.
- Fluxo de captura dinâmico para PDF, imagem, link, site e notas.

## Decisões e correções
- 2026-06-18: estrutura inicial do Segundo Cérebro.
- 2026-06-18: notebooklm-skill aprimorada com 6 melhorias: setup.ps1 Windows, wrapper PowerShell, templates, integração vault, healthcheck, refresh automático de sessão.
- 2026-06-18: yt-to-notebook reformulado como skill YouTube-específica (antes era cópia do notebook-to-md). Criados scripts get-yt-metadata.ps1, create-from-yt.ps1, yt-wrapper.ps1, setup.ps1, healthcheck.ps1, integrate-vault.ps1. Referências deduplicadas.
- 2026-06-18: notebook-to-md reconstruído como skill base completa (antes era stub). SKILL.md com pipeline extrair → formatar/entregar, compartilha references/ e scripts/ com yt-to-notebook.
- 2026-06-18: README.md do Skill-Hermes atualizado com tabela de skills e status.
- 2026-06-18: tabela de roteamento extraída para `05-sistema/roteamento.md` (fonte única). AGENTS.md e memory.md referenciam ela.
- 2026-06-18: fluxo de captura fluido implantado (`05-sistema/comandos/captura-rapida.ps1` + `vigia-clipboard.py`).
- 2026-06-18: padronização de arquivos de visão geral para `README.md` por tema.
- 2026-06-18: remoção automática de `Sem título`, `Untitled`, `.base` e `.canvas` fora dos pilares ativada por ação.
- 2026-06-18: revisão de links ao criar nota ativada.
- 2026-06-18: criados `02-projetos/controle-de-ativos.md`, `02-projetos/skill-nota-corretagem.md` e `02-projetos/sistema-criacao-conteudo-ia.md` para sanar wikilinks quebrados.
- 2026-06-18: staging ganhou regra de expurgo (7 dias → archive, 30 dias → exclusão).
- 2026-06-18: links bidirecionais completados entre projetos e conhecimento: `sistema-criacao-conteudo-ia` ↔ `programacao-e-ia`, `controle-de-ativos` ↔ `mercado-financeiro`, `skill-hermes` adicionado em `skills/README.md`.
- 2026-06-18: `instrucao-captura.md` e `fechar-dia.md` substituídos por `captura-rapida.ps1` e `encerrar-sessao.ps1`.
- 2026-06-18: `perfil.md` enriquecido com stack, área e interesses.
- 2026-06-18: criada nota `nota-corretagem-pipeline.md` em `mercado-financeiro/`.
- 2026-06-18: captura registrada: `notebooklm-vai-mudar-notebooklm-claude.md` em `programacao-e-ia/`.
- 2026-06-18: limpeza de 4 pastas vazias fantasmas: `01-eu/objetivos/`, `03-conhecimento/ia/`, `03-conhecimento/outros/`, `03-conhecimento/programacao/`.
- 2026-06-18: `informacoes-filtradas/` ganhou primeira nota real: `extended-graph-customizacao-graph-view-obsidian.md` movida para `ferramentas/`.
- 2026-06-18: `informacoes-filtradas/README.md` limpo (remoção de duplicação e template com emoji).

- 2026-06-18: `objetivos.md` atualizado — curto prazo riscado (estrutura feita), longo prazo preenchido.
- 2026-06-18: `skill-hermes.md` expandido com capacidades, subprojetos e skills relacionadas.
- 2026-06-18: `projetos-de-ia.md` expandido como guarda-chuva listando todos os projetos vinculados. com stack (Python), área (IA/ML + Dev geral), interesses (mercado financeiro, Obsidian, ferramentas IA).
- 2026-06-18: `infinite-memory-system.md` e `captura-de-conhecimento.md` vinculados a `skill-hermes.md` e `projetos-de-ia.md`.
- 2026-06-18: `revisao-semanal.md` substituído por `revisao-semanal.ps1`.
- 2026-06-18: removida duplicação de regras do vault do `agent.md` (eram redundantes com AGENTS.md).
- 2026-06-18: fluxo `validar-staging.md` substituído por `processar-staging.ps1`.
- 2026-06-18: nota `2026-06-18-automacao-para-afiliados-com-python-e-github-actions.md` gerada via NotebookLM a partir do vídeo `px7O23SvIn8` e salva em `03-conhecimento/youtube/`.
- 2026-06-18: nota `2026-06-18-como-eu-uso-ia-pra-programar-em-2026.md` gerada via NotebookLM a partir do vídeo `7nN4ayK79oc` e salva em `03-conhecimento/youtube/`. NotebookLM: `d5024cd0-...` com fonte `c20de796-...`.
- 2026-06-18: nota `2026-06-18-o-guia-definitivo-de-engenharia-de-prompt.md` gerada via NotebookLM a partir do vídeo `xJzLJMRxFIc` e salva em `03-conhecimento/youtube/`. NotebookLM: `9a1fc434-...` com fonte `7b18ca51-...`.
- 2026-06-18: nota `2026-06-18-aprenda-a-criar-infograficos-profissionais-com-ia-usando-1-prompt.md` gerada via NotebookLM a partir do vídeo `551vtXQksRE` e salva em `03-conhecimento/youtube/`. NotebookLM: `2a7fbd41-...` com fonte `c80a3ca2-...`.
- 2026-06-18: skill MoA `autonomous-ai-agents` criada como orquestrador de agentes. Agentes incluídos: `codex`, `claude-code`, `opencode`, `hermes-agent`, `anthropic`, `google`, `xai`, `openrouter`, `ollama`/`lmstudio`. Documentada também em `03-conhecimento/skills/autonomous-ai-agents.md`.
- 2026-06-18: nota `limites-e-fallback-provedores.md` criada em `03-conhecimento/skills/` com ordem de preferência: `anthropic` → `openrouter` → `ollama`.
- 2026-06-18: nota `how-to-debug-scripts-in-windows-powershell-ise.md` criada em `03-conhecimento/informacoes-filtradas/ferramentas/` a partir de documentação Microsoft Learn.
- 2026-06-18: skill `yt-to-notebook` instalada e usada para converter notebook do NotebookLM sobre Segundo Cérebro com Obsidian e Claude. Nota salva em `03-conhecimento/programacao-e-ia/segundo-cerebro-completo.md`.
- 2026-06-18: regra anti-duplicacao no index: ao atualizar `index.md`, nao duplicar linhas de skills/notas; consultar lista atual antes de inserir.
- 2026-06-19: melhoria skill notebooklm-skill — adicionado export/backup de notebooks (`export-notebooks.ps1`, `Export-NBNotebook`, `Export-NBAll`). Exporta fulltext, sources, summary, history para `~/NotebookLM-Backups/`.
- 2026-06-19: skill-creator do Anthropic analisada por segurança — todos os scripts verificados (quick_validate.py, package_skill.py, utils.py, aggregate_benchmark.py, run_eval.py, run_loop.py, improve_description.py, generate_report.py). Resultado: seguro, sem malware, sem chamadas de rede suspeitas. Instalada em `D:\IA\Skill-Hermes\skill-creator/`.
- 2026-06-19: skill-creator instalada no Skill-Hermes com todos os scripts e README. Adicionada na tabela de skills do repositório.
- 2026-06-19: criador-de-skills (antigo skill-creator) renomeada para português. Todos os arquivos atualizados: SKILL.md, README.md, evals.json.
- 2026-06-19: criado conjunto de 200 testes para evals do skill-creator em `D:\IA\Skill-Hermes\skill-creator\evals\evals.json`. Testes cobrem: decisões, capturas, projetos, conhecimento, skills, preferências, referências, documentação, debugging, infraestrutura, segurança e SRE.
- 2026-06-18: regra permanente para skills/comandos/estruturas mais estáveis: arquivos elencados em `index.md` e READMEs devem seguir uma ordem canônica; quando for atualizar listas/tabelas, primeiro ler o arquivo atual inteiro e editar com base na realidade do disco, para evitar remendo. Ação anti-repetição passa a ser padrão para todo update.
- 2026-06-18: wikilinks devem ser bidirecionais; referências quebradas são bloqueadas antes do salvamento e não entram no índice.
- 2026-06-18: antes de criar nota nova, buscar registros existentes no vault sobre o mesmo tema; se já houver conteúdo similar, consolidar no ponto único em vez de duplicar.
- 2026-06-18: frase de abertura alterada para "Segundo Cérebro ativo." no agent.md.
- 2026-06-18: audit-skills.ps1 criado — auditoria automática que varre skills e aponta faltas (SKILL.md, setup.ps1, frontmatter, wrappers, healthcheck, vault).
- 2026-06-18: corrigidos 2 críticos do audit: SKILL.md na raiz do Skill Nota-Corretagem e setup.ps1. Criados README.md, healthcheck.ps1 e integrate-vault.ps1 para skills que faltavam.
- 2026-06-19: notebooklm-skill ganhou funcionalidade de export/backup. Criados `export-notebooks.ps1` (script standalone), funções `Export-NBNotebook` e `Export-NBAll` no wrapper. Exporta fulltext, sources, summary e history para `~/NotebookLM-Backups/`.
- 2026-06-18: melhorias no vault: auditar-vault.ps1 (auditoria automática), healthcheck-vault.ps1 (frontmatter, links, consistência), processar-staging.ps1 (pipeline automatizado de staging), templates/ (captura-rapida, nota-conhecimento, projeto), READMEs em 03-conhecimento/notebooklm/ e 03-conhecimento/youtube/. Pastas vazias limpas, index.md corrigido (removida duplicata, adicionados novos paths).
- 2026-06-18: três etapas da imagem implementadas sem criar arquivos antecipadamente:
  - informações filtradas em `03-conhecimento/informacoes-filtradas/README.md`
  - skills conectadas em `03-conhecimento/skills/README.md`
  - inputs recorrentes da operação via `captura-rapida.ps1`

## Aprendizados
- Repositórios externos não devem entrar no vault; apenas notas que os descrevem e linkam.
- Links devem ser bidirecionais quando há aplicação direta entre projetos e conhecimento.
- Arquivos `.base`/`.canvas` no Obsidian são lixo e saem por ação.
