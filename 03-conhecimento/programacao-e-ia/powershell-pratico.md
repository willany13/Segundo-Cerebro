---
title: "PowerShell prático — scripts robustos"
tags:
  - grupo/conhecimento
  - conceito/inteligencia-artificial
  - fluxo/validacao
  - linguagem/powershell
  - linguagem/shell
---

# PowerShell prático — scripts robustos

## Try/Catch (não deixe erro silencioso)

```powershell
$ErrorActionPreference = "Stop"
try {
    Get-Content "arquivo-inexistente.md" -ErrorAction Stop
} catch [System.IO.FileNotFoundException] {
    Write-Host "⚠️ Arquivo não encontrado: $($_.Exception.Message)"
} catch {
    Write-Host "❌ Erro inesperado: $_"
    exit 1
}
```

**Regra:** sempre use `-ErrorAction Stop` ou `$ErrorActionPreference = "Stop"` antes de um try/catch — PowerShell não lança exceção por padrão.

## Debug condicional

```powershell
param([switch]$Verbose)
$DebugPreference = if ($Verbose) { "Continue" } else { "SilentlyContinue" }

Write-Debug "Processando $arquivo..."
```

Uso: `pwsh script.ps1 -Verbose` liga o debug, sem ele fica silencioso.

## Logging simples

```powershell
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    $line | Out-File -FilePath "$PSScriptRoot\..\_logs\script.log" -Append -Encoding utf8
    if ($Level -eq "ERROR") { Write-Host $line -ForegroundColor Red }
    else { Write-Host $line }
}

Write-Log "Iniciando auditoria..."
Write-Log "Falha ao processar" -Level "ERROR"
```

## Script modular (dot-source)

```powershell
# lib/logging.ps1
function Write-Log { ... }

# lib/validacao.ps1
function Test-Frontmatter { ... }

# main.ps1
$lib = Join-Path $PSScriptRoot "lib"
Get-ChildItem "$lib/*.ps1" | ForEach-Object { . $_.FullName }

Write-Log "Script iniciado"
```

## Filtrar arquivos com eficiência

```powershell
# Ruim (lento em pastas grandes):
Get-ChildItem -Recurse | Where-Object { $_.Extension -eq ".md" }

# Bom (filtro nativo, 10x mais rápido):
Get-ChildItem -Recurse -Filter "*.md" -File
```

## Wildcard paths com `-LiteralPath`

```powershell
# RUIM — colchetes viram wildcard:
Get-Content "arquivo[1].md"    # interpreta [1] como grupo regex

# BOM — trata como literal:
Get-Content -LiteralPath "arquivo[1].md"
```

## Exit code padronizado

```powershell
# 0 = sucesso
# 1 = erro de validação
# 2 = erro crítico

$erros = 0
# ... validações ...
exit $erros  # trava pre-commit hook se > 0
```

## Caminhos com espaços

```powershell
# RUIM:
Set-Location "D:\Meus Documentos\Segundo Cerebro"

# BOM:
$vault = Resolve-Path "$PSScriptRoot\..\.."
Set-Location (Resolve-Path $vault)
```

## Useful one-liners

```powershell
# Listar arquivos por tamanho (decrescente)
Get-ChildItem -Recurse -File | Sort-Object Length -Descending | Select-Object Name, Length

# Buscar texto em arquivos
Select-String -Path "*.ps1" -Pattern "function\s+\w+" | Group-Object Filename

# Ver diferença entre dois arquivos
Compare-Object (Get-Content a.txt) (Get-Content b.txt)
```
