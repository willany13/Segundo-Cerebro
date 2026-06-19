@echo off
title Cerebro - Processar Staging
cd /d "%~dp0"
pwsh -NoProfile -File "05-sistema\comandos\processar-staging.ps1" -AutoApprove
pause
