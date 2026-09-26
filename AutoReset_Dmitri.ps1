# AutoReset_Dmitri.ps1 - Portable DmitriRender Auto Renewal Script
$potDir = $PSScriptRoot
if (-not $potDir) { $potDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
$potExe = Join-Path $potDir "PotPlayerMini64.exe"
$patchBackup = Join-Path $potDir "Patch\version.dll"
$sampleVideo = Join-Path $potDir "sample.mp4"

# 1. Stop active processes
Get-Process | Where-Object { $_.ProcessName -match "PotPlayer|pcnsl|drtm|RunAsDate" } | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Clean expired registry and trial files
& reg.exe delete "HKCU\Software\DmitriRender" /f 2>$null | Out-Null
Remove-Item -Path "$env:APPDATA\DmitriRender\x64\Jongan.ini" -Force -ErrorAction SilentlyContinue

$desktop = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'desktop.ini'
if (Test-Path $desktop) {
    attrib -s -h $desktop
    $content = Get-Content $desktop -ErrorAction SilentlyContinue
    if ($content) {
        $clean = $content | Where-Object { $_ -notmatch '\{[0-9A-Fa-f\-]+\}' -and $_ -notmatch 'Class=' }
        Set-Content -Path $desktop -Value $clean -Force
    }
    attrib +s +h $desktop
}

Remove-Item -Path (Join-Path $potDir "version.dll") -Force -ErrorAction SilentlyContinue

# 3. Launch PotPlayer with dynamic offset to initialize DirectShow filter license
if (Test-Path $sampleVideo) {
    Start-Process -FilePath $potExe -ArgumentList "`"$sampleVideo`"" -WindowStyle Hidden
} else {
    Start-Process -FilePath $potExe -WindowStyle Hidden
}
Start-Sleep -Seconds 6
Get-Process | Where-Object { $_.ProcessName -match "PotPlayer|pcnsl|drtm" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# 4. Restore watermark patch
if (Test-Path $patchBackup) {
    for ($i = 0; $i -lt 10; $i++) {
        try {
            Copy-Item -Path $patchBackup -Destination (Join-Path $potDir "version.dll") -Force -ErrorAction Stop
            break
        } catch {
            Start-Sleep -Milliseconds 500
        }
    }
}
