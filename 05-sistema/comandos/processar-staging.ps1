#!/usr/bin/env pwsh
# processar-staging.ps1 — Pipeline automatizado de staging: valida e move.
# Uso: pwsh processar-staging.ps1 [-AutoApprove]
param([switch]$AutoApprove)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$vault = Resolve-Path "$PSScriptRoot\..\.."
$staging = "$vault\05-sistema\staging"
$archive = "$staging\archive"
$roteamento = "$vault\05-sistema\roteamento.md"

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Pipeline de Staging                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Discover staging files
$files = Get-ChildItem -Path $staging -Filter "*.md" -File | Where-Object { $_.DirectoryName -ne $archive }
if (-not $files) { Write-Host "✅ Nada em staging para processar." -ForegroundColor Green; exit 0 }

Write-Host "Arquivos em staging:" -ForegroundColor Yellow
foreach ($f in $files) { Write-Host "  📄 $($f.Name)" }
Write-Host ""

$aprovados = @()
$rejeitados = @()

foreach ($file in $files) {
    Write-Host "──────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  Analisando: $($file.Name)" -ForegroundColor Cyan
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    $issues = @()

    # 1. Check kebab-case
    if ($file.BaseName -match '[^a-z0-9\-]' -or $file.BaseName -match '^\s*$') {
        $issues += "Nome inválido (use kebab-case): $($file.BaseName)"
    }

    # 2. Check frontmatter
    if ($content -notmatch "^---") {
        $issues += "Sem frontmatter YAML (---)"
    }

    # 3. Check for abstract/empty
    if ($content -match '^\s*$' -or $content.Length -lt 50) {
        $issues += "Conteúdo muito curto (< 50 chars)"
    }

    # 4. Duplicate check in vault
    $searchTerms = ($file.BaseName -replace '-', ' ').Split(' ') | Where-Object { $_.Length -gt 3 }
    $duplicates = @()
    foreach ($term in $searchTerms) {
        $duplicates += Select-String -Path "$vault\*.md", "$vault\**\*.md" -Pattern $term -SimpleMatch -ErrorAction SilentlyContinue |
            Where-Object { $_.Path -ne $file.FullName }
    }
    $uniqueDups = $duplicates | Select-Object -ExpandProperty Path -Unique | Select-Object -First 5

    # 5. Auto-route detection
    $destino = "DESCONHECIDO"
    if ($content -match '(?i)(projeto|skill|sistema)') { $destino = "02-projetos" }
    elseif ($content -match '(?i)(conhecimento|conceito|framework|arquitetura)') { $destino = "03-conhecimento" }
    elseif ($content -match '(?i)(captura|hoje|ontem|notei|vi|li|assisti)') { $destino = "04-capturas" }
    elseif ($content -match '(?i)(roteiro|agenda|sistema|comando)') { $destino = "05-sistema" }

    # Report
    if ($issues.Count -gt 0) {
        Write-Host "  ❌ Problemas:" -ForegroundColor Red
        foreach ($i in $issues) { Write-Host "     - $i" -ForegroundColor Red }
    }
    if ($uniqueDups.Count -gt 0) {
        Write-Host "  ⚠️  Possível duplicata com:" -ForegroundColor Yellow
        foreach ($d in $uniqueDups) {
            $rel = [System.IO.Path]::GetRelativePath($vault, $d)
            Write-Host "     - $rel" -ForegroundColor Yellow
        }
    }
    Write-Host "  🏷️  Destino sugerido: $destino" -ForegroundColor Cyan

    # Decision
    if ($AutoApprove -and $issues.Count -eq 0) {
        $aprovados += $file
        Write-Host "  ✅ Aprovado automaticamente." -ForegroundColor Green
    } elseif ($issues.Count -gt 0) {
        $rejeitados += $file
        Write-Host "  ❌ Rejeitado (corrija antes de aprovar)." -ForegroundColor Red
    } else {
        $aprovados += $file
        Write-Host "  ✅ Aprovado." -ForegroundColor Green
    }
    Write-Host ""
}

# ─── Process approvals ───
if ($aprovados.Count -gt 0) {
    Write-Host "── Movendo aprovados ──" -ForegroundColor Yellow
    foreach ($f in $aprovados) {
        $dest = "$archive\$($f.BaseName)-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
        Move-Item -Path $f.FullName -Destination $dest -Force
        Write-Host "  📦 Arquivado: $dest" -ForegroundColor Green
    }
}

if ($rejeitados.Count -gt 0) {
    Write-Host "── Rejeitados ──" -ForegroundColor Yellow
    Write-Host "  Corrija os erros apontados e execute novamente."
    foreach ($f in $rejeitados) {
        Write-Host "  📄 $($f.Name) — corrigir manualmente" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✅ Concluído. Aprovados: $($aprovados.Count) | Rejeitados: $($rejeitados.Count)" -ForegroundColor Cyan
