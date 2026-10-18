@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Load-Smoke.ps1" "%~dp0RB_ASCII.aex"
pause
