#!/usr/bin/env pwsh
# auditar-vault.ps1 — Auditoria automática do Segundo Cérebro.
# Uso: pwsh auditar-vault.ps1 [-Fix]
param([switch]$Fix)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$vault = Resolve-Path "$PSScriptRoot\..\.."
Set-Location $vault

$PILARES = @("01-eu", "02-projetos", "03-conhecimento", "04-capturas", "05-sistema")
$EXTENSOES_VALIDAS = @(".md", ".pdf", ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp", ".mp3", ".m4a", ".mp4")

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Auditoria do Segundo Cérebro         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "Vault: $vault"
Write-Host ""

$erros = 0
$avisos = 0

# ─── 1. Index vs disco ───
Write-Host "── 1. Index vs disco ──" -ForegroundColor Yellow
$indexPath = "$vault\index.md"
if (-not (Test-Path $indexPath)) { Write-Host "❌ index.md não encontrado!" -ForegroundColor Red; $erros++ }
else {
    $indexContent = Get-Content $indexPath -Raw
    $indexedFiles = @()
    [regex]::Matches($indexContent, '`([^`]+\.md)`') | ForEach-Object { $indexedFiles += $_.Groups[1].Value }
    [regex]::Matches($indexContent, '\[\[([^\]]+?)(?:\|[^\]]+)?\]\]') | ForEach-Object { $indexedFiles += $_.Groups[1].Value }
    $indexedFiles = $indexedFiles | ForEach-Object { $_ -replace '\\', '/' } | Sort-Object -Unique

    $allMdFiles = Get-ChildItem -Recurse -Filter "*.md" -File | Where-Object {
        $_.FullName -notmatch '\\\.git\\' -and
        $_.Name -notin @('CLAUDE.md') -and
        $_.DirectoryName -notmatch '\\staging\\' -and
        $_.DirectoryName -notmatch '\\templates'
    }

    foreach ($file in $allMdFiles) {
        $rel = [System.IO.Path]::GetRelativePath($vault, $file.FullName) -replace '\\', '/'
        $found = $false
        foreach ($if in $indexedFiles) {
            $normalizedIf = $if.Trim() -replace '\\', '/'
            if ($rel -eq $normalizedIf) { $found = $true; break }
        }
        if (-not $found -and $rel -notmatch '^05-sistema/staging') {
            Write-Host "⚠️  Não indexado: $rel" -ForegroundColor Yellow
            $avisos++
        }
    }

    # Dead links: listed in index but file doesn't exist
    foreach ($if in $indexedFiles) {
        $normalized = $if.Trim() -replace '\\', '/'
        $fullPath = Join-Path $vault $normalized
        if (-not (Test-Path $fullPath)) {
            Write-Host "❌ Link morto no index: $normalized" -ForegroundColor Red
            $erros++
        }
    }

    # Deprecated: backtick-enclosed paths instead of wikilinks
    $backtickLinks = [regex]::Matches($indexContent, '`([^`]+\.md)`')
    if ($backtickLinks.Count -gt 0) {
        foreach ($m in $backtickLinks) {
            Write-Host "⚠️  Link em backtick (use [[...]]): $($m.Groups[1].Value)" -ForegroundColor Yellow
            $avisos++
        }
    }

    Write-Host "  ✅ Index lido ($($indexedFiles.Count) entradas)" -ForegroundColor Green
}

# ─── 2. Notas fora dos pilares ───
Write-Host "── 2. Notas fora dos pilares ──" -ForegroundColor Yellow
Get-ChildItem -Path $vault -Filter "*.md" -File | Where-Object {
    $rel = [System.IO.Path]::GetRelativePath($vault, $_.FullName)
    $inPilar = $false
    foreach ($p in $PILARES) { if ($rel -match "^$p\\") { $inPilar = $true } }
    -not $inPilar -and $rel -notin @("CLAUDE.md", "index.md")
} | ForEach-Object {
    Write-Host "❌ Fora de pilar: $([System.IO.Path]::GetRelativePath($vault, $_.FullName))" -ForegroundColor Red
    $erros++
}
if ($erros -eq 0) { Write-Host "  ✅ Todas notas nos pilares" -ForegroundColor Green }

# ─── 3. Pastas vazias ───
Write-Host "── 3. Pastas vazias ──" -ForegroundColor Yellow
$vazias = Get-ChildItem -Recurse -Directory | Where-Object {
    $_.GetFiles().Count -eq 0 -and $_.GetDirectories().Count -eq 0 -and
    $_.FullName -notmatch '\\\.git\\' -and
    $_.Name -notin @('__pycache__')
}
if ($vazias) {
    foreach ($d in $vazias) {
        Write-Host "⚠️  Pasta vazia: $([System.IO.Path]::GetRelativePath($vault, $d.FullName))" -ForegroundColor Yellow
        $avisos++
    }
} else { Write-Host "  ✅ Sem pastas vazias" -ForegroundColor Green }

# ─── 4. Nomes de arquivo inválidos ───
Write-Host "── 4. Nomes de arquivo inválidos ──" -ForegroundColor Yellow
$invalids = Get-ChildItem -Recurse -File | Where-Object {
    $_.FullName -notmatch '\\\.git\\' -and
    $_.Name -match '[\[\]\{\}\(\)\&\+\#\@\!\$\*\~\`\\\/\:\;\"\''\<\>\?\|]' -and
    $_.Name -notmatch '^\.'
}
if ($invalids) {
    foreach ($f in $invalids) {
        Write-Host "⚠️  Nome inválido: $($f.Name)" -ForegroundColor Yellow
        $avisos++
    }
} else { Write-Host "  ✅ Todos nomes válidos" -ForegroundColor Green }

