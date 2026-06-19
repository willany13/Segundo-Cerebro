#!/usr/bin/env python3
"""
captura-voz.py - Grava audio do microfone e transcreve para staging.

Uso:
  python captura-voz.py                  # grava 30s (padrao)
  python captura-voz.py --duracao 10     # grava 10s
  python captura-voz.py --arquivo som.wav  # transcreve arquivo existente

Dependencias: pip install sounddevice numpy openai-whisper torch
"""

import os
import sys
import tempfile
import wave
import threading
from pathlib import Path
from datetime import datetime

VAULT_ROOT = Path(__file__).resolve().parents[2]
STAGING_DIR = VAULT_ROOT / "05-sistema" / "staging"
STAGING_DIR.mkdir(parents=True, exist_ok=True)

DURACAO = 30  # segundos
RATE = 16000

_gravando = True


def transcrever(audio_path):
    try:
        import whisper
        print("[VOZ] Carregando modelo whisper (tiny)...")
        modelo = whisper.load_model("tiny")
        print("[VOZ] Transcrevendo...")
        resultado = modelo.transcribe(str(audio_path), language="pt")
        return resultado["text"].strip()
    except ImportError:
        print("[VOZ] whisper nao instalado. Use: pip install openai-whisper torch")
        return None
    except Exception as e:
        print(f"[VOZ] Erro na transcricao: {e}")
        return None


def gravar(temp_path, duracao):
    global _gravando
    try:
        import sounddevice as sd
        import numpy as np

        print(f"[VOZ] Gravando {duracao}s... (fale agora)")
        print("[VOZ] Pressione Ctrl+C para parar antes")
        audio = sd.rec(int(duracao * RATE), samplerate=RATE, channels=1, dtype='int16')
        sd.wait()

        with wave.open(str(temp_path), 'wb') as wf:
            wf.setnchannels(1)
            wf.setsampwidth(2)
            wf.setframerate(RATE)
            wf.writeframes(audio.tobytes())

        print("[VOZ] Gravacao concluida.")
        return True
    except ImportError:
        print("[VOZ] sounddevice nao instalado. Use: pip install sounddevice numpy")
        return False
    except KeyboardInterrupt:
        print("\n[VOZ] Gravacao interrompida.")
        return False
    except Exception as e:
        print(f"[VOZ] Erro na gravacao: {e}")
        return False


def salvar_captura(texto):
    if not texto:
        return

    data = datetime.now().strftime('%Y-%m-%d')
    slug = texto[:50].strip().lower()
    slug = ''.join(c for c in slug if c.isalnum() or c in ' -')
    slug = '-'.join(slug.split())[:60]

    if not slug:
        slug = f"voz-{datetime.now().strftime('%H%M%S')}"

    filepath = STAGING_DIR / f"{slug}.md"
    content = f"""---
tags:
  - tipo/captura
  - fonte/voz
data: {data}
fonte: captura por voz
---

# Transcricao - {data}

> [!abstract] Transcricao
> {texto}

## Notas

"""
    filepath.write_text(content, encoding='utf-8')
    print(f"[VOZ] Salvo em staging/{slug}.md")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--duracao", type=int, default=DURACAO)
    parser.add_argument("--arquivo", type=str)
    args = parser.parse_args()

    if args.arquivo:
        audio_path = Path(args.arquivo)
        if not audio_path.exists():
            print(f"[VOZ] Arquivo nao encontrado: {audio_path}")
            sys.exit(1)
        texto = transcrever(audio_path)
    else:
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
            temp_path = Path(f.name)

        try:
            if gravar(temp_path, args.duracao):
                texto = transcrever(temp_path)
            else:
                texto = None
        finally:
            if temp_path.exists():
                os.unlink(temp_path)

    if texto:
        print(f"\n[VOZ] Transcricao: {texto[:200]}{'...' if len(texto)>200 else ''}")
        salvar_captura(texto)
    else:
        print("[VOZ] Nada transcrito.")
