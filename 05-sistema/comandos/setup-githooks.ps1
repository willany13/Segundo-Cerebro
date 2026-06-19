#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Instala os git hooks do vault.
.DESCRIPTION
    Configura o git para usar .githooks/ como diretorio de hooks.
    Rode uma vez por clone.
#>

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$hooksDir = Join-Path $root ".githooks"

if (-not (Test-Path $hooksDir)) {
    Write-Error "Diretorio .githooks nao encontrado em $hooksDir"
    exit 1
}

git -C $root config core.hooksPath ".githooks"

if ($LASTEXITCODE -eq 0) {
    Write-Output "Git hooks configurados: $hooksDir"
} else {
    Write-Error "Falha ao configurar git hooks"
    exit 1
}
