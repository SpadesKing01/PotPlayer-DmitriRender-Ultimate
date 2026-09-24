@echo off
chcp 65001 >nul
cd /d "%~dp0"
title PotPlayer + DmitriRender 彻底卸载

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [提示] 正在请求管理员权限以清理滤镜和计划任务...
    powershell -Command "Start-Process cmd -ArgumentList '/c `"%~f0`"' -Verb RunAs"
    exit /b
)

echo ========================================================
echo   PotPlayer 64位 + DmitriRender 插帧 绿化版 卸载向导
echo ========================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Uninstall_Green.ps1"
echo.
pause
