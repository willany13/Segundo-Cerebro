#!/usr/bin/env python3
"""
bot-telegram.py - Bot do Telegram para capturar conteudo no Segundo Cerebro.

Uso:
  1. Crie um bot em @BotFather e pegue o TOKEN
  2. Crie um arquivo .env ou passe o token como variavel
  3. Rode: python bot-telegram.py

Comandos do bot:
  /capturar <texto>  — salva texto em staging
  /processar          — processa staging (roda processar-staging.ps1)
  /status             — mostra status do vault
  Qualquer mensagem   — vai direto pra staging como captura
  Documentos/fotos    — salvos como anexo + nota .md
"""

import os
import re
import sys
import asyncio
import logging
import subprocess
from pathlib import Path
from datetime import datetime

try:
    from telegram import Update, Document, PhotoSize
    from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
except ImportError:
    print("[BOT] Instale: pip install python-telegram-bot")
    sys.exit(1)

VAULT_ROOT = Path(__file__).resolve().parents[2]
STAGING_DIR = VAULT_ROOT / "05-sistema" / "staging"
STAGING_DIR.mkdir(parents=True, exist_ok=True)

TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "")
CHAT_ID = os.getenv("TELEGRAM_CHAT_ID", "")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def slugify(text, max_len=80):
    text = re.sub(r'[^a-zA-Z0-9\s-]', '', text)
    text = re.sub(r'\s+', '-', text.strip())
    text = re.sub(r'-+', '-', text).strip('-')
    if not text:
        text = f"telegram-{datetime.now().strftime('%H%M%S')}"
    return text[:max_len].rstrip('-')


def save_capture(texto, fonte="telegram"):
    if not texto or not texto.strip():
        return None
    texto = texto.strip()
    data = datetime.now().strftime('%Y-%m-%d')

    titulo = texto[:60] + ('...' if len(texto) > 60 else '')
    slug = slugify(titulo)
    filepath = STAGING_DIR / f"{slug}.md"

    content = f"""---
tags:
  - tipo/captura
  - fonte/telegram
data: {data}
fonte: {fonte}
---

# {titulo}

> [!abstract] Captura via Telegram
> {texto}

## Notas

"""
    filepath.write_text(content, encoding='utf-8')
    return filepath


async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "Segundo Cerebro ativo.\n\n"
        "Envie qualquer mensagem para capturar.\n"
        "/capturar <texto> — captura explicita\n"
        "/processar — processa staging\n"
        "/status — status do vault"
    )


async def capturar(update: Update, context: ContextTypes.DEFAULT_TYPE):
    texto = " ".join(context.args)
    if not texto:
        await update.message.reply_text("Uso: /capturar <texto ou URL>")
        return
    fp = save_capture(texto)
    if fp:
        await update.message.reply_text(f"Capturado: {fp.name}")
    else:
        await update.message.reply_text("Erro ao capturar.")


async def processar(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("Processando staging...")
    try:
        proc = await asyncio.create_subprocess_exec(
            "pwsh", "-NoProfile", "-File",
            str(VAULT_ROOT / "05-sistema" / "comandos" / "processar-staging.ps1"),
            "-AutoApprove",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, stderr = await proc.communicate()
        resultado = stdout.decode() if stdout else ""
        await update.message.reply_text(f"Staging processado.\n{resultado[:500]}")
    except Exception as e:
        await update.message.reply_text(f"Erro: {e}")


async def status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    staging = list(STAGING_DIR.glob("*.md"))
    staging_count = len([s for s in staging if s.parent.name != "archive"])
    vault_md = list(VAULT_ROOT.rglob("*.md"))
    await update.message.reply_text(
        f"Notas no vault: {len(vault_md)}\n"
        f"Capturas pendentes: {staging_count}\n"
        f"Staging: {STAGING_DIR}"
    )


async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    texto = update.message.text or update.message.caption or ""
    if not texto.strip():
        await update.message.reply_text("Envie um texto, URL ou documento.")
        return
    fp = save_capture(texto, fonte="telegram")
    if fp:
        await update.message.reply_text(f"Capturado em staging/{fp.name}")
    else:
        await update.message.reply_text("Erro ao capturar.")


async def handle_document(update: Update, context: ContextTypes.DEFAULT_TYPE):
    doc = update.message.document or update.message.photo[-1] if update.message.photo else None
    if not doc:
        return

    nome_arquivo = doc.file_name if hasattr(doc, 'file_name') else f"foto-{datetime.now().strftime('%H%M%S')}.jpg"
    destino = STAGING_DIR / nome_arquivo

    arquivo = await doc.get_file()
    await arquivo.download_to_drive(str(destino))
    await update.message.reply_text(f"Arquivo salvo: {destino.name}")


def main():
    if not TOKEN:
        print("[BOT] Defina TELEGRAM_BOT_TOKEN (variavel de ambiente ou .env)")
        print("[BOT] Crie um bot em @BotFather e copie o token.")
        sys.exit(1)

    app = Application.builder().token(TOKEN).build()

    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("capturar", capturar))
    app.add_handler(CommandHandler("processar", processar))
    app.add_handler(CommandHandler("status", status))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    app.add_handler(MessageHandler(filters.Document.ALL | filters.PHOTO, handle_document))

    logger.info("Bot Telegram rodando...")
    app.run_polling()


if __name__ == "__main__":
    main()
