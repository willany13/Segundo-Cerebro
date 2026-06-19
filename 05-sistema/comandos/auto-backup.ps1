#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Commit + push automatico do vault.
.Uso
    pwsh auto-backup.ps1                              # so commita se houver mudancas
    pwsh auto-backup.ps1 -Mensagem "feat: descricao"  # com mensagem personalizada
#>

param([string]$Mensagem = "")

$vault = Resolve-Path "$PSScriptRoot\..\.."
Set-Location $vault

$status = git status --porcelain
if (-not $status) {
    Write-Host "[BACKUP] Nada para commitar." -ForegroundColor Green
    exit 0
}

$count = ($status -split "`n").Count
$data = Get-Date -Format "yyyy-MM-dd HH:mm"
$msg = if ($Mensagem) { $Mensagem } else { "auto-backup $data ($count arquivos alterados)" }

Write-Host "[BACKUP] $count arquivos alterados" -ForegroundColor Cyan
Write-Host "[BACKUP] Commit: $msg" -ForegroundColor Gray

git add -A
git commit -m $msg

$pushResult = git push 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[BACKUP] Push OK" -ForegroundColor Green
} else {
    Write-Host "[BACKUP] Push falhou (pode ser rede): $pushResult" -ForegroundColor Yellow
}
