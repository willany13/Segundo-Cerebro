#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Pipeline completo de encerramento de sessao.
    Executa tudo em sequencia: expurgo -> backup -> validar links.
    So pergunta ao usuario se algo critico falhar.
#>

$vault = Resolve-Path "$PSScriptRoot\..\.."
$expurgar = Join-Path $PSScriptRoot "expurgar-staging.ps1"
$backup = Join-Path $PSScriptRoot "auto-backup.ps1"
$validador = Join-Path $PSScriptRoot "validar-links.ps1"

$erros = @()

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   ENCERRANDO SESSAO" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan

# 1. Expurgo
Write-Host "`n[1/3] Expurgando staging..." -ForegroundColor Yellow
& "pwsh" "-NoProfile", "-File", $expurgar, "-Executar"
if ($LASTEXITCODE -ne 0) { $erros += "Expurgo falhou" }

# 2. Backup
Write-Host "`n[2/3] Auto-backup..." -ForegroundColor Yellow
& "pwsh" "-NoProfile", "-File", $backup
if ($LASTEXITCODE -ne 0) { $erros += "Backup falhou" }

# 3. Validar links
Write-Host "`n[3/3] Validando links..." -ForegroundColor Yellow
& "pwsh" "-NoProfile", "-File", $validador
if ($LASTEXITCODE -ne 0) { $erros += "Links quebrados encontrados" }

# Resultado
Write-Host "`n═══════════════════════════════════════" -ForegroundColor Cyan
if ($erros.Count -eq 0) {
    Write-Host "   SESSAO ENCERRADA COM SUCESSO" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "   SESSAO ENCERRADA COM $($erros.Count) ERRO(S):" -ForegroundColor Red
    $erros | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
    Write-Host "═══════════════════════════════════════" -ForegroundColor Red
    exit 1
}
