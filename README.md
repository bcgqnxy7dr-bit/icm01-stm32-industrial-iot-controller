# ICM-01

学习 STM32 产品研发流程的嵌入式项目。当前已完成 DEV-01 最小 HAL 工程构建和 DEV-02 下载、复位、运行与源码调试闭环，没有业务功能。

- 目标：STM32F103C8T6，Flash 64 KB，RAM 20 KB。
- 工程：firmware/icm01_stm32；CubeMX 6.11.1 生成，CubeIDE 2.2.0 构建。
- 时钟：内部 HSI 8 MHz；调试：Serial Wire，PA13/PA14。
- 固件包：STM32CubeF1 V1.8.5；HAL V1.1.9。已将必需驱动复制到工程，构建不依赖外部固件包目录。
- 状态：[项目进度](docs/project_status.md)。
- 结果：[DEV-01 测试报告](docs/test_reports/stm32_minimal_build_2026-10-09.md)。

## 目录

```text
firmware/icm01_stm32/  CubeMX 配置、Core、Drivers、启动文件及 CubeIDE 元数据
 tools/                构建、配置生成和本任务验证脚本
 docs/                 项目进度与测试记录
```

## Debug 构建与检查

在仓库根目录的 PowerShell 中执行：

```powershell
.\tools\build_stm32.ps1
python .\tools\verify_dev01.py
```

构建脚本自动查找已安装的 CubeIDE 2.2.0，使用独立的 .cache/cubeide_dev01_workspace，不修改系统 PATH 或用户日常 IDE 工作区。也可通过 -CubeIDEPath 指定包含 stm32cubeidec.exe 的目录。

输出位于 firmware/icm01_stm32/Debug；构建产物、下载缓存和 IDE 工作区由 .gitignore 排除，不提交。

## 重新生成

使用 STM32CubeMX 6.11.1 打开 firmware/icm01_stm32/icm01_stm32.ioc，保持固定固件包 STM32Cube FW_F1 V1.8.5 和 STM32CubeIDE 工具链。

无界面重生成命令（从仓库根目录运行）：

```powershell
& 'D:\cubemx\jre\bin\java.exe' '-Dfile.encoding=UTF-8' -jar 'D:\cubemx\STM32CubeMX.exe' -q 'tools/dev01_generate.mxscript'
```

本机固定固件包在 C:\Users\Administrator\STM32Cube\Repository\STM32Cube_FW_F1_V1.8.5，来源为 [ST 官方 v1.8.5 标签](https://github.com/STMicroelectronics/STM32CubeF1/tree/v1.8.5)。没有安装或升级其他固件包。

DEV-02 已完成目标下载与源码调试；结果见 [调试链报告](docs/test_reports/stm32_debug_chain_2026-10-09.md)。

可复现源码调试入口：tools/debug_stm32.ps1（会复位目标；不自动烧录，须确保板上固件与本地 Debug ELF 一致）。等待导师明确安排下一任务。
