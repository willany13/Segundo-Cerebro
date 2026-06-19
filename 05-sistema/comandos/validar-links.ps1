#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Valida todos os [[wikilinks]] do vault.
.DESCRIPTION
    Varre todos os .md do Segundo Cerebro, extrai [[wikilinks]] e verifica
    se o destino existe. Resolve links como o Obsidian:
    1. Relativo ao diretorio do arquivo
    2. Relativo a raiz do vault
    Exit code: 0 se OK, 1 se houver broken links.
#>

$root = if ($args[0]) { $args[0] } else { Split-Path -Parent (Split-Path -Parent $PSScriptRoot) }
$errors = @()
$checked = 0

Get-ChildItem -Recurse -Filter "*.md" -Path $root | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw -Encoding UTF8
    $relPath = $file.Substring($root.Length + 1) -replace '\\', '/'

    [regex]::Matches($content, '\[\[([^\]]+?)(?:\|[^\]]+)?\]\]') | ForEach-Object {
        $link = $_.Groups[1].Value.Trim()
        $checked++

        # Ignore if inside backticks (inline code / example)
        $fullMatch = $_.Value
        $beforeMatch = $content.Substring(0, $_.Index)
        $backtickBefore = ($beforeMatch.ToCharArray() | Where-Object { $_ -eq '`' } | Measure-Object).Count
        if ($backtickBefore % 2 -eq 1) { return }

        # Ignore literal examples in docs ([[wikilink]], [[link]], [[placeholder]])
        if ($link -in 'wikilink', 'link', 'placeholder', 'link para projeto relacionado', 'link para outra nota de conhecimento', 'link para conhecimento', 'caminho/para/arquivo.md') {
            return
        }

        # Warn on ../ external links (should be file:///)
        if ($link -match '^\.\.') {
            $testPath = Join-Path (Split-Path $file -Parent) ($link -replace '/', '\')
            if (-not (Test-Path $testPath)) {
                $errors += "WARN in $relPath : " + '[[' + $link + ']]' + " - link externo nao encontrado"
            }
            return
        }

        # Resolve: try relative to file first, then vault root
        $resolved = $null
        $fileDir = Split-Path $file -Parent
        $test1 = Join-Path $fileDir ($link -replace '/', '\')
        if (Test-Path $test1) { $resolved = $test1 }

        if (-not $resolved) {
            $test2 = Join-Path $root ($link -replace '/', '\')
            if (Test-Path $test2) { $resolved = $test2 }
        }

        if (-not $resolved) {
            $errors += "BROKEN in $relPath : " + '[[' + $link + ']]'
        }
    }
}

if ($errors.Count -eq 0) {
    Write-Output "VALIDAR LINKS: $checked wikilinks verificados, 0 erros."
    exit 0
} else {
    Write-Output "VALIDAR LINKS: $checked wikilinks verificados, $($errors.Count) problema(s):"
    $errors | ForEach-Object { Write-Output "  $_" }
    exit 1
}
