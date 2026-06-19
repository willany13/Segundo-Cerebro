#!/usr/bin/env python3
"""
vigia-clipboard.py - Monitor de clipboard + atalho Ctrl+Shift+C.

Uso:
  python vigia-clipboard.py           # modo foreground
  python vigia-clipboard.py --tray    # com bandeja (se pystray instalado)

Captura automatica:
  - URLs copiadas sao salvas em staging/
  - Ctrl+Shift+C: captura o que estiver na clipboard
"""

import os
import re
import sys
import time
import threading
import subprocess
from pathlib import Path
from datetime import datetime

import pyperclip
from pynput import keyboard

VAULT_ROOT = Path(__file__).resolve().parents[2]
STAGING_DIR = VAULT_ROOT / "05-sistema" / "staging"
STAGING_DIR.mkdir(parents=True, exist_ok=True)

_last_clip = ""
_running = True

try:
    import pystray
    from PIL import Image, ImageDraw
    _HAS_TRAY = True
except ImportError:
    _HAS_TRAY = False


def slugify(text, max_len=80):
    text = re.sub(r'[^a-zA-Z0-9\s-]', '', text)
    text = re.sub(r'\s+', '-', text.strip())
    text = re.sub(r'-+', '-', text)
    text = text.strip('-')
    if not text:
        text = "captura-" + datetime.now().strftime('%H%M%S')
    return text[:max_len].rstrip('-')


def save_capture(texto, fonte=None):
    if not texto or not texto.strip():
        return None
    texto = texto.strip()
    fonte = fonte or (texto if re.match(r'https?://', texto) else 'captura manual')

    titulo = texto
    if re.match(r'https?://', texto):
        m = re.search(r'https?://(.+?)(?:/|$)', texto)
        if m:
            titulo = m.group(1)
    elif len(texto) > 60:
        titulo = texto[:57] + '...'

    slug = slugify(titulo)
    filepath = STAGING_DIR / f"{slug}.md"
    data = datetime.now().strftime('%Y-%m-%d')

    content = f"""---
tags:
  - tipo/captura
data: {data}
fonte: {fonte}
---

# {titulo}

> [!abstract] TL;DR
> {texto}

## Pontos principais
- 

## Contexto
{fonte}

## Aplicação

"""
    filepath.write_text(content, encoding='utf-8')
    return filepath


def on_activate():
    clip = pyperclip.paste()
    if clip and len(clip) > 5:
        fp = save_capture(clip)
        if fp:
            notify(f"Capturado: {fp.name}")
    else:
        print("[VIGIA] Clipboard vazio ou muito curto.")


def notify(msg):
    try:
        subprocess.run(
            ["powershell", "-NoProfile", "-Command",
             f"New-BurntToastNotification -Text '{msg}'"],
            capture_output=True, timeout=5)
    except Exception:
        pass


def check_clipboard():
    global _last_clip
    try:
        current = pyperclip.paste()
        if current and current != _last_clip:
            _last_clip = current
            if re.match(r'https?://\S+', current):
                fp = save_capture(current, fonte=current)
                if fp:
                    print(f"[VIGIA] URL capturada: {fp.name}")
                    notify(f"URL capturada: {fp.name}")
    except Exception:
        pass


def clipboard_poll(interval=2):
    while _running:
        check_clipboard()
        time.sleep(interval)


def run_tray():
    img = Image.new('RGB', (16, 16), (0, 120, 215))
    draw = ImageDraw.Draw(img)
    draw.rectangle([2, 2, 14, 14], fill=(255, 255, 255))
    draw.text((4, 2), "C", fill=(0, 120, 215))

    def on_quit(icon, item):
        global _running
        _running = False
        icon.stop()

    menu = pystray.Menu(
        pystray.MenuItem("Capturar (Ctrl+Shift+C)", lambda: on_activate()),
        pystray.MenuItem("Sair", on_quit)
    )
    icon = pystray.Icon("vigia-cerebro", img, "Vigia Cerebro", menu)
    icon.run()


def on_press(key):
    try:
        hotkey.press(key)
    except AttributeError:
        pass


def on_release(key):
    try:
        hotkey.release(key)
    except AttributeError:
        pass


if __name__ == "__main__":
    use_tray = '--tray' in sys.argv

    print("=" * 50)
    print("  VIGIA CEREBRO")
    print(f"  Monitorando: {STAGING_DIR}")
    print("  Ctrl+Shift+C: captura rapida")
    print("=" * 50)

    hotkey = keyboard.HotKey(
        keyboard.HotKey.parse('<ctrl>+<shift>+c'),
        on_activate
    )

    threading.Thread(target=clipboard_poll, daemon=True).start()

    if use_tray and _HAS_TRAY:
        threading.Thread(target=run_tray, daemon=True).start()

    with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
        listener.join()
