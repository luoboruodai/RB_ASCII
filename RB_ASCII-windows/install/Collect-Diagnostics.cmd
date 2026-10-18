@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Collect-Diagnostics.ps1" -OutputPath "%~dp0RB_ASCII-diagnostics.txt"
pause
