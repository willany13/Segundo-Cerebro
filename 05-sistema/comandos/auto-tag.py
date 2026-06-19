#!/usr/bin/env python3
"""
auto-tag.py - Sugere e aplica tags em notas baseado no conteudo.

Uso:
  python auto-tag.py nota.md                         # sugerir tags (só mostra)
  python auto-tag.py nota.md --apply                 # aplicar tags no arquivo
  python auto-tag.py --dir staging/                  # sugerir em todas
  python auto-tag.py --dir staging/ --apply          # aplicar em todas
  python auto-tag.py --vault                          # varrer vault inteiro (sugerir)
  python auto-tag.py --vault --apply                 # varrer vault e aplicar tags
  python auto-tag.py --vault --apply --dry-run       # simular (nao salva)
"""

import os
import re
import sys
from pathlib import Path

VAULT_ROOT = Path(__file__).resolve().parents[2]
EXCLUDE_DIRS = {".git", ".obsidian", "archive", "staging"}
EXCLUDE_FILES = {"AGENTS.md", "agent.md"}

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
    return m.group(1) if m else ""


def tags_existentes(fm):
    if not fm:
        return set()
    return set(re.findall(r'^\s*-\s+(\S+)', fm, re.MULTILINE))


def sugerir_tags(texto):
    text_lower = texto.lower()
    tags = set()

    for palavra, tag in TAG_MAP.items():
        if palavra in text_lower:
            tags.add(tag)

    h1 = re.search(r'^#\s+(.+)$', texto, re.MULTILINE)
    if h1:
        titulo = h1.group(1).lower()
        for palavra, tag in TAG_PREFIXES.items():
            if palavra in titulo:
                tags.add(tag)

    return sorted(tags)


def aplicar_tags_no_arquivo(path, dry_run=False):
    texto_original = path.read_text(encoding='utf-8', errors='replace')
    fm = extrair_frontmatter(texto_original)
    existentes = tags_existentes(fm)
    sugeridas = set(sugerir_tags(texto_original))
    novas = sugeridas - existentes

    if not novas:
        return 0  # nada a adicionar

    if dry_run:
        print(f"  [DRY-RUN] {path.name}: +{', '.join(novas)}")
        return len(novas)

    # Inserir novas tags no frontmatter, antes do fechamento ---
    linhas = texto_original.split('\n')
    # Encontrar onde inserir: depois da ultima tag ou antes do --- de fechamento
    idx_inserir = None
    dentro_fm = False
    for i, linha in enumerate(linhas):
        if linha.strip() == '---' and not dentro_fm:
            dentro_fm = True
            continue
        if linha.strip() == '---' and dentro_fm:
            idx_inserir = i
            break

    if idx_inserir is None:
        return 0

    # Inserir as novas tags antes do --- de fechamento
    for tag in sorted(novas):
        linhas.insert(idx_inserir, f"  - {tag}")
        idx_inserir += 1

    path.write_text('\n'.join(linhas), encoding='utf-8')
    print(f"  {path.name}: +{', '.join(novas)}")
    return len(novas)


def main():
    args = sys.argv[1:]
    apply = '--apply' in args
    dry_run = '--dry-run' in args
    vault_mode = '--vault' in args
    dir_mode = any(a == '--dir' for a in args)

    if vault_mode:
        if dry_run:
            print("Modo: --vault --dry-run (simulando)")
        elif apply:
            print("Modo: --vault --apply (aplicando tags em todo vault)")
        else:
            print("Modo: --vault (apenas sugerindo)")

        todos = list(VAULT_ROOT.rglob("*.md"))
        # Filtrar pastas excluidas
        arquivos = []
        for a in todos:
            rel = a.relative_to(VAULT_ROOT)
            partes = rel.parts
            if any(p in EXCLUDE_DIRS for p in partes):
                continue
            if a.parent.name == "archive":
                continue
            if a.name in EXCLUDE_FILES:
                continue
            arquivos.append(a)

        total_novas = 0
        total_arquivos = 0
        for arq in sorted(arquivos):
            tags = sugerir_tags(arq.read_text(encoding='utf-8', errors='replace'))
            fm = extrair_frontmatter(arq.read_text(encoding='utf-8', errors='replace'))
            existentes = tags_existentes(fm)
            novas = set(tags) - existentes
            if novas:
                total_arquivos += 1
                if not apply:
                    rel = arq.relative_to(VAULT_ROOT)
                    print(f"  {rel}: +{', '.join(novas)}")
                total_novas += len(novas)

            if apply and not dry_run:
                total_novas += aplicar_tags_no_arquivo(arq)

        if dry_run:
            print(f"\nResumo (dry-run): {total_arquivos} arquivos receberiam {total_novas} tags")
        elif apply:
            print(f"\nResumo: {total_arquivos} arquivos atualizados, {total_novas} tags adicionadas")
        else:
            print(f"\nResumo: {total_arquivos} arquivos com tags sugeridas, {total_novas} tags")
            print("Para aplicar: python auto-tag.py --vault --apply")

        return

    if dir_mode:
        idx = args.index('--dir') + 1
        if idx >= len(args):
            print("Especifique o diretorio: --dir <pasta>")
            sys.exit(1)
        pasta = Path(args[idx])
        arquivos = list(pasta.glob("*.md"))
    else:
        # Arquivo unico
        for a in args:
            if a.startswith('--'):
                continue
            arquivos = [Path(a)]
            break
        else:
            print("Uso: python auto-tag.py [--vault | --dir <pasta> | <arquivo>] [--apply] [--dry-run]")
            sys.exit(1)

    for arq in arquivos:
        if not arq.exists():
            print(f"Arquivo nao encontrado: {arq}")
            continue
        if apply:
            n = aplicar_tags_no_arquivo(arq, dry_run=dry_run)
            if n == 0:
                print(f"{arq.name}: ja atualizado")
        else:
            tags = sugerir_tags(arq.read_text(encoding='utf-8', errors='replace'))
            print(f"{arq.name}: {', '.join(tags) if tags else '(nenhuma)'}")


if __name__ == "__main__":
    main()
