@echo off
title Vigia Cerebro - Clipboard Watcher
cd /d "%~dp0"
echo Iniciando Vigia Cerebro...
start /min pythonw "%~dp0vigia-clipboard.py"
echo Vigia rodando em segundo plano. Feche pelo Gerenciador de Tarefas.
timeout /t 3 >nul
