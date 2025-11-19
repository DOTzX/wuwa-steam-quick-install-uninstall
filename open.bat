@echo off
powershell -Command "Start-Process PowerShell -ArgumentList '-NoExit','-ExecutionPolicy Bypass','-File \"\"%CD%\wuwa-steam-quick-install-uninstall.ps1\"\"' -Verb RunAs"
