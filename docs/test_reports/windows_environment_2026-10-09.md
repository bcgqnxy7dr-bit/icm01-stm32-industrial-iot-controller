# ICM-01 Windows 基础开发环境检查

日期：2026-10-09（Asia/Shanghai）。本次只进行环境配置，没有 STM32 功能开发。

## 初始检查

- Windows 10.0.19045，系统/进程均为 x64。
- PowerShell 7.6.5；winget v1.29.380，可用。
- 用户 DESKTOP-J80TFCC\Administrator；执行进程未提升管理员权限。
- 项目初始只有 .git，没有 README、进度文档、源码或 AGENTS.md。
- git status --short --branch：No commits yet on master；初始工作区干净。
- 初始 Git 2.53.0.windows.3 来自 Codex 缓存。python 仅为 WindowsApps 应用别名，py/pip/code 不可调用。
- 后续 py -0p 检出既有 uv 管理的 CPython 3.12.14，文件创建于 2026-09-30；没有修改或删除。

## 自动安装

通过 winget 解析官方安装包，三个安装均报告成功，下载均通过 winget 哈希校验。

| 软件 | 版本 | winget 包 | 官方安装来源 |
| --- | --- | --- | --- |
| Git | 2.55.0.windows.5 | Git.Git（显示 2.55.0.5） | github.com/git-for-windows/git/releases |
| Python x64 | 3.13.15 | Python.Python.3.13 | www.python.org |
| pip | 26.2.1 | 随 Python 安装 | Python 官方安装器 |
| py | 默认解释器 3.13.15 | 随 Python 安装 | Python 官方安装器 |
| VS Code 用户版 | 1.140.0 | Microsoft.VisualStudioCode | vscode.download.prss.microsoft.com |

Git 位于 C:\Program Files\Git。Python/VS Code 为用户级安装。本次仅新增 Python 3.13，不删除既有 uv Python 或 Codex Git。

Python 安装参数：/quiet InstallAllUsers=0 PrependPath=1 Include_pip=1 Include_launcher=1 InstallLauncherAllUsers=0 Include_test=0

## 实际验证

验证进程通过持久机器和用户 PATH 刷新自己的 PATH。已有终端重新打开后读取新 PATH。PowerShell 使用 where.exe 执行路径查找，避免 where 别名。

| 命令 | 结果 |
| --- | --- |
| git --version | git version 2.55.0.windows.5 |
| python --version | Python 3.13.15 |
| py --version | Python 3.13.15 |
| pip --version | pip 26.2.1，python 3.13 |
| where.exe git | C:\Program Files\Git\cmd\git.exe |
| where.exe python | C:\Users\Administrator\AppData\Local\Programs\Python\Python313\python.exe；其次是 WindowsApps\python.exe 应用别名 |
| where.exe code | C:\Users\Administrator\AppData\Local\Programs\Microsoft VS Code\bin\code 和 code.cmd |
| winget list（仅相关行） | Git.Git 2.55.0.5；Python.Python.3.13 3.13.15；Microsoft.VisualStudioCode 1.140.0；Python.Launcher 版本字段 < 3.14.7 |
| py -0p | 默认 3.13；另有既有 Astral/CPython3.12.14 |
| Python struct.calcsize('P') * 8 | 64 |
| Python import pip | 成功 |
| Code.exe 文件及 ProductVersion | 存在，1.140.0 |

## STM32CubeIDE

状态：需要人工安装。

winget search STM32CubeIDE 和 winget search STM32 均未找到包。PATH、卸载注册表、C:\ST 和常见 STMicroelectronics 目录未发现 CubeIDE、ARM GCC 或 STM32 工具链；不能排除其他目录的便携程序。

官方入口：https://www.st.com/en/development-tools/stm32cubeide.html

按用户要求，官方图形安装器、许可确认、可能的管理员和驱动操作留给用户；本次没有启动安装。没有安装独立 ARM GCC 或其他第三方工具链。

## ST-Link

Get-PnpDevice（含 PresentOnly）、Win32_PnPSignedDriver 没有检出 ST-Link/STM32/VID_0483 匹配设备；pnputil /enum-drivers 未发现相关 ST 驱动条目。

未真正检测到 ST-Link，不能确认驱动工作。Hardware verification pending.

用户后续连接实际拥有的 ST-Link，用设备管理器检查设备名称、状态和驱动。如需要驱动，仅使用 ST 官方 STSW-LINK009：https://www.st.com/en/development-tools/stsw-link009.html

尚未验证：软件图形启动体验、CubeIDE 编译、STM32 烧录/调试、真实硬件接线。

## 范围与后续

没有修改系统策略、Windows Update、防火墙、Defender 或代理；没有删除已有软件；没有安装禁止列表的软件或 VS Code ESP-IDF 扩展。

本次仅新增检查报告，不创建产品模块。用户无需手动安装 Git/Python/pip/VS Code。下一项建议：官方 CubeIDE 安装完成后验证其自带工具链，等待明确任务再执行。
