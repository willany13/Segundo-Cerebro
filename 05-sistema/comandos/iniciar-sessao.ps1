#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Pipeline de inicio de sessao: expurga staging e verifica capturas pendentes.
    Executa automaticamente toda vez que uma sessao comeca.
#>

$vault = Resolve-Path "$PSScriptRoot\..\.."
$expurgar = Join-Path $PSScriptRoot "expurgar-staging.ps1"
$staging = Join-Path $vault "05-sistema\staging"

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   INICIANDO SESSAO" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan

# 1. Expurgo
Write-Host "`n[1/2] Expurgando staging..." -ForegroundColor Yellow
& "pwsh" "-NoProfile", "-File", $expurgar, "-Executar"

# 2. Verificar capturas pendentes
Write-Host "`n[2/2] Verificando capturas pendentes..." -ForegroundColor Yellow
$pendentes = Get-ChildItem -Path $staging -Filter "*.md" -File | Where-Object { $_.DirectoryName -notmatch 'archive' }
if ($pendentes) {
    Write-Host "   $($pendentes.Count) captura(s) pendente(s) em staging:" -ForegroundColor Yellow
    $pendentes | ForEach-Object { Write-Host "   - $($_.Name) ($($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm')))" }
    Write-Host "   Processe com: pwsh processar-staging.ps1" -ForegroundColor Gray
} else {
    Write-Host "   Nenhuma captura pendente." -ForegroundColor Green
}

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   SESSAO INICIADA" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
