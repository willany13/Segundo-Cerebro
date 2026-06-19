#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Extrai texto de PDFs em staging e gera nota .md.
.Uso
    pwsh extrair-pdf.ps1                              # processa todos os PDFs em staging
    pwsh extrair-pdf.ps1 -Path "caminho/arquivo.pdf"  # PDF especifico
#>

param([string]$Path = "")

$vault = Resolve-Path "$PSScriptRoot\..\.."
$staging = Join-Path $vault "05-sistema\staging"

$pdfs = if ($Path) { Get-Item $Path -ErrorAction Stop } else { Get-ChildItem -Path $staging -Filter "*.pdf" -File }

if (-not $pdfs) { Write-Host "[PDF] Nenhum PDF encontrado." -ForegroundColor Yellow; exit 0 }

foreach ($pdf in $pdfs) {
    Write-Host "[PDF] Extraindo: $($pdf.Name)" -ForegroundColor Cyan

    $slug = $pdf.BaseName -replace '[^a-zA-Z0-9\s-]', '' -replace '\s+', '-'
    $mdPath = Join-Path $staging "$slug.md"

    $pythonCode = @"
import sys, json
try:
    import pdfplumber
    text = []
    with pdfplumber.open(r'$($pdf.FullName)') as pdf:
        for page in pdf.pages:
            t = page.extract_text()
            if t:
                text.append(t)
    print(json.dumps({'ok': True, 'text': '\n\n'.join(text), 'pages': len(pdf.pages)}))
except Exception as e:
    print(json.dumps({'ok': False, 'error': str(e)}))
"@

    $result = python -c $pythonCode 2>&1 | Out-String
    $parsed = $result | ConvertFrom-Json

    if (-not $parsed.ok) {
        Write-Host "[PDF] Erro: $($parsed.error)" -ForegroundColor Red
        continue
    }

    $data = Get-Date -Format "yyyy-MM-dd"
    $titulo = $pdf.BaseName
    $textoExtraido = $parsed.text

    if (-not $textoExtraido) {
        Write-Host "[PDF] Nenhum texto extraido (pode ser imagem)" -ForegroundColor Yellow
        $textoExtraido = "_PDF sem texto extraivel (possivelmente digitalizado)_"
    }

    $content = @"
---
tags:
  - tipo/captura
data: $data
fonte: $($pdf.Name)
paginas: $($parsed.pages)
---

# $titulo

> Extraido de: $($pdf.Name)

## Conteudo

$textoExtraido

## Notas

"@

    Set-Content -Path $mdPath -Value $content -Encoding UTF8
    Write-Host "[PDF] OK -> staging/$slug.md ($($parsed.pages) paginas)" -ForegroundColor Green
}
