---
tags:
  - tipo/referencia
  - conceito/cli
  - conceito/inteligencia-artificial
  - fluxo/captura
  - fluxo/staging
  - linguagem/javascript
---

# Marcador Web — Bookmarklet

Arraste o link abaixo para a barra de favoritos do navegador:

## [📥 Capturar p/ Cerebro](javascript:(function(){let%20t=document.title,u=location.href,s=getSelection()?.toString()||'';let%20txt=u+'\n'+t+'\n'+s;navigator.clipboard.writeText(txt).then(()=>{alert('[Cerebro] URL copiada! O Vigia vai capturar automaticamente.')}).catch(()=>{prompt('[Cerebro] Copie manualmente:',txt)})})())

## Como usar

1. Arraste o link **"📥 Capturar p/ Cerebro"** acima para a barra de favoritos
2. Quando estiver numa página que quiser salvar, clique no favorito
3. O título + URL + seleção vão para a área de transferência
4. O **Vigia Clipboard** detecta a URL e salva em `05-sistema/staging/`

## Código fonte (para inspecionar)

```javascript
(function() {
  let titulo = document.title;
  let url = location.href;
  let selecao = getSelection()?.toString() || '';
  let texto = url + '\n' + titulo + '\n' + selecao;

  navigator.clipboard.writeText(texto)
    .then(() => alert('[Cerebro] URL copiada! O Vigia vai capturar automaticamente.'))
    .catch(() => prompt('[Cerebro] Copie manualmente:', texto));
})();
```

## Versão simplificada (só URL)

Se preferir capturar apenas a URL:

```
javascript:navigator.clipboard.writeText(location.href).then(()=>alert('URL copiada!'))
```
