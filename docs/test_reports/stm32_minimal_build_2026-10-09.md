# DEV-01：STM32F103C8T6 最小 HAL 工程创建与首次构建

日期：2026-10-09（Asia/Shanghai）。

Software Verification = Passed

Hardware Verification = Pending

学习状态：待用户学习与导师验收；没有标记 Mastered。

## 范围与结果

真正使用 CubeMX 生成 CubeIDE HAL 工程，再使用 CubeIDE 内置工具完成首次 Debug 编译与链接。未创建业务代码，未连接/烧录/擦除 MCU。

仓库最初没有 README、进度文档、源码或 .ioc，只有前次环境与 SWD 记录；已读取这些记录并检查 Git 状态。工程没有重复实现。

## 版本和配置

| 项目 | 实际结果 |
| --- | --- |
| 完整 MCU 型号 | STM32F103C8T6，LQFP48；.ioc Mcu.CPN 和 CubeMX 日志确认 |
| 工程名与位置 | icm01_stm32；D:\Documents\ChatGPT\嵌入式项目\firmware\icm01_stm32 |
| CubeIDE | 2.2.0 |
| CubeMX | 6.11.1；DB.6.0.111 |
| Firmware Package | STM32CubeF1 V1.8.5；.ioc LastFirmware=false |
| HAL | V1.1.9（驱动源码版本宏 0x01 / 0x01 / 0x09 / 0x00） |
| ARM GCC | GNU Tools for STM32 14.3.rel1.20251027-0700；14.3.1 20250623 |
| SYS Debug | Serial Wire；PA13 SWDIO，PA14 SWCLK |
| 系统时钟 | 内部 HSI 8 MHz；SYSCLK/AHB/APB1/APB2 均为 8 MHz；不配置 HSE 或 PLL |
| HAL 时基 | SysTick |
| 业务外设与中间件 | 未启用；Mcu.IP 仅 NVIC/RCC/SYS |
| 构建配置 | Debug，Cortex-M3，Thumb，软浮点，-O0，-g3，USE_HAL_DRIVER |
| 链接容量 | Flash 64 KB；RAM 20 KB |

STM32F103xB 是 ST CMSIS 对 C8/CB 共用的中容量编译宏，不代表选择了 CB 型号或采用 128 KB Flash。精确项目目标为 C8，生成的启动文件和链接脚本均为 C8。

CubeMX 自动生成 MX_GPIO_Init，只开启 GPIOA 时钟，没有 HAL_GPIO_Init/WritePin/TogglePin 或 LED 功能。驱动中存在 HAL DMA 源码是 HAL 基础依赖，.ioc 没有启用 DMA 或配置 DMA 通道。

## 官方固件包获取和生成

本机初始没有 F1 固件包。本次仅新增固定 V1.8.5，来源：

https://github.com/STMicroelectronics/STM32CubeF1/tree/v1.8.5

下载地址：

https://codeload.github.com/STMicroelectronics/STM32CubeF1/zip/refs/tags/v1.8.5

下载归档 SHA256：EFE9467F9155C99FF3B46C636396B45E5125CDB39EBBACF165B4DE771C6A478D。

该标签归档已经包含 HAL/CMSIS，无需另行获取或混用不同版本的子模块。没有升级任何已有固件包。

CubeMX 自定义路径未被下载检查识别，因此将同一官方包新增到标准位置 C:\Users\Administrator\STM32Cube\Repository\STM32Cube_FW_F1_V1.8.5，保持 DefaultFWLocation=true，并固定 V1.8.5。未覆盖已有包；不需要 ST 登录凭据。

按 MCU 型号加载初始配置，设置 Serial Wire 并交由 CubeMX 官方生成器生成全部 Core/Drivers、启动文件、链接脚本和 CubeIDE 元数据。没有手写或修改生成的 C、汇编和链接逻辑，所有 USER CODE 区域保留。

生成入口为 tools/dev01_generate.mxscript。使用本机 UM1718 Rev 44 的 -q 无界面脚本模式；project generate 返回 OK。

## 构建和自动检查

实际执行：

```powershell
.\tools\build_stm32.ps1
python .\tools\verify_dev01.py
```

