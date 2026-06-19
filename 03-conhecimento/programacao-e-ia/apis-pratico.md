---
title: "APIs prático — REST, autenticação, rate limit"
tags:
  - grupo/conhecimento
  - conceito/api
  - conceito/inteligencia-artificial
  - ferramenta/git
  - ferramenta/github
  - linguagem/powershell
  - linguagem/python
  - linguagem/shell
---

# APIs prático — REST, autenticação, rate limit

## Template de requisição com tratamento de erro

```python
import requests

def get_json(url, headers=None, timeout=15):
    try:
        r = requests.get(url, headers=headers, timeout=timeout)
        r.raise_for_status()
        return r.json()
    except requests.Timeout:
        print(f"⏱ Timeout: {url}")
    except requests.HTTPError as e:
        print(f"❌ HTTP {e.response.status_code}: {url}")
    except requests.ConnectionError:
        print(f"🔌 Sem conexão: {url}")
    return None
```

## Autenticação por token

```python
# Via header
headers = {
    "Authorization": f"Bearer {os.environ['GITHUB_TOKEN']}",
    "Accept": "application/vnd.github.v3+json"
}

# Ou via parâmetro
params = {"api_key": "sua-chave", "format": "json"}
```

**Nunca** coloque token no código. Use variável de ambiente (`$env:TOKEN` no PowerShell, `os.environ` no Python).

## Rate limiting — respeito ao servidor

```python
import time

def rate_limited_request(url, headers, min_interval=1.0):
    """No mínimo 1 segundo entre requisições."""
    time.sleep(min_interval)
    r = requests.get(url, headers=headers)
    r.raise_for_status()

    # Respeitar headers de rate limit (se existirem)
    remaining = int(r.headers.get("X-RateLimit-Remaining", 1))
    if remaining == 0:
        reset = int(r.headers.get("X-RateLimit-Reset", time.time() + 60))
        espera = max(reset - time.time(), 0) + 1
        print(f"⏳ Rate limit excedido. Esperando {espera}s...")
        time.sleep(espera)

    return r.json()
```

## GitHub API — exemplos reais

```python
import os, requests

GITHUB_TOKEN = os.environ["GITHUB_TOKEN"]
HEADERS = {"Authorization": f"Bearer {GITHUB_TOKEN}"}
BASE = "https://api.github.com"

# Listar repositórios do usuário
repos = get_json(f"{BASE}/users/willany13/repos")
for r in repos:
    print(f"  {r['name']} — {r['description'] or 'sem descrição'}")

# Criar issue
issue = requests.post(f"{BASE}/repos/willany13/Segundo-Cerebro/issues",
    json={"title": "Automação", "body": "Criada via script"},
    headers=HEADERS)
```

## Endpoints úteis do GitHub API

| Endpoint | Uso |
|----------|-----|
| `GET /repos/{owner}/{repo}` | Info do repositório |
| `GET /repos/{owner}/{repo}/contents/{path}` | Listar arquivos |
| `POST /repos/{owner}/{repo}/issues` | Criar issue |
| `POST /repos/{owner}/{repo}/dispatches` | Trigger workflow |
| `GET /users/{user}/repos` | Listar repositórios |
| `POST /user/repos` | Criar repositório |

## Python vs PowerShell — escolha certa

| Tarefa | Melhor ferramenta |
|--------|-------------------|
| Manipular arquivos do vault | PowerShell (nativo Windows) |
| API calls complexas | Python (requests > Invoke-RestMethod) |
| Git hooks | PowerShell (já está no ambiente) |
| Processamento de PDF | Python (pdfplumber) |
| Automação rápida one-liner | PowerShell |
| Script reutilizável/complexo | Python |
