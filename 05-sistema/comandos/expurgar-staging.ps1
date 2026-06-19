#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Expurga staging: arquivos >7d vao pra archive, >30d sao candidatos a exclusao.
.Uso
    pwsh expurgar-staging.ps1          # dry-run (mostra o que faria)
    pwsh expurgar-staging.ps1 -Executar  # executa de verdade
#>

param([switch]$Executar)

$vault = Resolve-Path "$PSScriptRoot\..\.."
$staging = Join-Path $vault "05-sistema\staging"
$archive = Join-Path $staging "archive"

if (-not (Test-Path $archive)) { New-Item -ItemType Directory -Path $archive -Force | Out-Null }

$now = Get-Date
$movidos = 0
$candidatos = 0

Write-Host "── Expurgo de Staging ──" -ForegroundColor Cyan

Get-ChildItem -Path $staging -Filter "*.md" -File | Where-Object { $_.DirectoryName -ne $archive } | ForEach-Object {
    $dias = ($now - $_.LastWriteTime).Days

    if ($dias -gt 30) {
        Write-Host "  🗑️  Candidato a exclusao (>30d): $($_.Name)" -ForegroundColor Red
        $candidatos++
    } elseif ($dias -gt 7) {
        $dest = Join-Path $archive $_.Name
        Write-Host "  📦 Arquivando (>7d): $($_.Name)" -ForegroundColor Yellow
        if ($Executar) {
            Move-Item -Path $_.FullName -Destination $dest -Force
            Write-Host "     -> $dest" -ForegroundColor Gray
        }
        $movidos++
    }
}

Write-Host ""
Write-Host "Resumo: $movidos movidos para archive, $candidatos candidatos a exclusao" -ForegroundColor Cyan
if ($candidatos -gt 0 -and $Executar) {
    Write-Host "[!] Revise e exclua manualmente os candidatos >30d." -ForegroundColor Red
}
if (-not $Executar) {
    Write-Host "[!] Modo dry-run. Use -Executar para aplicar." -ForegroundColor Yellow
}