脚本使用 CubeIDE stm32cubeidec.exe 的 org.eclipse.cdt.managedbuilder.core.headlessbuild，导入仓库内工程，构建 icm01_stm32/Debug。临时工作区在 .cache/cubeide_dev01_workspace，不修改日常 IDE 工作区或系统 PATH。

实际结果：构建退出码 0；Build Finished. 0 errors, 0 warnings。编译器和链接器均成功，生成 icm01_stm32.elf。

验收脚本的 19 项检查全部通过，退出码 0，包含：精确型号、固定包版本、SWD 保留、无业务外设、HAL/启动/链接文件存在、HSI 8 MHz、空主循环、64 KB/20 KB 限制、真实 ARM ELF 与 Flash 内 Thumb 入口，以及实际构建零错误/警告。

arm-none-eabi-readelf -h：ELF32、little-endian、ARM、EABI5 soft-float，入口 0x080002d9，位于 64 KB Flash。

## Flash/RAM 占用

GNU arm-none-eabi-size 的实际结果：

```text
text    data    bss     dec     hex
3592    12      1572    5176    1438
```

| 占用口径 | 字节 | 芯片预算 | 占比 |
| --- | --- | --- | --- |
| Flash：text + data 初值 | 3604 | 65536 | 5.50% |
| RAM：data + GNU size bss 汇总 | 1584 | 20480 | 7.73% |

size -A 的具体 RAM 段为：.data 12 B；.bss 32 B；._user_heap_stack 1540 B（默认堆 512 B、栈 1024 B、对齐 4 B）。因此普通静态变量为 44 B，另外预留 1540 B；RAM 合计 1584 B。没有添加动态分配业务代码，未修改默认堆栈或链接脚本。

这是链接资源预算，不是运行时最大栈/堆使用量。ELF 文件包含调试信息，其磁盘大小不等于 Flash 占用。

## 输出文件

位于 firmware/icm01_stm32/Debug/：

- icm01_stm32.elf：643204 B。
- icm01_stm32.map：244523 B。
- icm01_stm32.list：100856 B。

构建未默认生成 BIN/HEX，本次没有为此修改配置。

ELF SHA256：E61BCA5B37F247B263A90E31495C8CFAE703568ECFF5EE724218AE76EFAAD044。

原始日志（本地保存，Git 忽略）：docs/test_reports/dev01_logs/cubemx_generate.log、cubeide_debug_build.log、verification.log。

## 关键生成代码与学习重点

1. Core/Src/main.c:64 为 main；:74 调用 HAL_Init，:81 调用 SystemClock_Config，:95 开始空 while (1)。理解初始化顺序和主循环。本次没有业务逻辑。
2. Core/Src/main.c:108 定义 SystemClock_Config；:129 选择 RCC_SYSCLKSOURCE_HSI。理解内部 8 MHz 时钟、总线分频和 Flash 延迟。
3. Core/Src/stm32f1xx_hal_msp.c:77 的 __HAL_AFIO_REMAP_SWJ_NOJTAG 保留 SWD、关闭 JTAG。理解 PA13/PA14 不能作为本阶段业务 GPIO。

HAL_Init 的库实现位于 Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c:142，供进一步阅读。

小练习：在纸上画出 HAL_Init -> SystemClock_Config -> MX_GPIO_Init -> while (1) 的调用顺序，并使用 size 段值独立算出 3604 B Flash 和 1584 B RAM。无需改动源码或硬件。

## 未验证与用户操作

尚未验证本工程下载、运行、main 断点、单步、运行时实际时钟、实际堆栈使用量或任何外设。之前的 SWD 识别不能替代本固件运行验收。

本任务没有需要用户补做的软件检查。后续下载与调试必须等待导师安排新任务。

## Git 与风险

下载缓存、IDE 工作区、构建产物和诊断日志已排除；不提交 ELF、编译缓存或用户 IDE 临时文件。第三方驱动附带的许可证文件保留。

本机尚未配置 Git 提交姓名和邮箱，未擅自填写或修改全局身份。本任务提交等待用户提供身份；工程和验收结果均已保存。

## 下一步建议

由导师安排最小工程下载与 main 断点/单步验证；本次不执行。
