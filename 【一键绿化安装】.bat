@echo off
setlocal
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cls
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install_Green.ps1"
echo.
pause
