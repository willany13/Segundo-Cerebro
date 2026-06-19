@echo off
title Cerebro - Captura Rapida
cd /d "%~dp0"
set /p texto="Texto/URL: "
if "%texto%"=="" exit /b
pwsh -NoProfile -File "%~dp0captura-rapida.ps1" -Texto "%texto%"
pause
