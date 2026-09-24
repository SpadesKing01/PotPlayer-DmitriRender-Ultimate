# PotPlayer + DmitriRender + LAV Filters + madVR 终极免续期绿化整合版

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%2F%2011%20(64--bit)-blue.svg)](#)
[![PotPlayer](https://img.shields.io/badge/PotPlayer-64--bit-orange.svg)](#)
[![DmitriRender](https://img.shields.io/badge/DmitriRender-v5.0.0.1-green.svg)](#)
[![LAV Filters](https://img.shields.io/badge/LAV%20Filters-x64-purple.svg)](#)
[![madVR](https://img.shields.io/badge/madVR-v0.92.17-red.svg)](#)

开箱即用的 Windows 64 位极致观影体验整合包。完美融合 **PotPlayer** 现代播放器、**DmitriRender 5.0.0.1** 实时 GPU 光流补帧、**LAV Filters** 强力音视频解码器与 **madVR** 高画质视频渲染器。

彻底解决 DmitriRender 试用期 StarForce 锁死、2026年硬边界、时钟倒退检测、右下角跑动水印以及 4K 10-bit HDR 绿屏色域异常等顽疾。

---

## 🌟 核心特性

1. **动态相对时间欺骗（核心技术）**：
   - 预置 `RunAsDate` 相对时间偏移参数 `/movetime Hours:-17520`（恒定比真实时间滞后 2 年至 2024 年安全窗口）。
   - **时间随系统时钟同步向前流逝**，彻底避免静态死时间导致的 StarForce “检测到时钟倒流作弊” 致命锁死错误。
2. **后台静默续期计划任务**：
   - 内置 `AutoReset_Dmitri.ps1` 便携脚本与 Windows 计划任务 `DmitriRender_AutoReset`。
   - 每 20 天在后台自动静默清理过期的试用注册表与时间戳文件，重新签发 30 天试用期，实现完全无感“一劳永逸”。
3. **试用跑动水印完全消除**：
   - 自动部署 `version.dll` 专用内存劫持补丁，彻底屏蔽画面右下角 DmitriRender 跑动水印。
4. **4K 10-bit HEVC 绿屏/色彩异常修复**：
   - 预设启用 **D3D11 Copy-Back 硬件加速**，在显存内预先将高规格 10-bit `P010` 视频无损转码为 DmitriRender 所需的 8-bit `NV12` 色彩空间，根治绿屏与画面撕裂。
5. **顶级音频全格式直出（LAV Audio）**：
   - 集成 64 位 LAV Audio 解码器，完美解码并直出 Dolby Atmos、EAC3、TrueHD、DTS-HD Master Audio 等多声道音轨。
6. **集成顶级渲染器 madVR**：
   - 包含 madVR 0.92.17 核心组件，支持一键注册与配置，满足追求极致渲染画质的进阶用户需求。
7. **系统默认播放器自动认证与官方高清图标**：
   - 自动写入 Windows `Capabilities` 与 `RegisteredApplications`，让 Windows 10/11 正式将本绿化版认证为受信任的媒体播放器。
   - 底层指令双重劫持：无论系统走哪个注册表路径拉起播放器，均内嵌 `-17520h` 动态时钟参数，实现直接双击即享插帧。
   - 图标强行覆盖与缓存刷新：所有视频文件和打开方式均锁定为 PotPlayer 官方原生高清图标，彻底杜绝 RunAsDate 日历图标。

---

## 📂 目录结构

```text
PotPlayer_GreenPackage/
├── PotPlayerMini64.exe               # PotPlayer 64位主程序
├── PotPlayer64.dll                   # 核心链接库
├── RunAsDate.exe                     # 64位动态时间劫持加载器
├── PotIcons64.dll                    # 官方高清文件格式图标库
├── version.dll                       # 水印去除内存补丁
├── AutoReset_Dmitri.ps1              # 便携后台静默续期脚本
├── sample.mp4                        # 滤镜激活与自检微型样本视频
├── PotPlayer_Config.template.reg     # 全套优化预设注册表模板
├── 【一键绿化安装】.bat              # 管理员权限一键配置引导脚本
├── 【一键彻底卸载】.bat              # 一键完整清理与卸载脚本
├── DmitriRender/                     # DmitriRender 5.0.0.1 64位纯净核心文件
├── LAVFilters/                       # LAV Filters x64 解码器套件 (Audio/Video/Splitter)
├── madVR/                            # madVR 0.92.17 视频渲染器
├── Patch/                            # 纯净版免水印补丁备份库
└── !vc2017_x64.exe                   # Visual C++ 2017 64位运行库安装包
```

---

## 🚀 快速使用

### 1. 解压目录
将压缩包解压到任意磁盘目录（例如 `D:\PotPlayer` 或 `C:\Tools\PotPlayer`，路径中建议不要含有特殊字符）。

### 2. 一键安装
在解压出的文件夹中，**右键单击【一键绿化安装.bat】**，选择 **【以管理员身份运行】**。
脚本将全自动执行以下操作：
1. 终止残留播放器与后台守护进程；
2. 部署并注册 DmitriRender 滤镜至 `%APPDATA%\DmitriRender`；
3. 注册 64 位 LAV Filters（音频/视频/分离器）及 madVR；
4. 导入经过全方位调优的播放器预设参数（硬件硬解、音轨优先、OSD禁用）；
5. 初始化时间欺骗环境并部署免水印补丁；
6. 创建 Windows 后台静默续期任务（每 20 天自动维护）；
7. 写入 Windows 默认媒体播放器能力集（Capabilities）并绑定 20 种常用格式；
8. 全局锁定 PotPlayer 官方高清图标并自动广播刷新 Explorer 缓存。

### 3. 默认播放器与官方图标说明

- **全自动默认关联**：
  运行安装脚本后，底层已完成注册劫持与 MRU 首选设置，**直接双击本地任意视频文件即可自动进入插帧播放**，无需额外选择。
- **全局官方原生图标**：
  所有视频文件的图标全部显示为官方对应的高清图标（如 MP4、MKV 原生标示），安装脚本会在结束后自动清理 Windows 图标缓存并即刻生效。
- **系统设置一键指定（可选）**：
  若想在 Windows 11 设置中全局确认：按 `Win + I` 打开系统设置 -> 点击【应用】 -> 【默认应用】 -> 搜索 `PotPlayer` -> 点击右上角【设为默认值】即可一键接管全部多媒体扩展名。

---

## 🔍 安装与状态核验方法 (Verification)

运行【一键绿化安装.bat】后，你可以通过以下方式快速核验各个核心组件与计划任务是否成功就绪：

### 1. 验证后台静默续期任务
- **命令行方式**：在 CMD 或 PowerShell 中运行以下命令，若返回状态包含 `Ready`（准备就绪），说明续期任务已成功建立并处于保护中：
  ```cmd
  schtasks /Query /TN "DmitriRender_AutoReset" /FO LIST
  ```
- **图形化界面方式**：
  按快捷键 `Win + R`，输入 `taskschd.msc` 回车打开【任务计划程序】。点击左侧【任务计划程序库】，在列表中找到 **`DmitriRender_AutoReset`**，确认其状态为“准备就绪”，触发器为“每 20 天”。

### 2. 验证插帧与解码器运行状态
播放任意视频时，按下键盘 **`Tab`** 键（或 `Ctrl + F1`）调出播放信息 OSD 检查：
1. **插帧帧率**：查看输出帧率是否达到 **60.00 fps**（或显示器刷新率 120 / 144 / 240 fps）；
2. **插帧滤镜**：在视频处理滤镜链中可以看到 `DmitriRender`；
3. **音频解码**：音频解码器栏显示为 `LAV Audio Decoder`。

---

## 🧹 卸载方法

如需清理或迁移目录：
1. **右键单击【一键彻底卸载.bat】**，选择 **【以管理员身份运行】**。
2. 脚本会自动注销 DirectShow 滤镜、移除 Windows 计划任务、清理临时注册表与格式关联。

---

## ❓ 常见问题排查 (FAQ)

### Q1: 播放时画面左下角出现 "dmitriRender trial expired" 提示？
- **原因**：系统时间被改动，或试用期达到 30 天未刷新。
- **解决**：再次右键管理员运行目录下的 `【一键绿化安装】.bat`，或在 PowerShell 中直接运行 `AutoReset_Dmitri.ps1`，即可一键刷新试用期。

### Q2: 播放 4K 10-bit 视频时半边绿屏或色彩错乱？
- **原因**：DmitriRender 原生仅接受 8-bit NV12 格式帧输入。
- **解决**：本绿化版默认已配置好内置解码器中的 `DXVA2 Copy-Back: D3D11`。若手动重置了设置，请在 `选项(F5) -> 滤镜 -> 视频解码器 -> 内置解码器/DXVA设置` 中勾选 `使用硬件加速(DXVA)`，并将 Copy-Back 选为 `D3D11`。

### Q3: 提示找不到 VC++ 运行库或 DLL 丢失？
- **解决**：双击运行本目录下的 `!vc2017_x64.exe` 完成运行库安装即可。

---

## ⚖️ 免责声明 (Disclaimer)

本项目仅用于技术交流与个人多媒体调优测试。涉及的第三方商业/闭源组件（DmitriRender、PotPlayer、LAV Filters、madVR）版权均归各自原始著作权人所有。请支持正版软件。

