---
titulo: "Mão na massa — padrões práticos do vault"
tags:
  - grupo/conhecimento
---

# Mão na massa — padrões práticos do vault

Código real extraído dos scripts do vault, organizado por padrão reutilizável.

## 1. Pipeline de auditoria (seções modulares)

```powershell
$erros = 0; $avisos = 0

# ─── 1. Seção ───
Write-Host "── 1. Título ──" -ForegroundColor Yellow
# validação...
if ($condicao_erro) { Write-Host "❌ erro" -ForegroundColor Red; $erros++ }
if ($condicao_aviso) { Write-Host "⚠️  aviso" -ForegroundColor Yellow; $avisos++ }

# ─── Resumo ───
Write-Host "❌ Erros: $erros" -ForegroundColor Red
Write-Host "⚠️  Avisos: $avisos" -ForegroundColor Yellow
exit $erros  # exit code = total de erros (0 = limpo)
```

**Uso no vault:** `auditar-vault.ps1` — 7 seções, cada uma independente. O exit code trava o pre-commit hook.

## 2. Pre-commit hook (gatilho automático)

```batch
@echo off
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\caminho\do\script.ps1"
exit /b %ERRORLEVEL%
```

**Regra:** o exit code do PowerShell vira exit code do batch. Se `> 0`, o `git commit` aborta.

**Configuração:** `git config core.hooksPath "05-sistema/git-hooks"`

## 3. Parâmetros com switch

```powershell
param([switch]$Fix, [switch]$AutoApprove, [string]$Path = ".")

if ($Fix) {
    # modo correção automática
}
if ($AutoApprove) {
    # pula confirmação manual
}
```

**Uso:** `pwsh script.ps1 -Fix -Path "03-conhecimento"`

## 4. Validar frontmatter YAML

```powershell
$content = Get-Content $arquivo -First 1
if ($content -ne "---") {
    Write-Host "⚠️  Sem frontmatter: $arquivo"
}
```

**Frontmatter mínimo:**
```yaml
---
titulo: Nome da Nota
tags:
  - grupo/conhecimento
---
```

## 5. Filtrar arquivos ignorando .git

```powershell
Get-ChildItem -Recurse -Filter "*.md" -File | Where-Object {
    $_.FullName -notmatch '\\\.git\\'
}
```

## 6. Caminhos relativos limpos

```powershell
$vault = Resolve-Path "$PSScriptRoot\..\.."
$rel = [System.IO.Path]::GetRelativePath($vault, $_.FullName) -replace '\\', '/'
```

**Por que:** `$PSScriptRoot` sempre resolve o caminho absoluto do diretório do script. `..\..` sobe até a raiz do vault. `-replace '\\', '/'` normaliza pra Unix (funciona no Obsidian).

## 7. Pipeline de staging (buffer → validar → rotear)

```powershell
# 1. DESCOBRIR
$arquivos = Get-ChildItem -Path "$vault\05-sistema\staging" -Filter "*.md" -File

foreach ($arquivo in $arquivos) {
    # 2. VALIDAR
    $content = Get-Content $arquivo -Raw
    if (-not $content.StartsWith("---")) {
        Write-Host "❌ Validação falhou: $arquivo"
        continue
    }

    # 3. ROTEAR (decidir destino)
    $destino = if ($content -match "tags:.*fonte/youtube") {
        "03-conhecimento/youtube/$($arquivo.Name)"
    } elseif ($content -match "tags:.*fonte/notebooklm") {
        "03-conhecimento/notebooklm/$($arquivo.Name)"
    } else {
        "03-conhecimento/informacoes-filtradas/$($arquivo.Name)"
    }

    # 4. MOVER
    Move-Item -LiteralPath $arquivo.FullName -Destination "$vault\$destino"
    Write-Host "✅ Roteado: $destino"
}
```

## 8. Expressões regulares úteis

```powershell
# Extrair wikilinks de um texto
[regex]::Matches($texto, '\[\[([^\]]+?)(?:\|[^\]]+)?\]\]') |
    ForEach-Object { $_.Groups[1].Value }

# Extrair paths em backtick
[regex]::Matches($texto, '`([^`]+\.md)`') |
    ForEach-Object { $_.Groups[1].Value }

# Extrair frontmatter title
if ($content -match '^---\s*\ntitulo:\s*(.+)\s*\n') {
    $titulo = $matches[1]
}
```

## 9. Git status automático

```powershell
$status = git status --porcelain
$untracked = $status | Where-Object { $_ -match '^\?\?.*\.md$' }
$modified  = $status | Where-Object { $_ -match '^ M.*\.md$' }

foreach ($u in $untracked) {
    Write-Host "⚠️  Não versionado: $($u.Substring(3))"
}
```

## 10. Template de skill PowerShell

```powershell
#!/usr/bin/env pwsh
# nome-da-skill.ps1 - O que faz
# Uso: pwsh nome-da-skill.ps1 [-Parametro]
param(
    [switch]$Force,
    [string]$InputPath = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$vault = Resolve-Path "$PSScriptRoot\..\.."

# ─── seu código aqui ───

Write-Host "✅ Concluído"
exit 0
```
