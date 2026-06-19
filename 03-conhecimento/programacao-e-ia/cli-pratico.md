---
title: "CLI prático — ferramentas de linha de comando"
tags:
  - grupo/conhecimento
  - conceito/cli
  - ferramenta/git
  - linguagem/powershell
  - linguagem/python
  - linguagem/shell
---

# CLI prático — ferramentas de linha de comando

## Estrutura de um CLI em Python

```
meu-script/
├── meu_script/
│   ├── __init__.py
│   └── main.py
├── pyproject.toml
└── README.md
```

```python
# meu_script/main.py
import argparse
import sys

def main():
    parser = argparse.ArgumentParser(
        description="Ferramenta X — faz Y",
        epilog="Ex: meu-script --path . --fix"
    )
    parser.add_argument("--path", default=".", help="Caminho para processar")
    parser.add_argument("--fix", action="store_true", help="Corrigir automaticamente")
    parser.add_argument("-v", "--verbose", action="store_true")

    args = parser.parse_args()
    if args.verbose:
        print(f"Processando: {args.path}")

    erros = 0
    # ... lógica ...
    sys.exit(erros)

if __name__ == "__main__":
    main()
```

```toml
# pyproject.toml
[project]
name = "meu-script"
version = "0.1.0"

[project.scripts]
meu-script = "meu_script.main:main"
```

Depois: `pip install -e .` — e `meu-script` vira comando global.

## CLI em PowerShell

```powershell
# meu-script.ps1
param(
    [Parameter(Mandatory, HelpMessage = "Caminho do vault")]
    [string]$Path,
    [switch]$Fix,
    [switch]$Verbose
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

if (-not (Test-Path $Path)) {
    Write-Host "❌ Caminho inválido: $Path" -ForegroundColor Red
    exit 1
}

$erros = 0
# ... lógica ...
exit $erros
```

## Progresso em CLI (útil para loops longos)

```python
from tqdm import tqdm
import time

arquivos = list(Path(".").rglob("*.md"))
for f in tqdm(arquivos, desc="Auditando"):
    processar(f)
```

`pip install tqdm`

```powershell
# PowerShell progress
$arquivos = Get-ChildItem -Recurse -Filter "*.md" -File
$i = 0
foreach ($f in $arquivos) {
    $i++
    Write-Progress -Activity "Auditando" -Status "$($f.Name)" -PercentComplete ($i / $arquivos.Count * 100)
    processar $f
}
```

## Cores no terminal

```python
# Python com colorama
from colorama import Fore, Style
print(f"{Fore.GREEN}✅ Sucesso{Style.RESET_ALL}")
print(f"{Fore.RED}❌ Erro{Style.RESET_ALL}")
```

```powershell
# PowerShell nativo
Write-Host "✅ Sucesso" -ForegroundColor Green
Write-Host "❌ Erro" -ForegroundColor Red
Write-Host "⚠️  Aviso" -ForegroundColor Yellow
```

## Template pronto (Python + PowerShell híbrido)

Quando um script precisa rodar nos dois ambientes:

```python
"""Script híbrido PowerShell/Python"""
import os, sys
VAULT = os.environ.get("VAULT_PATH", os.path.dirname(os.path.abspath(__file__)))

def audit():
    erros = 0
    for root, dirs, files in os.walk(VAULT):
        for f in files:
            if f.endswith(".md") and ".git" not in root:
                path = os.path.join(root, f)
                with open(path, "r", encoding="utf-8") as fh:
                    first = fh.readline()
                    if not first.startswith("---"):
                        print(f"⚠️  Sem frontmatter: {os.path.relpath(path, VAULT)}")
                        erros += 1
    return erros

if __name__ == "__main__":
    sys.exit(audit())
```
