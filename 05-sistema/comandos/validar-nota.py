#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

REQUIRED_FRONTMATTER_FIELDS = {"titulo", "fonte", "data"}
MIN_LINES = 5
ALLOWED_PREFIXES = (
    "01-eu",
    "02-projetos",
    "03-conhecimento",
    "04-capturas",
    "05-sistema",
)


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("Usage: validar_nota.py <caminho/relativo/para/nota.md>")
        return 2

    target = Path(argv[1])
    if not target.exists():
        print(f"Nota não encontrada: {target}")
        return 1

    content = target.read_text(encoding="utf-8")

    if not content.lstrip().startswith("---"):
        print("Erro: frontmatter ausente (não encontrei '---' no início).")
        return 1

    parts = content.split("---", 2)
    if len(parts) < 3:
        print("Erro: frontmatter malformado.")
        return 1

    front = parts[1]
    body = parts[2]

    fields = {m.group(1).strip() for m in re.finditer(r"^\s*([A-Za-z0-9_-]+)\s*:", front, flags=re.M)}
    missing = REQUIRED_FRONTMATTER_FIELDS - fields
    if missing:
        print(f"Erro: campos faltando no frontmatter: {', '.join(sorted(missing))}")
        return 1

    lines = body.splitlines()
    real_lines = [ln.rstrip() for ln in lines if ln.strip()]
    if len(real_lines) < MIN_LINES:
        print(f"Erro: nota curta demais ({len(real_lines)} linhas não vazias; mínimo {MIN_LINES}).")
        return 1

    if not re.search(r"^#\s+.+", body, flags=re.M):
        print("Erro: heading principal `# ...` ausente no corpo.")
        return 1

    # Relative path should at least start with an allowed pillar name.
    try:
        rel = target.relative_to(Path.cwd())
        if not any(str(rel).startswith(prefix) for prefix in ALLOWED_PREFIXES):
            print(f"Aviso: caminho fora dos pilares esperados: {rel}")
    except ValueError:
        # relative_to can fail if target is not under cwd; soft failure only.
        pass

    print(f"Nota validada: {target}")
    print(f"- Campos obrigatórios presentes: {', '.join(sorted(REQUIRED_FRONTMATTER_FIELDS))}")
    print(f"- Linhas não vazias no corpo: {len(real_lines)}")
    print(f"- Heading principal encontrado.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
