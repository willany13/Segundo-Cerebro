#!/usr/bin/env python3
"""
auto-tag.py - Sugere tags para uma nota baseado no conteudo.

Uso:
  python auto-tag.py 05-sistema/staging/minha-nota.md
  python auto-tag.py --dir 05-sistema/staging/  # processa todas
"""

import os
import re
import sys
import json
from pathlib import Path

VAULT_ROOT = Path(__file__).resolve().parents[2]

# Mapa de palavras-chave -> tags
TAG_MAP = {
    "python": "linguagem/python",
    "powershell": "linguagem/powershell",
    "shell": "linguagem/shell",
    "javascript": "linguagem/javascript",
    "api": "conceito/api",
    "cli": "conceito/cli",
    "git": "ferramenta/git",
    "github": "ferramenta/github",
    "docker": "ferramenta/docker",
    "obsidian": "ferramenta/obsidian",
    "telegram": "ferramenta/telegram",
    "whisper": "ferramenta/whisper",
    "notebooklm": "ferramenta/notebooklm",
    "skill": "conceito/skill",
    "agente": "conceito/agente-ia",
    "hermes": "projeto/hermes",
    "ia": "conceito/inteligencia-artificial",
    "machine learning": "conceito/machine-learning",
    "automacao": "conceito/automacao",
    "captura": "fluxo/captura",
    "staging": "fluxo/staging",
    "backup": "fluxo/backup",
    "valida": "fluxo/validacao",
    "projeto": "tipo/projeto",
    "decisao": "tipo/decisao",
    "tutorial": "tipo/tutorial",
    "referencia": "tipo/referencia",
    "financeiro": "area/financeiro",
    "corretagem": "area/financeiro",
    "investimento": "area/financeiro",
    "programacao": "area/programacao",
    "dev": "area/programacao",
}

TAG_PREFIXES = {
    "projeto": "tipo/projeto",
    "decisao": "tipo/decisao",
    "conhecimento": "tipo/conhecimento",
    "captura": "tipo/captura",
    "tutorial": "tipo/tutorial",
}


def extrair_frontmatter(texto):
    m = re.match(r'^---\s*\n(.*?)\n---', texto, re.DOTALL)
    if m:
        return m.group(1)
    return ""


def sugerir_tags(texto):
    text_lower = texto.lower()
    tags = set()

    # Tags do mapa de palavras-chave
    for palavra, tag in TAG_MAP.items():
        if palavra in text_lower:
            tags.add(tag)

    # Detectar tipo pelo H1
    h1 = re.search(r'^#\s+(.+)$', texto, re.MULTILINE)
    if h1:
        titulo = h1.group(1).lower()
        for palavra, tag in TAG_PREFIXES.items():
            if palavra in titulo:
                tags.add(tag)

    # Tags existentes no frontmatter
    fm = extrair_frontmatter(texto)
    if fm:
        existing = re.findall(r'^\s*-\s+(\S+)', fm, re.MULTILINE)
        for e in existing:
            if e.startswith("tipo/") or e.startswith("area/") or e.startswith("ferramenta/"):
                tags.add(e)

    return sorted(tags)


def processar_arquivo(path):
    texto = path.read_text(encoding='utf-8', errors='replace')
    tags = sugerir_tags(texto)
    return tags


def main():
    if len(sys.argv) < 2:
        print("Uso: python auto-tag.py <arquivo.md>")
        print("      python auto-tag.py --dir <pasta/>")
        sys.exit(1)

    if sys.argv[1] == "--dir":
        pasta = Path(sys.argv[2])
        arquivos = list(pasta.glob("*.md"))
    else:
        arquivos = [Path(sys.argv[1])]

    for arq in arquivos:
        if not arq.exists():
            print(f"Arquivo nao encontrado: {arq}")
            continue
        tags = processar_arquivo(arq)
        print(f"{arq.name}: {', '.join(tags) if tags else '(nenhuma tag detectada)'}")


if __name__ == "__main__":
    main()
