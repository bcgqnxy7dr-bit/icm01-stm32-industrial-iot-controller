# ICM-01 Windows 开发环境验收

日期：2026-10-09（Asia/Shanghai）。初次结论：Ready, hardware target pending。后续最小 SWD 验证通过，当前结论：Ready。

本次仅检查既有环境、执行版本/帮助命令并保存报告；不创建 STM32 工程或业务代码，不连接目标 MCU，不烧录，不操作 COM 设备，不修改系统 PATH、IDE 配置或安全策略，不安装/升级软件。

## 项目检查

已读取前次环境报告并检查目录和 Git 状态。当前没有 README、独立进度文档或源码；初始 Git 状态为 No commits yet on master，docs/ 未跟踪。前次报告记录的是安装 CubeIDE、CubeMX 和连接 ST-Link 之前的历史状态，本报告记录当前验收结果。

## 基础环境实际结果

| 命令 | 结果 |
| --- | --- |
| git --version | git version 2.55.0.windows.5 |
| python --version | Python 3.13.15 |
| py --version | Python 3.13.15 |
| pip --version | pip 26.2.1，关联 Python313\Lib\site-packages\pip (python 3.13) |
| where.exe git | C:\Program Files\Git\cmd\git.exe 优先，随后为 Codex 自带 Git |
| where.exe python | C:\Users\Administrator\AppData\Local\Programs\Python\Python313\python.exe 优先，随后为 WindowsApps 应用别名 |
| where.exe code | C:\Users\Administrator\AppData\Local\Programs\Microsoft VS Code\bin\code 和 code.cmd |
| code --version | 1.140.0，x64，退出码 0 |
| Python struct.calcsize('P') * 8 | 64 |
| Python import pip | 成功，模块位于 Python313\Lib\site-packages\pip |

使用当前进程原有 PATH；本次没有修改环境变量。

## STM32CubeIDE 与 CubeMX

- CubeIDE 主程序：D:\download\stm32cubeide\STM32CubeIDE_2.2.0\STM32CubeIDE\stm32cubeide.exe，存在。
- CubeIDE 版本：2.2.0，由卸载注册表、.eclipseproduct 和 stm32cubeide.ini 相互核对。
- CubeIDE 控制台入口 stm32cubeidec.exe 和 headless-build.bat 存在；未启动 IDE 或实际工程构建。
- CubeIDE 自带 Java：OpenJDK 21.0.10，java -version 退出码 0。
- CubeMX 主程序：D:\cubemx\STM32CubeMX.exe，存在。
- CubeMX 安装版本：6.11.1；程序文件版本字段为 >6.11.1-RC2。版本证据来自卸载注册表和程序元数据。
- CubeMX 自带 Java：OpenJDK 17.0.8.1，java -version 退出码 0。
- CubeMX families.xml 包含 STM32F103C8Tx；对应 STM32F103C(8-B)Tx.xml 存在，含 RAM 20 KB、Flash 64 KB 条目。本项目仍按 C8 官方保证规格设计，不使用同族 CB 的容量。
- 未启动图形界面，未验证新工程生成或实际编译。

## 内部工具实际验证

均使用安装目录内绝对路径调用，没有将 ARM 工具加入系统 PATH。以下命令全部退出码 0。

| 工具 | 参数 | 实际版本 |
| --- | --- | --- |
| arm-none-eabi-gcc.exe | --version | GNU Tools for STM32 14.3.rel1.20251027-0700；GCC 14.3.1 20250623 |
| arm-none-eabi-gdb.exe | --version | GNU gdb 15.2.90.20241229-git |
| make.exe | --version | GNU Make 4.4.1_st_20260330-0700 |
| ninja.exe | --version | 1.13.2 |
| openocd.exe | --version | 0.12.0+dev-00664-g72f14cee6，2026-04-16，STMicroelectronics 内置版本 |
| ST-LINK_gdbserver.exe | --help；--version | 7.14.0 |
| STM32_Programmer_CLI.exe | -h | STM32CubeProgrammer 2.23.0 |
| stlinkserver.exe | --version | stlink-server 2.1.1 |

### 实际工具路径
- D:\download\stm32cubeide\STM32CubeIDE_2.2.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.14.3.rel1.win32_1.0.100.202602081740\tools\bin\arm-none-eabi-gdb.exe
- D:\download\stm32cubeide\STM32CubeIDE_2.2.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.14.3.rel1.win32_1.0.100.202602081740\tools\bin\arm-none-eabi-gcc.exe
- D:\download\stm32cubeide\STM32CubeIDE_2.2.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.stlink-gdb-server.win32_2.2.500.202604010938\tools\bin\ST-LINK_gdbserver.exe
- D:\download\stm32cubeide\STM32CubeIDE_2.2.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.openocd.win32_2.4.500.202604080855\tools\bin\openocd.exe
- D:\download\stm32cubeide\STM32CubeIDE_2.2.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.ninja.win32_1.1.200.202606260906\tools\bin\ninja.exe
- D:\download\stm32cubeide\STM32CubeIDE_2.2.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.make.win32_2.2.200.202604021615\tools\bin\make.exe
- D:\download\stm32cubeide\STM32CubeIDE_2.2.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.cubeprogrammer.win32_2.2.500.202603051304\tools\bin\STM32_Programmer_CLI.exe
- C:\Program Files (x86)\STMicroelectronics\stlink_server\stlinkserver.exe

## ST-Link USB 与驱动

- Get-PnpDevice -PresentOnly：STM32 STLink，Class USBDevice，Status OK。
- 硬件实例：USB\VID_0483&PID_3748\5&288AFDF&0&1。
- PnP ProblemCode：0。
- DriverProvider：STMicroelectronics；DriverVersion：2.2.0.0；Service：WinUSB；INF：oem44.inf。
- 卸载注册表显示 STMicroelectronics STLinkWinUSB 驱动包，版本字段 04/01/2021 2.02。
- Win32_PnPSignedDriver 的 IsSigned 字段返回 False；进一步检查两个 stlink_dbg_winusb.inf 驱动仓库目录中的 STLinkDbgWinUSB_x64.cat，Get-AuthenticodeSignature 均为 Valid，签名者为 STMicroelectronics。记录字段差异，不把 WMI 的单一字段解释为签名失效。

状态：ST-Link USB Verified。

目标状态：Target MCU pending / not verified。USB 枚举不能证明 SWD 已连接或 MCU 可调试。本次没有执行目标连接、复位、读写或下载命令。

## 当前缺失与用户操作

没有发现软件基础环境缺失。真实 STM32F103C8T6 的 SWD 连接仍未验收。

用户仅需按实际硬件引脚定义连接 ST-Link 的 SWDIO、SWCLK、GND 与目标板，并确认正确的 3.3V 供电/参考电压；随后安排最小连接验证。未要求用户重复执行可自动完成的软件检查。

下一步仅建议：进行 STM32F103C8T6 最小连接验证。本次停止，不创建功能工程。

## 后续目标连接验证（2026-10-09）

用户确认已接线后，官方 CLI 以 HOTPLUG 模式连接成功，退出码 0。电压 3.29 V，Device ID 0x410，STM32F101/F102/F103 Medium-density，NVM 64 KB，CPU Cortex-M3。

当前状态：Ready；ST-Link USB Verified；Target MCU Verified（仅最小 SWD 连接识别）。未执行烧录、擦除或功能验证。

详见 stm32f103_swd_connection_2026-10-09.md 和同名 .log。上文目标 pending 描述保留为初次检查历史。
