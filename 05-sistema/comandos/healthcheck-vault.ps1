#!/usr/bin/env pwsh
# healthcheck-vault.ps1 — Valida saúde do vault: frontmatter, links, consistência.
# Uso: pwsh healthcheck-vault.ps1
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$vault = Resolve-Path "$PSScriptRoot\..\.."
Set-Location $vault

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Healthcheck do Segundo Cérebro       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$allOk = $true

# ─── 1. Arquivos críticos existem ───
Write-Host "── 1. Arquivos críticos ──" -ForegroundColor Yellow
$criticos = @(
    "CLAUDE.md",
    "index.md",
    "05-sistema/agent.md",
    "05-sistema/memory.md",
    "05-sistema/roteamento.md",
    "01-eu/perfil.md"
)
foreach ($c in $criticos) {
    $path = "$vault\$c"
    if (Test-Path $path) { Write-Host "  ✅ $c" -ForegroundColor Green }
    else { Write-Host "  ❌ $c — FALTANDO" -ForegroundColor Red; $allOk = $false }
}
Write-Host ""

# ─── 2. Frontmatter YAML ───
Write-Host "── 2. Frontmatter YAML ──" -ForegroundColor Yellow
$semFrontmatter = Get-ChildItem -Recurse -Filter "*.md" -File | Where-Object {
    $_.FullName -notmatch '\\\.git\\' -and
    $_.Name -notin @('CLAUDE.md') -and
    $_.DirectoryName -notmatch '\\staging\\'
} | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -and -not $content.StartsWith("---")) {
        $rel = [System.IO.Path]::GetRelativePath($vault, $_.FullName)
        Write-Host "  ⚠️  Sem frontmatter: $rel" -ForegroundColor Yellow
        $_
    }
}
if (-not $semFrontmatter) { Write-Host "  ✅ Todas com frontmatter" -ForegroundColor Green }
Write-Host ""

# ─── 3. Consistência memory.md vs capturas ───
Write-Host "── 3. Memory vs Capturas ──" -ForegroundColor Yellow
$memory = Get-Content "$vault\05-sistema\memory.md" -Raw
$capturas = Get-ChildItem -Path "$vault\04-capturas" -Filter "*.md" | ForEach-Object {
    $_.BaseName
}
$memoryData = [regex]::Matches($memory, '(\d{4}-\d{2}-\d{2})') | ForEach-Object { $_.Value } | Sort-Object -Unique
foreach ($d in $memoryData) {
    if ($d -notin $capturas -and $d -ne (Get-Date -Format "yyyy-MM-dd")) {
        Write-Host "  ⚠️  $d em memory.md mas sem captura correspondente" -ForegroundColor Yellow
    }
}
foreach ($c in $capturas) {
    if ($c -notin $memoryData) {
        Write-Host "  ℹ️  $c em capturas mas sem entrada em memory.md" -ForegroundColor DarkGray
    }
}
Write-Host "  ✅ Consistência verificada" -ForegroundColor Green
Write-Host ""

# ─── 4. Links entre projetos e conhecimento ───
Write-Host "── 4. Links bidirecionais ──" -ForegroundColor Yellow
$projetos = Get-ChildItem -Path "$vault\02-projetos" -Filter "*.md" | ForEach-Object {
    $_.BaseName
}
$conhecimentos = Get-ChildItem -Path "$vault\03-conhecimento" -Recurse -Filter "README.md" | ForEach-Object {
    $_.Directory.Name
}
Write-Host "  📊 Projetos: $($projetos.Count) | Áreas de conhecimento: $($conhecimentos.Count)" -ForegroundColor Cyan
Write-Host ""

# ─── 5. READMEs com links de volta ───
Write-Host "── 5. READMEs com links de volta ──" -ForegroundColor Yellow
Get-ChildItem -Path "$vault\03-conhecimento" -Recurse -Filter "README.md" | ForEach-Object {
    $rel = [System.IO.Path]::GetRelativePath($vault, $_.FullName)
    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -notmatch 'Projetos relacionados|02-projetos') {
        Write-Host "  ⚠️  README sem link para projetos: $rel" -ForegroundColor Yellow
        $allOk = $false
    }
}
Write-Host "  ✅ Verificado" -ForegroundColor Green
Write-Host ""

# ─── 6. index.md atualizado ───
Write-Host "── 6. index.md atualizado ──" -ForegroundColor Yellow
$indexContent = Get-Content "$vault\index.md" -Raw
$indexDate = if ($indexContent -match 'Atualizado:\s*(\d{4}-\d{2}-\d{2})') { $matches[1] } else { "desconhecida" }
$today = Get-Date -Format "yyyy-MM-dd"
Write-Host "  📅 Última atualização: $indexDate" -ForegroundColor Cyan
Write-Host ""

# ─── Resumo ───
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
if ($allOk) {
    Write-Host "✅ Vault saudável." -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ Problemas encontrados." -ForegroundColor Red
    exit 1
}
