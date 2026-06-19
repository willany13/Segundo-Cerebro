#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Busca rapida no vault por termos.
.Uso
    pwsh busca-vault.ps1 -Termo "skill hermes"
    pwsh busca-vault.ps1 -Termo "projeto" -Pilar "03-conhecimento"
    pwsh busca-vault.ps1 -Termo "api" -Contexto 3   # 3 linhas de contexto
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Termo,
    [string]$Pilar = "",
    [int]$Contexto = 1
)

$vault = Resolve-Path "$PSScriptRoot\..\.."
$searchPath = if ($Pilar) { Join-Path $vault $Pilar } else { $vault }

Write-Host "[BUSCA] Termo: '$Termo'" -ForegroundColor Cyan
if ($Pilar) { Write-Host "[BUSCA] Pilar: $Pilar" -ForegroundColor Gray }
Write-Host ""

$results = Select-String -Path "$searchPath\**\*.md" -Pattern $Termo -SimpleMatch -CaseSensitive:$false -ErrorAction SilentlyContinue

if (-not $results) {
    Write-Host "Nenhum resultado encontrado." -ForegroundColor Yellow
    exit 0
}

$grouped = $results | Group-Object Filename | Sort-Object Count -Descending

Write-Host "Encontrados em $($grouped.Count) arquivos:" -ForegroundColor Green
Write-Host ""

foreach ($group in $grouped) {
    $relPath = [System.IO.Path]::GetRelativePath($vault, $group.Name)
    $count = $group.Count
    Write-Host "  $relPath ($count ocorrencias)" -ForegroundColor Cyan

    $group.Group | Sort-Object LineNumber | Select-Object -First 3 | ForEach-Object {
        $line = $_.Line.Trim()
        $num = $_.LineNumber
        if ($line.Length -gt 120) { $line = $line.Substring(0, 117) + "..." }
        Write-Host "    L$num: $line" -ForegroundColor Gray
    }

    if ($group.Count -gt 3) {
        Write-Host "    ... e mais $($group.Count - 3) ocorrencias" -ForegroundColor DarkGray
    }
    Write-Host ""
}

Write-Host "[BUSCA] $($grouped.Count) arquivos, $($results.Count) ocorrencias" -ForegroundColor Cyan
