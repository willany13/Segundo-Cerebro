---
tags:
  - tipo/referencia
---

# Bot Telegram — Captura mobile

## Setup (uma vez)

1. Abra o Telegram, procure por **@BotFather**
2. Envie `/newbot`, escolha um nome (ex.: `CerebroBot`) e username (ex.: `@SeuCerebroBot`)
3. O @BotFather vai te dar um **token** (ex.: `123456:ABC-DEF1234...`)
4. Defina o token como variável de ambiente:

```powershell
$env:TELEGRAM_BOT_TOKEN = "seu-token-aqui"
```

Ou crie um arquivo `.env` na pasta `05-sistema/comandos/`:
```
TELEGRAM_BOT_TOKEN=seu-token-aqui
```

5. Inicie o bot:

```powershell
python 05-sistema/comandos/bot-telegram.py
```

O bot fica rodando em segundo plano. Para parar: Ctrl+C.

## Comandos

| Comando | O que faz |
|---|---|
| `/start` | Boas-vindas |
| `/capturar <texto>` | Salva texto/URL em staging |
| `/processar` | Processa staging (valida e arquiva) |
| `/status` | Mostra estatísticas do vault |
| *qualquer texto* | Virá captura automática |
| *foto/documento* | Salvo como anexo em staging |

## Exemplos

- Enviar `https://github.com/willany13/projeto` → URL capturada em staging
- Enviar `/capturar Decidi migrar o Hermes para Python puro` → decisão registrada
- Enviar uma foto de reunião → salva em staging + anotação
- Encaminhar mensagem de outro chat → conteúdo capturado
