# Uninstall_Green.ps1 - Complete Uninstallation for Portable PotPlayer + DmitriRender
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Continue"

Write-Host "========================================================" -ForegroundColor Yellow
Write-Host "  PotPlayer + DmitriRender 绿化版 卸载程序" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Yellow

$potDir = $PSScriptRoot
if (-not $potDir) { $potDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
$appDataDmitri = Join-Path $env:APPDATA "DmitriRender"
$lavX64 = Join-Path $potDir "LAVFilters\x64"

# 1. Stop active processes
Write-Host "[1/5] 正在关闭相关进程..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -match "PotPlayer|pcnsl|drtm" } | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Remove scheduled task
Write-Host "[2/5] 正在移除后台自动续期计划任务..." -ForegroundColor Yellow
& schtasks.exe /Delete /TN "DmitriRender_AutoReset" /F 2>$null | Out-Null
Unregister-ScheduledTask -TaskName "DmitriRender_AutoReset" -Confirm:$false -ErrorAction SilentlyContinue
Write-Host "    已彻底清理计划任务: DmitriRender_AutoReset" -ForegroundColor Green

# 3. Unregister DirectShow filters
Write-Host "[3/5] 正在反注册 DirectShow 滤镜..." -ForegroundColor Yellow
if (Test-Path "$appDataDmitri\x64\dmitriRender.dll") {
    & regsvr32.exe /u /s "$appDataDmitri\x64\dmitriRender.dll"
}
if (Test-Path "$lavX64\LAVAudio.ax") {
    & regsvr32.exe /u /s "$lavX64\LAVAudio.ax"
    & regsvr32.exe /u /s "$lavX64\LAVVideo.ax"
    & regsvr32.exe /u /s "$lavX64\LAVSplitter.ax"
}
$madDir = Join-Path $potDir "madVR"
if (Test-Path (Join-Path $madDir "madVR64.ax")) {
    Push-Location $madDir
    & regsvr32.exe /u /s "madVR.ax"
    & regsvr32.exe /u /s "madVR64.ax"
    Pop-Location
}

# 4. Remove file associations and Desktop shortcut
Write-Host "[4/5] 正在清理文件关联与桌面快捷方式..." -ForegroundColor Yellow
$desktopPath = [Environment]::GetFolderPath('Desktop')
Remove-Item -Path (Join-Path $desktopPath "PotPlayer.lnk") -Force -ErrorAction SilentlyContinue
Remove-Item -Path (Join-Path $desktopPath "PotPlayer (插帧免续期版).lnk") -Force -ErrorAction SilentlyContinue

$exts = @('mp4', 'mkv', 'avi', 'flv', 'mov', 'wmv', 'ts', 'webm', 'm4v', 'rmvb', 'mp3', 'flac', 'wav', 'aac', 'm4a', 'iso', 'vob', 'mpg', 'mpeg', '3gp')
foreach ($ext in $exts) {
    Remove-Item -Path "HKCU:\Software\Classes\PotPlayerMini64.$ext" -Recurse -Force -ErrorAction SilentlyContinue
}

# 5. Clean DmitriRender AppData and Registry
Write-Host "[5/5] 正在清理 DmitriRender 注册表与缓存..." -ForegroundColor Yellow
Remove-Item -Path "HKCU:\Software\DmitriRender" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKCU:\Software\Daum\PotPlayer64_Core" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $appDataDmitri -Recurse -Force -ErrorAction SilentlyContinue

try {
    $typeDef = @"
    using System;
    using System.Runtime.InteropServices;
    public class ShellNotifier {
        [DllImport("shell32.dll")]
        public static extern void SHChangeNotify(int wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);
    }
"@
    Add-Type -TypeDefinition $typeDef -ErrorAction SilentlyContinue
    [ShellNotifier]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)
} catch {}

Write-Host "========================================================" -ForegroundColor Green
Write-Host "  卸载完成！所有滤镜、计划任务与关联已安全清理。" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green


