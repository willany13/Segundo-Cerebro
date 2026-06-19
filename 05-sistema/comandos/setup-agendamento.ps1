#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Configura tarefas agendadas no Windows para execucao diaria.
    Rode UMA VEZ como Administrador para ativar.
#>

$vault = Resolve-Path "$PSScriptRoot\..\.."
$expurgar = Join-Path $PSScriptRoot "expurgar-staging.ps1"
$backup = Join-Path $PSScriptRoot "auto-backup.ps1"
$pwsh = "C:\Program Files\PowerShell\7\pwsh.exe"

if (-not (Test-Path $pwsh)) {
    $pwsh = "pwsh"
}

Write-Host "── Configurar Tarefas Agendadas ──" -ForegroundColor Cyan
Write-Host "Execute este script como Administrador UMA VEZ."
Write-Host ""

$tarefas = @(
    @{
        Name = "Cerebro-Expurgo"
        Task = "Expurgo diario do staging"
        Action = "-NoProfile -File `"$expurgar`" -Executar"
        Time = "09:00"
    },
    @{
        Name = "Cerebro-Backup"
        Task = "Backup diario do vault"
        Action = "-NoProfile -File `"$backup`""
        Time = "18:00"
    }
)

foreach ($t in $tarefas) {
    $existing = Get-ScheduledTask -TaskName $t.Name -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "  Ja existe: $($t.Name)" -ForegroundColor Yellow
        continue
    }

    $action = New-ScheduledTaskAction -Execute $pwsh -Argument $t.Action -WorkingDirectory $vault
    $trigger = New-ScheduledTaskTrigger -Daily -At $t.Time
    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -RunLevel Limited

    try {
        Register-ScheduledTask -TaskName $t.Name -Action $action -Trigger $trigger -Principal $principal -Force
        Write-Host "  Criada: $($t.Name) ($($t.Time))" -ForegroundColor Green
    } catch {
        Write-Host "  Erro ao criar $($t.Name): $_" -ForegroundColor Red
        Write-Host "  Execute como Administrador." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Para ver as tarefas: Get-ScheduledTask -TaskName Cerebro-*" -ForegroundColor Cyan
Write-Host "Para remover: Unregister-ScheduledTask -TaskName Cerebro-* -Confirm" -ForegroundColor Gray
