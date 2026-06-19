#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Gera relatorio de revisao semanal do vault.
.Uso
    pwsh revisao-semanal.ps7
    pwsh revisao-semanal.ps1 -Dias 14  # periodo customizado
#>

param([int]$Dias = 7)

$vault = Resolve-Path "$PSScriptRoot\..\.."
Set-Location $vault

$desde = (Get-Date).AddDays(-$Dias)
$dataStr = $desde.ToString("yyyy-MM-dd")
$hoje = Get-Date -Format "yyyy-MM-dd"

Write-Host "── Revisao Semanal ($Dias dias) ──" -ForegroundColor Cyan
Write-Host ""

# 1. Git log
Write-Host "## Commits" -ForegroundColor Yellow
$commits = git log --oneline --since=$dataStr --until=$hoje 2>&1
if ($commits) { $commits } else { Write-Host "  Nenhum commit no periodo." -ForegroundColor Gray }
Write-Host ""

# 2. Notas criadas/modificadas
Write-Host "## Notas criadas/modificadas" -ForegroundColor Yellow
$notas = git log --name-only --diff-filter=AMCR --since=$dataStr --until=$hoje --pretty=format: -- "*.md" 2>&1 |
    Select-Object -Unique | Where-Object { $_ -match '\.md$' }

if ($notas) {
    $notas | ForEach-Object { Write-Host "  - $_" }
} else {
    Write-Host "  Nenhuma nota alterada." -ForegroundColor Gray
}
Write-Host ""

# 3. Staging
Write-Host "## Staging pendente" -ForegroundColor Yellow
$stagingFiles = Get-ChildItem "05-sistema\staging\*.md" -File | Where-Object { $_.DirectoryName -notmatch 'archive' }
if ($stagingFiles) {
    $stagingFiles | ForEach-Object { Write-Host "  - $($_.Name) ($($_.LastWriteTime.ToString('yyyy-MM-dd')))" }
} else {
    Write-Host "  Nenhum." -ForegroundColor Gray
}
Write-Host ""

# 4. Estatisticas
Write-Host "## Estatisticas" -ForegroundColor Yellow
$totalNotas = (Get-ChildItem -Recurse -Filter "*.md" -File).Count
$totalPastas = (Get-ChildItem -Directory -Recurse).Count
$tamanhoKB = [math]::Round(((Get-ChildItem -Recurse -Filter "*.md" -File | Measure-Object -Property Length -Sum).Sum) / 1KB, 0)
Write-Host "  Total de notas: $totalNotas"
Write-Host "  Total de pastas: $totalPastas"
Write-Host "  Tamanho total: ${tamanhoKB}KB"
Write-Host ""

# 5. Sugestoes
Write-Host "## Sugestoes" -ForegroundColor Yellow
if ($stagingFiles) { Write-Host "  - Processar staging pendente" -ForegroundColor Yellow }
Write-Host "  - Revisar notas da semana e conectar ao grafo"
Write-Host "  - Atualizar objetivos em 01-eu/ se necessario"
