# Install_Green.ps1 - Automated Setup for Portable PotPlayer + DmitriRender + LAV Filters
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Continue"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  PotPlayer + DmitriRender 绿化版 安装配置中..." -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$potDir = $PSScriptRoot
if (-not $potDir) { $potDir = Split-Path -Parent $MyInvocation.MyCommand.Path }

$potExe = Join-Path $potDir "PotPlayerMini64.exe"
$runAsDate = Join-Path $potDir "RunAsDate.exe"
$iconsDll = Join-Path $potDir "PotIcons64.dll"
$patchSrc = Join-Path $potDir "Patch\version.dll"
$potPatch = Join-Path $potDir "version.dll"
$autoResetPs1 = Join-Path $potDir "AutoReset_Dmitri.ps1"
$templateReg = Join-Path $potDir "PotPlayer_Config.template.reg"
$appDataDmitri = Join-Path $env:APPDATA "DmitriRender"
$lavX64 = Join-Path $potDir "LAVFilters\x64"
$sampleVideo = Join-Path $potDir "sample.mp4"

# 1. Terminate existing processes and clean legacy core files
Write-Host "[1/7] 正在关闭现有播放器及后台进程..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -match "PotPlayer|pcnsl|drtm|RunAsDate" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

Remove-Item -Path (Join-Path $potDir "PotPlayer64_Core.exe") -Force -ErrorAction SilentlyContinue
Remove-Item -Path (Join-Path $potDir "Patch\Launcher.*") -Force -ErrorAction SilentlyContinue
Remove-Item -Path (Join-Path $potDir "Playlist\PotPlayer64_Core.dpl") -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKCU:\Software\Daum\PotPlayer64_Core" -Recurse -Force -ErrorAction SilentlyContinue

# 2. Deploy DmitriRender to %APPDATA%
Write-Host "[2/7] 正在部署 DmitriRender 插帧核心组件..." -ForegroundColor Yellow
if (-not (Test-Path $appDataDmitri)) {
    New-Item -ItemType Directory -Path $appDataDmitri -Force | Out-Null
}
Copy-Item -Path "$potDir\DmitriRender\*" -Destination $appDataDmitri -Recurse -Force
Remove-Item -Path "$appDataDmitri\x64\Jongan.ini" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKCU:\Software\DmitriRender" -Recurse -Force -ErrorAction SilentlyContinue

$desktopIni = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'desktop.ini'
if (Test-Path $desktopIni) {
    attrib -s -h $desktopIni
    $content = Get-Content $desktopIni -ErrorAction SilentlyContinue
    if ($content) {
        $clean = $content | Where-Object { $_ -notmatch '\{[0-9A-Fa-f\-]+\}' -and $_ -notmatch 'Class=' }
        Set-Content -Path $desktopIni -Value $clean -Force
    }
    attrib +s +h $desktopIni
}

# 3. Register DirectShow Filters
Write-Host "[3/7] 正在注册 DirectShow 滤镜 (DmitriRender + LAV Filters + madVR)..." -ForegroundColor Yellow
& regsvr32.exe /s "$appDataDmitri\x64\dmitriRender.dll"
& regsvr32.exe /s "$lavX64\LAVAudio.ax"
& regsvr32.exe /s "$lavX64\LAVVideo.ax"
& regsvr32.exe /s "$lavX64\LAVSplitter.ax"

$madDir = Join-Path $potDir "madVR"
if (Test-Path (Join-Path $madDir "madVR64.ax")) {
    Push-Location $madDir
    & regsvr32.exe /s "madVR.ax"
    & regsvr32.exe /s "madVR64.ax"
    Pop-Location
}

