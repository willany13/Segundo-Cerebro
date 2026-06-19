@echo off
title Cerebro - Revisao Semanal
cd /d "%~dp0"
pwsh -NoProfile -File "05-sistema\comandos\revisao-semanal.ps1"
pause
