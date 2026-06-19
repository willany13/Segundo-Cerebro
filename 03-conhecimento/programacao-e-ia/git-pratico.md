---
title: "Git prático — fluxos e automação"
tags:
  - grupo/conhecimento
---

# Git prático — fluxos e automação

## Fluxo do vault (branch única)

```bash
git add -A
git commit -m "tipo: mensagem"
git push
```

| Tipo | Quando usar |
|------|-------------|
| `feat:` | Novo conteúdo ou funcionalidade |
| `fix:` | Correção de erro |
| `docs:` | Só documentação |
| `refactor:` | Reorganização sem mudar conteúdo |
| `chore:` | Gitignore, config, setup |

## Merge vs Rebase

```bash
# Merge — preserva histórico real (use para colaboração)
git merge feature-branch

# Rebase — histórico linear (use para limpeza local)
git rebase main
```

**Regra prática:** se só você usa o repo, rebase à vontade. Se tem colaboradores, merge.

## Pre-commit hook (o que usamos)

```batch
@echo off
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\05-sistema\comandos\auditar-vault.ps1"
exit /b %ERRORLEVEL%
```

**Config:** `git config core.hooksPath "05-sistema/git-hooks"`

## Useful one-liners

```bash
# Últimos commits com arquivos alterados
git log --name-status --oneline -5

# Quem alterou cada linha de um arquivo
git blame arquivo.md

# Desfazer último commit mantendo alterações
git reset --soft HEAD~1

# Descartar alterações não stageadas
git restore .

# Ver diff só de arquivos .md
git diff -- '*.md'

# Squash últimos 3 commits em 1
git reset --soft HEAD~3 && git commit -m "mensagem"

# Stash temporário
git stash push -m "wip" && git stash pop
```

## Git aliases úteis

```bash
git config --global alias.lg "log --oneline --graph --all --decorate"
git config --global alias.s "status -sb"
git config --global alias.df "diff --word-diff"
git config --global alias.undo "reset --soft HEAD~1"
```

Uso: `git lg` mostra o grafo bonito.

## CI/CD básico com GitHub Actions

```yaml
# .github/workflows/audit.yml
name: Audit
on: [push]
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run audit
        shell: pwsh
        run: pwsh 05-sistema/comandos/auditar-vault.ps1
```

Isso roda a auditoria automaticamente em todo push — se falhar, o commit fica marcado como ❌ no GitHub.

## .gitignore estratégico

```gitignore
# Cache local que muda sozinho
.obsidian/workspace.json
.obsidian/graph.json
.obsidian/cache/
.obsidian/plugins/
.obsidian/themes/

# Temporários
*.tmp
*.bak
Thumbs.db
.DS_Store
```