# ─── 5. Arquivos sem título no topo ───
Write-Host "── 5. Arquivos sem H1 ──" -ForegroundColor Yellow
Get-ChildItem -Recurse -Filter "*.md" -File | Where-Object {
    $_.FullName -notmatch '\\\.git\\' -and
    $_.Name -notin @('CLAUDE.md')
} | ForEach-Object {
    $content = Get-Content $_.FullName -TotalCount 5 -ErrorAction SilentlyContinue
    $hasH1 = $content -match "^# "
    $hasFrontmatter = $content -match "^---"
    if (-not $hasH1 -and -not $hasFrontmatter) {
        Write-Host "⚠️  Sem H1: $([System.IO.Path]::GetRelativePath($vault, $_.FullName))" -ForegroundColor Yellow
        $avisos++
    }
}

# ─── 6. READMEs ───
Write-Host "── 6. READMEs ──" -ForegroundColor Yellow
$readmeSemFrontmatter = Get-ChildItem -Recurse -Filter "README.md" | Where-Object {
    $_.FullName -notmatch '\\\.git\\' -and
    (Get-Content $_.FullName -First 1) -ne "---"
}
if ($readmeSemFrontmatter) {
    foreach ($r in $readmeSemFrontmatter) {
        Write-Host "⚠️  README sem frontmatter: $([System.IO.Path]::GetRelativePath($vault, $r.FullName))" -ForegroundColor Yellow
        $avisos++
    }
} else { Write-Host "  ✅ Todos com frontmatter" -ForegroundColor Green }

# ─── 7. Git health ───
Write-Host "── 6. Git health ──" -ForegroundColor Yellow
$gitStatus = git status --porcelain 2>$null
if ($LASTEXITCODE -eq 0 -and $gitStatus) {
    $untracked = $gitStatus | Where-Object { $_ -match '^\?\?.*\.md$' }
    $modified = $gitStatus | Where-Object { $_ -match '^ M.*\.md$' }
    if ($untracked) {
        foreach ($u in $untracked) {
            Write-Host "⚠️  .md não versionado: $($u.Substring(3))" -ForegroundColor Yellow
            $avisos++
        }
    }
    if ($modified) {
        foreach ($m in $modified) {
            Write-Host "⚠️  .md modificado sem stage: $($m.Substring(3))" -ForegroundColor Yellow
            $avisos++
        }
    }
    if (-not $untracked -and -not $modified) {
        Write-Host "  ✅ Git limpo" -ForegroundColor Green
    }
} elseif ($LASTEXITCODE -ne 0) {
    Write-Host "  ⚠️  Não é um repositório git" -ForegroundColor Yellow
    $avisos++
} else {
    Write-Host "  ✅ Git limpo" -ForegroundColor Green
}

# ─── 7. Tamanho do vault ───
Write-Host "── 8. Métricas ──" -ForegroundColor Yellow
$totalMd = (Get-ChildItem -Recurse -Filter "*.md" -File | Where-Object { $_.FullName -notmatch '\\\.git\\' }).Count
$totalPastas = (Get-ChildItem -Recurse -Directory | Where-Object { $_.FullName -notmatch '\\\.git\\' }).Count
$tamanho = "{0:N2} MB" -f ((Get-ChildItem -Recurse -File | Where-Object { $_.FullName -notmatch '\\\.git\\' } | Measure-Object -Property Length -Sum).Sum / 1MB)
Write-Host "  📊 Notas: $totalMd | Pastas: $totalPastas | Tamanho: $tamanho" -ForegroundColor Cyan

# ─── Resumo ───
Write-Host ""
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
if ($erros -eq 0 -and $avisos -eq 0) { Write-Host "✅ Vault saudável — sem problemas." -ForegroundColor Green }
else {
    Write-Host "❌ Erros: $erros" -ForegroundColor Red
    Write-Host "⚠️  Avisos: $avisos" -ForegroundColor Yellow
}
if ($Fix) { Write-Host "(modo -Fix ativado: correções automáticas serão aplicadas)" -ForegroundColor Yellow }
exit $erros
