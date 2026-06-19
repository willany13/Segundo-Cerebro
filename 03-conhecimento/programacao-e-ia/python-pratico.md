---
title: "Python prático — automação e scripts"
tags:
  - grupo/conhecimento
  - area/financeiro
  - conceito/api
  - conceito/cli
  - conceito/inteligencia-artificial
  - ferramenta/git
  - ferramenta/github
  - fluxo/captura
  - linguagem/python
---

# Python prático — automação e scripts

## Automação de arquivos

```python
import os
from pathlib import Path

vault = Path(__file__).resolve().parent.parent

# Listar .md recursivamente
for md in vault.rglob("*.md"):
    if ".git" not in md.parts:
        print(md.relative_to(vault))

# Procurar arquivos sem frontmatter
for md in vault.rglob("*.md"):
    if ".git" in md.parts:
        continue
    content = md.read_text(encoding="utf-8")
    if not content.startswith("---"):
        print(f"Sem frontmatter: {md.name}")

# Renomear em lote
pasta = vault / "04-capturas"
for f in pasta.glob("*.md"):
    if " " in f.stem:
        novo = f.stem.replace(" ", "-") + f.suffix
        f.rename(pasta / novo)
```

## Requests com retry e rate limit

```python
import time
import requests
from functools import wraps

def retry(max_tentativas=3, espera=2):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            for tentativa in range(max_tentativas):
                try:
                    return f(*args, **kwargs)
                except requests.RequestException as e:
                    if tentativa == max_tentativas - 1:
                        raise
                    time.sleep(espera * (tentativa + 1))
            return None
        return wrapper
    return decorator

@retry(max_tentativas=3, espera=2)
def buscar_api(url, headers=None):
    r = requests.get(url, headers=headers, timeout=10)
    r.raise_for_status()
    return r.json()

# Uso
dados = buscar_api("https://api.github.com/repos/willany13/Segundo-Cerebro")
print(dados["description"])
```

## Processar PDF (notas de corretagem)

```python
import pdfplumber
import csv

with pdfplumber.open("nota-corretagem.pdf") as pdf:
    for pagina in pdf.pages:
        texto = pagina.extract_text()
        tabelas = pagina.extract_tables()

        for tabela in tabelas:
            for linha in tabela:
                print(" | ".join(str(c) or "" for c in linha))
```

**Dependências:** `pip install pdfplumber requests`

## CLI com argparse

```python
import argparse

parser = argparse.ArgumentParser(description="Auditar vault")
parser.add_argument("--path", default=".", help="Caminho do vault")
parser.add_argument("--fix", action="store_true", help="Corrigir automaticamente")
parser.add_argument("--verbose", action="store_true")

args = parser.parse_args()

if args.verbose:
    print(f"Auditando: {args.path}")
if args.fix:
    print("Modo correção ativado")
```

## Template de script Python

```python
#!/usr/bin/env python3
"""nome-do-script — O que faz.

Usage:
    python nome-do-script.py --path ./vault [--fix]
"""
import argparse
import sys
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--path", required=True)
    parser.add_argument("--fix", action="store_true")
    args = parser.parse_args()

    vault = Path(args.path).resolve()
    if not vault.exists():
        print(f"❌ Caminho não existe: {vault}")
        sys.exit(1)

    erros = 0
    # ... seu código aqui ...

    sys.exit(erros)

if __name__ == "__main__":
    main()
```
