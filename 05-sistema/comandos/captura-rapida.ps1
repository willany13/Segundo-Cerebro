#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Captura rapida: texto/URL direto para staging.
.DESCRIPTION
    Aceita input via pipeline, parametro, ou prompt interativo.
    Gera arquivo .md em staging/ com frontmatter padrao.

    Uso:
      pwsh captura-rapida.ps1 -Texto "URL ou texto qualquer"
      pwsh captura-rapida.ps1 -Prompt                     # interactive
      "minha nota" | pwsh captura-rapida.ps1               # pipeline
#>

param(
    [Parameter(ValueFromPipeline = $true)]
    [string]$Texto,
    [switch]$Prompt
)

$vaultRoot = Resolve-Path "$PSScriptRoot\..\.."
$stagingDir = Join-Path $vaultRoot "05-sistema\staging"
$templatePath = Join-Path $vaultRoot "05-sistema\templates\captura-rapida.md"

if (-not (Test-Path $stagingDir)) { New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null }

# --- Get input ---
if ($Prompt -or -not $Texto) {
    $Texto = Read-Host "Digite o texto/URL para capturar"
}
if (-not $Texto) { Write-Host "Nada capturado." -ForegroundColor Yellow; exit 0 }

# --- Detect type ---
$fonte = if ($Texto -match 'https?://') { $Texto.Trim() } else { "captura manual" }
$titulo = if ($Texto -match '^https?://(.+?)(?:/|$)') { $matches[1] } elseif ($Texto.Length -gt 60) { $Texto.Substring(0, 57) + "..." } else { $Texto.Trim() }

# --- Clean filename ---
$slug = $titulo -replace '[^a-zA-Z0-9\s-]', '' -replace '\s+', '-' -replace '-+', '-' -replace '^-|-$', ''
if ($slug.Length -gt 80) { $slug = $slug.Substring(0, 80) }
if (-not $slug) { $slug = "captura-" + (Get-Date -Format 'HHmmss') }
$filename = "$slug.md"
$filePath = Join-Path $stagingDir $filename

# --- Build content ---
$data = Get-Date -Format 'yyyy-MM-dd'
$template = if (Test-Path $templatePath) { Get-Content $templatePath -Raw } else { "" }

$content = @"
---
tags:
  - tipo/captura
data: $data
fonte: $fonte
---

# $titulo

> [!abstract] TL;DR
> $Texto

## Pontos principais
- 

## Contexto
$fonte

## Aplicação

"@

Set-Content -Path $filePath -Value $content -Encoding UTF8
Write-Host "[CAPTURA] Salvo em staging/$filename" -ForegroundColor Green
Write-Host "[CAPTURA] Nao esqueca de processar: pwsh processar-staging.ps1" -ForegroundColor Yellow
exit 0
