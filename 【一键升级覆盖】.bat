@echo off
setlocal
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\" \"%~1\"' -Verb RunAs"
    exit /b
)

cls
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Upgrade_PotPlayer.ps1" "%~1"
echo.
pause
