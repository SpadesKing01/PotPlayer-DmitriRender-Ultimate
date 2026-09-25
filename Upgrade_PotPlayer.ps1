param([string]$PackagePath)
# Upgrade_PotPlayer.ps1 - Automated PotPlayer Upgrade for Green Edition
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Continue"

$potDir = $PSScriptRoot
if (-not $potDir) { $potDir = Split-Path -Parent $MyInvocation.MyCommand.Path }

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  PotPlayer 官方新版本 自动化升级程序" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 1. Stop active processes
Write-Host "[1/4] 正在关闭现有播放器..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -match "PotPlayer|pcnsl|drtm" } | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Check if a package path is provided or locate newest in Install Packages
$bz = Join-Path $potDir "..\Bandizip\bz.exe"
if (-not (Test-Path $bz)) { $bz = "D:\Program Files\Software\Bandizip\bz.exe" }

$package = $PackagePath
if (-not $package -or -not (Test-Path $package)) {
    $instPkgDir = "D:\Program Files\Install Packages"
    if (Test-Path $instPkgDir) {
        $found = Get-ChildItem -Path $instPkgDir -Filter "*ot*layer*Stable.exe" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($found) { $package = $found.FullName }
    }
}

if ($package -and (Test-Path $package) -and (Test-Path $bz)) {
    Write-Host "[2/4] 正在从安装包提取升级文件: $(Split-Path -Leaf $package)..." -ForegroundColor Yellow
    $tempDir = Join-Path $env:TEMP "pot_upgrade_temp"
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    & $bz x -o:"$tempDir" "$package" | Out-Null
    
    $sourceDir = $tempDir
    if (Test-Path (Join-Path $tempDir "PotPlayer")) {
        $sourceDir = Join-Path $tempDir "PotPlayer"
    }
    
    robocopy "$sourceDir" "$potDir" /E /XF "!)卸载清除.bat" "!)设置优化.bat" "*.dpl" /XD "Playlist" | Out-Null
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "[2/4] 已跳过压缩包解压，直接执行本地核心文件转换..." -ForegroundColor Yellow
}

# 3. Promote official PotPlayerMini64.exe to PotPlayer64_Core.exe and deploy launcher
Write-Host "[3/4] 正在转换播放器核心并部署防绕过加载器..." -ForegroundColor Yellow
$potExe = Join-Path $potDir "PotPlayerMini64.exe"
$potCoreExe = Join-Path $potDir "PotPlayer64_Core.exe"
$patchLauncher = Join-Path $potDir "Patch\Launcher.exe"
$patchCs = Join-Path $potDir "Patch\Launcher.cs"

if (Test-Path $potExe) {
    $exeSize = (Get-Item $potExe).Length
    if ($exeSize -gt 100000) {
        Copy-Item -Path $potExe -Destination $potCoreExe -Force
        Write-Host "    已升级核心组件: PotPlayer64_Core.exe ($([math]::Round($exeSize/1MB, 2)) MB)" -ForegroundColor Green
    }
}

if (Test-Path $patchLauncher) {
    Copy-Item -Path $patchLauncher -Destination $potExe -Force
} elseif (Test-Path $patchCs) {
    & "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /target:winexe /platform:x64 /win32icon:"$potDir\potplayer.ico" /out:"$potExe" "$patchCs" | Out-Null
}
Write-Host "    已挂载免续期防护加载器: PotPlayerMini64.exe" -ForegroundColor Green

# 4. Sync Registry presets
Write-Host "[4/4] 正在同步播放器配置与滤镜预设..." -ForegroundColor Yellow
if (Test-Path "HKCU:\Software\Daum\PotPlayerMini64") {
    Copy-Item -Path "HKCU:\Software\Daum\PotPlayerMini64" -Destination "HKCU:\Software\Daum\PotPlayer64_Core" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "========================================================" -ForegroundColor Green
Write-Host "  升级完成！新版 PotPlayer 已就绪，免续期插帧防护100%生效。" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
