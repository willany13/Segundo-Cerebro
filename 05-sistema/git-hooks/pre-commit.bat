@echo off
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\05-sistema\comandos\auditar-vault.ps1"
exit /b %ERRORLEVEL%
