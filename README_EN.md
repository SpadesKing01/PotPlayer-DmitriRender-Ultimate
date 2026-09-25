# PotPlayer + DmitriRender + LAV Filters + madVR Ultimate Portable Edition

[English](README_EN.md) | [简体中文](README.md)

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%2F%2011%20(64--bit)-blue.svg)](#)
[![PotPlayer](https://img.shields.io/badge/PotPlayer-v1.7.23122-orange.svg)](#)
[![DmitriRender](https://img.shields.io/badge/DmitriRender-v5.0.0.1-green.svg)](#)
[![LAV Filters](https://img.shields.io/badge/LAV%20Filters-v0.79.2-purple.svg)](#)
[![madVR](https://img.shields.io/badge/madVR-v0.92.17-red.svg)](#)
[![RunAsDate](https://img.shields.io/badge/RunAsDate-v1.41-brightgreen.svg)](#)

An out-of-the-box, standalone 64-bit media playback suite for Windows. Seamlessly integrates **PotPlayer** media player, **DmitriRender 5.0.0.1** real-time GPU optical flow frame interpolation, **LAV Filters** audio/video decoders, and **madVR** high-fidelity video renderer.

Completely overcomes DmitriRender StarForce expiration locks, 2026 calendar hard limits, system clock rollback detections, floating watermarks, and 4K 10-bit HDR/HEVC green screen tinting.

---

## 📦 Integrated Components Matrix

| Component | Exact Version | Arch | Description & Features |
| :--- | :--- | :--- | :--- |
| **PotPlayer** | `v1.7.23122` | x64 | Core media player with tuned performance presets, clean & ad-free |
| **DmitriRender** | `v5.0.0.1` | x64 | GPU optical flow real-time frame interpolation (60/120/144/240 FPS) |
| **LAV Filters** | `v0.79.2` | x64 | DirectShow audio/video splitters & decoders (Dolby Atmos/DTS passthrough) |
| **madVR** | `v0.92.17` | x86/x64 | High-end video renderer with chromatic upscaling & HDR tone mapping |
| **RunAsDate** | `v1.41` | x64 | Dynamic relative time-spoofing loader (constant 2-year offset window) |
| **Watermark Patch**| `version.dll` | x64 | In-memory hook patch eliminating DmitriRender floating trial watermark |

---

## 🌟 Core Highlights

1. **Dynamic Relative Time Spoofing (Core Breakthrough)**:
   - Configured with `RunAsDate` relative time parameter `/movetime Hours:-17520` (constantly 2 years behind real time).
   - **Time flows synchronously with system clock**, eliminating StarForce "clock rollback detection" fatal errors caused by static fixed dates.
2. **Silent Automated Background License Reset**:
   - Built-in `AutoReset_Dmitri.ps1` script paired with Windows Task Scheduler task `DmitriRender_AutoReset`.
   - Automatically and silently clears trial registry keys and timestamps every 20 days at 15:00 to re-issue a fresh 30-day window without user intervention.
3. **Floating Watermark Elimination**:
   - Deploys `version.dll` memory interception module, suppressing the floating trial watermark in the lower-right corner.
4. **4K 10-bit HEVC Green Screen Fix**:
   - Pre-configured with **D3D11 Copy-Back hardware acceleration** in VRAM, converting 10-bit `P010` video to 8-bit `NV12` before feeding frames to DmitriRender, eliminating green screen tears.
5. **Lossless Multi-Channel Audio (LAV Audio)**:
   - Prioritizes 64-bit LAV Audio Decoder for bit-perfect output of Dolby Atmos, EAC3, TrueHD, DTS-HD Master Audio.
6. **Integrated madVR Renderer**:
   - Includes full madVR 0.92.17 suite for enthusiasts pursuing state-of-the-art scaling, debanding, and HDR tone mapping.
7. **Clean PotPlayer Branding & Official Icons**:
   - Injects Windows `Capabilities` and `RegisteredApplications` entries so Windows recognizes it as `PotPlayer`.
   - Desktop shortcut and Open-With menus strictly use authentic yellow PotPlayer rounded-square icon (`PotPlayerMini64.exe,0`), eliminating RunAsDate calendar icons.

---

## 📂 Directory Layout

```text
PotPlayer/
├── PotPlayerMini64.exe               # PotPlayer 64-bit main executable
├── PotPlayer64.dll                   # Core shared library
├── RunAsDate.exe                     # 64-bit dynamic time spoofing injector
├── PotIcons64.dll                    # Official icon library for media formats
├── version.dll                       # Watermark removal memory hook
├── AutoReset_Dmitri.ps1              # Automated silent license refresh script
├── PotPlayer_Config.template.reg     # Tuned configuration registry template
├── 【一键绿化安装】.bat              # Administrator one-click installer
├── 【一键彻底卸载】.bat              # Administrator one-click uninstaller
├── DmitriRender/                     # DmitriRender 5.0.0.1 64-bit core files
├── LAVFilters/                       # LAV Filters x64 suite (Audio/Video/Splitter)
├── madVR/                            # madVR 0.92.17 video renderer suite
├── Patch/                            # Backup of clean memory patch
└── !vc2017_x64.exe                   # Visual C++ 2017 64-bit runtime installer
```

---

## 🚀 Quick Start

### 1. Extract Directory
Extract the archive to any local folder (e.g. `D:\PotPlayer` or `C:\Tools\PotPlayer`; avoid unusual special characters in path).

### 2. One-Click Setup
In the extracted directory, **right-click 【一键绿化安装.bat】** and select **【Run as administrator】**.

The script will automatically perform:
1. Terminate running player instances and background helper processes;
2. Deploy and register DmitriRender filters to `%APPDATA%\DmitriRender`;
3. Register 64-bit LAV Filters (Audio/Video/Splitter) and madVR;
4. Import performance-tuned registry settings (hardware decode, audio bitstream, OSD);
5. Initialize time-spoofing environment and watermark bypass;
6. Create Windows background maintenance task `DmitriRender_AutoReset` (executing every 20 days at 15:00);
7. Register Windows Default App capabilities for 20 common media formats;
8. Lock official yellow PotPlayer icons and refresh Windows Explorer icon cache.

### 3. Default App & Open-With Selection Guide

- **When "How do you want to open this file?" dialog appears**:
  - Select **`PotPlayer`** (marked with the **classic yellow player icon**);
  - Check **【Always use this app】**, then click OK.
  - *Note*: Underlying registry entries are already injected with `-17520h` dynamic clock parameters; selecting it starts the player with automatic 60FPS frame interpolation.
- **Automatic File Association**:
  Double-clicking any standard video format (MP4, MKV, AVI, etc.) will directly open and interpolate frames in PotPlayer.
- **Windows 11 Settings (Optional)**:
  Press `Win + I` -> Apps -> Default apps -> Search `PotPlayer` -> Click "Set default" to assign all media extensions at once.

---

## 🔍 Verification & Health Check

After running 【一键绿化安装.bat】, verify the installation state:

### 1. Check Background Auto-Reset Task
- **Command Line**: In CMD or PowerShell, run:
  ```cmd
  schtasks /Query /TN "DmitriRender_AutoReset" /FO LIST
  ```
  If status shows `Ready`, the automated reset task is armed and active.
- **Task Scheduler GUI**:
  Press `Win + R`, type `taskschd.msc` and hit Enter. Navigate to `Task Scheduler Library` -> find `DmitriRender_AutoReset`. Verify status is `Ready` with trigger `Every 20 days at 15:00`.

### 2. Check Frame Interpolation & Decoder Status
While playing any video, press **`Tab`** (or `Ctrl + F1`) on your keyboard to reveal the playback OSD:
1. **Output FPS**: Confirm output frame rate reaches **60.00 fps** (or your display refresh rate 120/144/240 fps);
2. **Filter Chain**: Look for `DmitriRender` in the video filter chain;
3. **Audio Decoder**: Confirm audio decoder displays `LAV Audio Decoder`.

---

## 🧹 Uninstallation

To cleanly remove or move directories:
1. **Right-click 【一键彻底卸载.bat】** and select **【Run as administrator】**.
2. All DirectShow filters will be unregistered, scheduled tasks removed, and file associations cleanly restored.

---

## ❓ Troubleshooting (FAQ)

### Q1: "dmitriRender trial expired" error appears in the lower-left corner?
- **Cause**: System clock changed drastically, or 30-day window expired before reset.
- **Fix**: Right-click `【一键绿化安装】.bat` as administrator, or run `AutoReset_Dmitri.ps1` in PowerShell to immediately renew the 30-day license.

### Q2: 4K 10-bit video shows green screen or distorted colors?
- **Cause**: DmitriRender natively requires 8-bit NV12 frames.
- **Fix**: The pre-configured settings enable `DXVA2 Copy-Back: D3D11`. If preferences were manually reset, navigate to `Preferences (F5) -> Filter -> Video Decoder -> Built-in Decoder/DXVA Settings`, enable `Hardware Acceleration (DXVA)`, and select `D3D11` for Copy-Back.

### Q3: Missing VC++ runtime or DLL errors?
- **Fix**: Run `!vc2017_x64.exe` in the root folder to install the required Visual C++ 2017 x64 runtime.

---

## ⚖️ Disclaimer

This package is intended solely for personal media evaluation and technical research. All proprietary software components (DmitriRender, PotPlayer, LAV Filters, madVR) belong to their respective original copyright holders. Please support the official developers.
