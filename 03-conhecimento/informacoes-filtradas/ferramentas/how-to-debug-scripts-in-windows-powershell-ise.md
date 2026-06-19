---
titulo: How to Debug Scripts in Windows PowerShell ISE
fonte: https://learn.microsoft.com/en-us/powershell/scripting/windows-powershell/ise/how-to-debug-scripts-in-windows-powershell-ise?view=powershell-7.6
data: 2026-06-18
tags:
  - grupo/ferramentas
  - conceito/cli
  - conceito/inteligencia-artificial
  - linguagem/powershell
  - linguagem/shell
  - tipo/referencia
---

# 🔧 How to Debug Scripts in Windows PowerShell ISE

> [!abstract] TL;DR
> Documentação oficial Microsoft para depurar scripts localmente usando o **Windows PowerShell ISE** com debugging visual.
>
> Pontos principais: breakpoints de linha/variável/comando, pausar execução, inspecionar variáveis no Console Pane e retomar.

> [!info] Fonte
> **URL:** https://learn.microsoft.com/en-us/powershell/scripting/windows-powershell/ise/how-to-debug-scripts-in-windows-powershell-ise?view=powershell-7.6
> **Versão referenciada:** PowerShell 7.6 (LTS)

---

## 🧠 Conceito

- Depuração visual local no **Windows PowerShell ISE**.
- O script pausa em breakpoints para examinar estado e variáveis.
- No Console Pane você pode: inspecionar, modificar variáveis e continuar.

## 🛠️ Tipos de breakpoint

| Tipo | O que faz |
|---|---|
| **Linha** | Pausa quando a linha é atingida |
| **Variável** | Pausa quando o valor da variável muda |
| **Comando** | Pausa quando o comando/função está prestes a rodar |

> [!tip] Limitação do ISE
> Por menu/atalho, só é possível criar **line breakpoints**.
> Variable e command breakpoints são criados no Console Pane via `Set-PSBreakpoint`.

## 🔥 Atalhos e ações comuns

- **F9** → toggle line breakpoint na linha selecionada
- **F5** → continuar execução
- **Clique direito → Toggle Breakpoint** → alternativa ao F9
- Console Pane → comandos livres para inspecionar variáveis durante a pausa

## ⚙️ Workflow sugerido

1. Salvar o script `.ps1`
2. Abrir no Windows PowerShell ISE
3. Definir breakpoints com **F9**
4. Executar o script
5. Quando pausar, usar o Console Pane para:
   - ler variáveis
   - rodar comandos auxiliares
   - modificar valores em tempo de execução
6. Retomar com **F5**

## 📌 Cola rápida

| Problema | Solução no ISE |
|---|---|
| Descobrir onde o script trava | Line breakpoint + F9 |
| Verificar valor de variável em tempo real | Console Pane durante pausa |
| Mudar variável no meio da execução | Console Pane com atribuição direta |
| Parar só quando uma função rodar | `Set-PSBreakpoint -Command "NomeFuncao"` |
| Parar quando valor mudar | `Set-PSBreakpoint -Variable "NomeVar"` |

## ❌ O que não fazer

- Não depurar script não salvo: breakpoints exigem arquivo salvo.
- Não modificar estado crítico no Console Pane sem planejamento.
- Não confundir PowerShell ISE com VS Code: ISE é a interface legada, VS Code é o caminho atual recomendado pela Microsoft.

---

> [!quote] Microsoft Learn
> "This article describes how to debug scripts on a local computer by using the Windows PowerShell Integrated Scripting Environment (ISE) visual debugging features."

---

## 🔗 Links

- Documentação oficial: https://learn.microsoft.com/en-us/powershell/scripting/windows-powershell/ise/how-to-debug-scripts-in-windows-powershell-ise?view=powershell-7.6
- Tópico relacionado: Windows PowerShell ISE