# 4. Import PotPlayer registry configuration
Write-Host "[4/7] 正在应用播放器预设配置..." -ForegroundColor Yellow
if (Test-Path $templateReg) {
    $rawReg = Get-Content $templateReg -Raw -Encoding Unicode
    $escapedPot = $potDir.Replace('\', '\\')
    $escapedLav = $lavX64.Replace('\', '\\')
    $finalReg = $rawReg.Replace('{{POT_DIR_ESC}}', $escapedPot).Replace('{{LAV_DIR_ESC}}', $escapedLav)
    
    $tempRegFile = Join-Path $env:TEMP "PotPlayer_Apply.reg"
    $finalReg | Set-Content $tempRegFile -Encoding Unicode
    & reg.exe import $tempRegFile | Out-Null
    Remove-Item $tempRegFile -Force -ErrorAction SilentlyContinue
}

# 5. Initialize StarForce License & Watermark Bypass
Write-Host "[5/7] 正在初始化时间伪装及免水印环境..." -ForegroundColor Yellow
Remove-Item -Path $potPatch -Force -ErrorAction SilentlyContinue

if (Test-Path $sampleVideo) {
    Start-Process -FilePath $runAsDate -ArgumentList "/immediate /movetime Hours:-17520 `"$potExe`" `"$sampleVideo`"" -WindowStyle Hidden
} else {
    Start-Process -FilePath $runAsDate -ArgumentList "/immediate /movetime Hours:-17520 `"$potExe`"" -WindowStyle Hidden
}
Start-Sleep -Seconds 6
Get-Process | Where-Object { $_.ProcessName -match "PotPlayer|pcnsl|drtm" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

if (Test-Path $patchSrc) {
    for ($i = 0; $i -lt 10; $i++) {
        try {
            Copy-Item -Path $patchSrc -Destination $potPatch -Force -ErrorAction Stop
            break
        } catch {
            Start-Sleep -Milliseconds 500
        }
    }
}

# 6. Setup Background Auto-Reset Scheduled Task
Write-Host "[6/7] 正在配置后台静默自动续期计划任务 (每20天下午15:00自动维护)..." -ForegroundColor Yellow
& schtasks.exe /Delete /TN "DmitriRender_AutoReset" /F 2>$null | Out-Null
& schtasks.exe /Create /SC DAILY /MO 20 /ST 15:00 /TN "DmitriRender_AutoReset" /TR "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File \`"$autoResetPs1\`"" /F | Out-Null
try {
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    Set-ScheduledTask -TaskName "DmitriRender_AutoReset" -Settings $settings -ErrorAction SilentlyContinue | Out-Null
} catch {}

# 7. Create Desktop Shortcut and File Associations (High-Speed Batch Mode)
Write-Host "[7/7] 正在创建桌面快捷方式及关联媒体文件格式..." -ForegroundColor Yellow

$wsh = New-Object -ComObject WScript.Shell
$desktopPath = [Environment]::GetFolderPath('Desktop')
Remove-Item -Path (Join-Path $desktopPath "PotPlayer (插帧免续期版).lnk") -Force -ErrorAction SilentlyContinue
$shortcut = $wsh.CreateShortcut((Join-Path $desktopPath "PotPlayer.lnk"))
$shortcut.TargetPath = $runAsDate
$shortcut.Arguments = "/immediate /movetime Hours:-17520 `"$potExe`""
$shortcut.WorkingDirectory = $potDir
$shortcut.IconLocation = "$potExe,0"
$shortcut.Description = "PotPlayer 64-bit with DmitriRender 60FPS"
$shortcut.Save()

$cmd = "`"$runAsDate`" /immediate /movetime Hours:-17520 `"$potExe`" `"%1`""
$escapedCmd = $cmd.Replace('\', '\\').Replace('"', '\"')
$escapedIcons = $iconsDll.Replace('\', '\\')
$escapedPot = $potExe.Replace('\', '\\')

$extIcons = @{
    'mp4' = 13; 'mkv' = 15; 'avi' = 1; 'flv' = 21; 'mov' = 20;
    'wmv' = 7; 'ts' = 33; 'webm' = 0; 'm4v' = 14; 'rmvb' = 12;
    'mp3' = 48; 'flac' = 62; 'wav' = 70; 'aac' = 63; 'm4a' = 46;
    'iso' = 17; 'vob' = 18; 'mpg' = 3; 'mpeg' = 3; '3gp' = 28
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("Windows Registry Editor Version 5.00`r`n")

# Capabilities
[void]$sb.AppendLine("[HKEY_CURRENT_USER\Software\Daum\PotPlayerMini64\Capabilities]")
[void]$sb.AppendLine('"ApplicationName"="PotPlayer"')
[void]$sb.AppendLine('"ApplicationDescription"="PotPlayer 64-bit 终极免续期插帧绿化版"')
[void]$sb.AppendLine(('"ApplicationIcon"="{0},0"' -f $escapedPot))
[void]$sb.AppendLine("`r`n[HKEY_CURRENT_USER\Software\RegisteredApplications]")
[void]$sb.AppendLine('"PotPlayerMini64"="Software\\Daum\\PotPlayerMini64\\Capabilities"`r`n')

[void]$sb.AppendLine("[HKEY_CURRENT_USER\Software\Daum\PotPlayerMini64\Capabilities\FileAssociations]")
foreach ($ext in $extIcons.Keys) {
    [void]$sb.AppendLine(('".{0}"="PotPlayerMini64.{0}"' -f $ext))
}
[void]$sb.AppendLine("")

# Applications registration & DropTarget purge
foreach ($app in @("PotPlayerMini64.exe", "RunAsDate.exe")) {
    foreach ($root in @("HKEY_CURRENT_USER\Software\Classes\Applications", "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Applications")) {
        [void]$sb.AppendLine(('[{0}\{1}]' -f $root, $app))
        [void]$sb.AppendLine('@="PotPlayer"')
        [void]$sb.AppendLine('"FriendlyAppName"="PotPlayer"')
        [void]$sb.AppendLine(('[{0}\{1}\DefaultIcon]' -f $root, $app))
        [void]$sb.AppendLine(('@="{0},0"' -f $escapedPot))
        [void]$sb.AppendLine(('[{0}\{1}\shell\open\command]' -f $root, $app))
        [void]$sb.AppendLine(('@="{0}"' -f $escapedCmd))
        [void]$sb.AppendLine(('[{0}\{1}\shell\play\command]' -f $root, $app))
        [void]$sb.AppendLine(('@="{0}"' -f $escapedCmd))
        [void]$sb.AppendLine(('[-{0}\{1}\shell\open\DropTarget]' -f $root, $app))
        [void]$sb.AppendLine(('[-{0}\{1}\shell\play\DropTarget]' -f $root, $app))
        [void]$sb.AppendLine("")
    }
}

# Media extensions association & DropTarget purge
foreach ($ext in $extIcons.Keys) {
    $progId = "PotPlayerMini64.$ext"
    $iconIdx = $extIcons[$ext]

    foreach ($root in @("HKEY_CURRENT_USER\Software\Classes", "HKEY_LOCAL_MACHINE\SOFTWARE\Classes")) {
        [void]$sb.AppendLine(('[{0}\{1}]' -f $root, $progId))
        [void]$sb.AppendLine(('@="{0} 媒体文件"' -f $ext))
        [void]$sb.AppendLine(('[{0}\{1}\DefaultIcon]' -f $root, $progId))
        [void]$sb.AppendLine(('@="{0},{1}"' -f $escapedIcons, $iconIdx))
        [void]$sb.AppendLine(('[{0}\{1}\shell]' -f $root, $progId))
        [void]$sb.AppendLine('@="open"')
        [void]$sb.AppendLine(('[{0}\{1}\shell\open\command]' -f $root, $progId))
        [void]$sb.AppendLine(('@="{0}"' -f $escapedCmd))
        [void]$sb.AppendLine(('[{0}\{1}\shell\play\command]' -f $root, $progId))
        [void]$sb.AppendLine(('@="{0}"' -f $escapedCmd))
        [void]$sb.AppendLine(('[-{0}\{1}\shell\open\DropTarget]' -f $root, $progId))
        [void]$sb.AppendLine(('[-{0}\{1}\shell\play\DropTarget]' -f $root, $progId))
        [void]$sb.AppendLine(('[-{0}\{1}\shell\Enqueue\DropTarget]' -f $root, $progId))
        [void]$sb.AppendLine("")
    }

    [void]$sb.AppendLine(('[HKEY_CURRENT_USER\Software\Classes\.{0}]' -f $ext))
    [void]$sb.AppendLine(('@="{0}"' -f $progId))
    [void]$sb.AppendLine(('`r`n[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.{0}\OpenWithList]' -f $ext))
    [void]$sb.AppendLine('"a"="PotPlayerMini64.exe"')
    [void]$sb.AppendLine('"MRUList"="a"')
    [void]$sb.AppendLine(('`r`n[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.{0}\OpenWithProgids]' -f $ext))
    [void]$sb.AppendLine(('"{0}"=hex:' -f $progId))
    [void]$sb.AppendLine('"Applications\\PotPlayerMini64.exe"=hex:`r`n')
}

$tempAssocReg = Join-Path $env:TEMP "PotPlayer_Assoc.reg"
[System.IO.File]::WriteAllText($tempAssocReg, $sb.ToString(), [System.Text.Encoding]::Unicode)
& reg.exe import $tempAssocReg 2>$null | Out-Null
Remove-Item $tempAssocReg -Force -ErrorAction SilentlyContinue

# Fast shell refresh
& ie4uinit.exe -show 2>$null
& rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True 2>$null

Write-Host "========================================================" -ForegroundColor Green
Write-Host "  安装完成！PotPlayer 绿化版已就绪。" -ForegroundColor Green
Write-Host "  - 默认视频播放器: 已关联 20 种媒体格式 (原版/升级覆盖均直接生效)" -ForegroundColor Green
Write-Host "  - 播放器图标: 官方高清矢量图标已全局生效" -ForegroundColor Green
Write-Host "  - 动态时间欺骗: -17520小时 (免续期，支持双击直接打开与拖入播放)" -ForegroundColor Green
Write-Host "  - 后台静默续期任务: DmitriRender_AutoReset (每20天下午15:00自动维护)" -ForegroundColor Green
Write-Host "  - DmitriRender 插帧 + 去水印: 已生效" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
