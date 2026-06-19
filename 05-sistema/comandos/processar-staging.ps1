#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Pipeline de staging: valida, roteia para o pilar correto e atualiza index.md.
.Uso
    pwsh processar-staging.ps1                   # modo interativo
    pwsh processar-staging.ps1 -AutoApprove      # automatico (usa em scripts)
#>

param([switch]$AutoApprove, [switch]$DryRun)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$vault = Resolve-Path "$PSScriptRoot\..\.."
$staging = Join-Path $vault "05-sistema\staging"
$archive = Join-Path $staging "archive"
$indexPath = Join-Path $vault "index.md"

if (-not (Test-Path $archive)) { New-Item -ItemType Directory -Path $archive -Force | Out-Null }

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Pipeline de Staging Inteligente       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan

$files = Get-ChildItem -Path $staging -Filter "*.md" -File | Where-Object { $_.DirectoryName -ne $archive }
if (-not $files) { Write-Host "Nada em staging." -ForegroundColor Green; exit 0 }

$aprovados = @()
$rejeitados = @()
$roteados = @()  # files that were actually moved to a pillar

foreach ($file in $files) {
    Write-Host "`n--- $($file.Name) ---" -ForegroundColor Cyan
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    $issues = @()

    # 1. Nome kebab-case
    if ($file.BaseName -match '[^a-z0-9\-]' -or $file.BaseName -match '^\s*$') {
        $issues += "Nome invalido (use kebab-case): $($file.BaseName)"
    }

    # 2. Frontmatter
    if ($content -notmatch "^---") { $issues += "Sem frontmatter YAML (---)" }

    # 3. Conteudo minimo
    if ($content.Length -lt 50) { $issues += "Conteudo muito curto (< 50 chars)" }

    # 4. Duplicidade
    $searchTerms = ($file.BaseName -replace '-', ' ').Split(' ') | Where-Object { $_.Length -gt 3 }
    $dups = @()
    foreach ($term in $searchTerms) {
        $dups += Select-String -Path "$vault\*.md", "$vault\**\*.md" -Pattern $term -SimpleMatch -ErrorAction SilentlyContinue |
            Where-Object { $_.Path -ne $file.FullName }
    }
    $uniqueDups = $dups | Select-Object -ExpandProperty Path -Unique | Select-Object -First 5

    # 5. Roteamento inteligente
    $destino = "DESCONHECIDO"
    if ($content -match '(?i)(projeto|skill\b|skill-hermes)') { $destino = "02-projetos" }
    elseif ($content -match '(?i)(conhecimento|conceito|framework|arquitetura|tutorial|guia)') { $destino = "03-conhecimento" }
    elseif ($content -match '(?i)(captura|hoje|ontem|notei|vi|li|assisti|fiz|aconteceu)') { $destino = "04-capturas" }
    elseif ($content -match '(?i)(sistema|comando|template|roteiro|agenda|staging)') { $destino = "05-sistema" }
    elseif ($content -match '(?i)(eu|perfil|objetivo|meta)') { $destino = "01-eu" }

    # Sugerir subpasta
    $subpasta = ""
    if ($destino -eq "03-conhecimento") {
        if ($content -match '(?i)(python|programacao|api|cli|framework)') { $subpasta = "programacao-e-ia" }
        elseif ($content -match '(?i)(skill|agente|hermes)') { $subpasta = "skills" }
        elseif ($content -match '(?i)(financeiro|corretagem|investimento|bolsa)') { $subpasta = "mercado-financeiro" }
        elseif ($content -match '(?i)(notebooklm|youtube|video)') { $subpasta = "youtube" }
        elseif ($content -match '(?i)(ferramenta|plugin|extensao|software)') { $subpasta = "informacoes-filtradas/ferramentas" }
    }

    # Report
    if ($issues.Count -gt 0) {
        Write-Host "  Problemas:" -ForegroundColor Red
        $issues | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
    }
    if ($uniqueDups.Count -gt 0) {
        Write-Host "  Possivel duplicata:" -ForegroundColor Yellow
        $uniqueDups | ForEach-Object {
            $rel = [System.IO.Path]::GetRelativePath($vault, $_)
            Write-Host "    - $rel" -ForegroundColor Yellow
        }
    }
    Write-Host "  Destino: $destino $subpasta" -ForegroundColor Cyan

    # Decision
    $aprovado = $false
    if ($AutoApprove -and $issues.Count -eq 0) { $aprovado = $true }
    elseif ($issues.Count -eq 0) { $aprovado = $true }

    if ($aprovado) {
        $aprovados += $file

        # Montar caminho destino no pilar
        $pilarPath = Join-Path $vault $destino
        if ($subpasta) { $pilarPath = Join-Path $pilarPath $subpasta }
        if (-not (Test-Path $pilarPath)) { New-Item -ItemType Directory -Path $pilarPath -Force | Out-Null }

        $destFile = Join-Path $pilarPath $file.Name

        if ($DryRun) {
            Write-Host "  Roteando -> $destino/$subpasta/$($file.Name)" -ForegroundColor Green
        } else {
            # Verificar se ja existe
            if (Test-Path $destFile) {
                $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
                $destFile = Join-Path $pilarPath "$($file.BaseName)-$timestamp.md"
            }
            Move-Item -Path $file.FullName -Destination $destFile -Force
            Write-Host "  Roteado para: $destino/$subpasta/$($file.Name)" -ForegroundColor Green
            $roteados += @{ Origem = $file.Name; Destino = $destFile; Pilar = $destino }
        }
    } else {
        $rejeitados += $file
        Write-Host "  Rejeitado (corrigir e tentar novamente)." -ForegroundColor Red
    }
}

# Atualizar index.md com os arquivos roteados
if ($roteados.Count -gt 0 -and -not $DryRun) {
    Write-Host "`nAtualizando index.md..." -ForegroundColor Yellow
    $indexContent = Get-Content $indexPath -Raw
    $novasLinhas = @()
    foreach ($r in $roteados) {
        $relPath = [System.IO.Path]::GetRelativePath($vault, $r.Destino).Replace('\', '/')
        $wikilink = "- [[$relPath]]"
        if ($indexContent -notmatch [regex]::Escape($wikilink)) {
            $novasLinhas += $wikilink
        }
    }
    if ($novasLinhas.Count -gt 0) {
        $linha = $novasLinhas -join "`n"
        $indexContent = $indexContent.TrimEnd() + "`n$linha`n"
        Set-Content -Path $indexPath -Value $indexContent -Encoding UTF8
        Write-Host "  $($novasLinhas.Count) arquivo(s) adicionado(s) ao index.md" -ForegroundColor Green
    }
}

# Arquivar rejeitados
if ($rejeitados.Count -gt 0) {
    Write-Host "`nArquivando rejeitados..." -ForegroundColor Yellow
    foreach ($f in $rejeitados) {
        $dest = Join-Path $archive "$($f.BaseName)-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
        Move-Item -Path $f.FullName -Destination $dest -Force
        Write-Host "  $($f.Name) -> archive/" -ForegroundColor Gray
    }
}

Write-Host "`nConcluido. Aprovados: $($aprovados.Count) | Rejeitados: $($rejeitados.Count)" -ForegroundColor Cyan
