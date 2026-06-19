@echo off
title Cerebro - Backup
cd /d "%~dp0"
pwsh -NoProfile -File "05-sistema\comandos\auto-backup.ps1"
pause
