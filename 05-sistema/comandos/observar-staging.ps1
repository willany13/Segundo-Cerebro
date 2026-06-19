#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Observa a pasta staging e processa automaticamente ao detectar novos arquivos.
.Uso
    pwsh observar-staging.ps1                   # foreground
    start pwsh observar-staging.ps1 -Background  # background
#>

$vault = Resolve-Path "$PSScriptRoot\..\.."
$staging = Join-Path $vault "05-sistema\staging"
$processador = Join-Path $PSScriptRoot "processar-staging.ps1"

Write-Host "[OBSERVAR] Monitorando: $staging" -ForegroundColor Cyan
Write-Host "[OBSERVAR] Ctrl+C para parar" -ForegroundColor Gray

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $staging
$watcher.Filter = "*.md"
$watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::Size
$watcher.EnableRaisingEvents = $true

$onCreated = Register-ObjectEvent $watcher "Created" -Action {
    Start-Sleep -Seconds 2
    $name = $Event.SourceEventArgs.Name
    Write-Host "[OBSERVAR] Novo arquivo: $name" -ForegroundColor Green
    & "pwsh" "-NoProfile", "-File", $using:processador, "-AutoApprove"
}

try {
    Write-Host "[OBSERVAR] Aguardando arquivos..." -ForegroundColor Gray
    Wait-Event
} finally {
    Unregister-Event -SourceIdentifier $onCreated.Name -ErrorAction SilentlyContinue
    $watcher.Dispose()
}
