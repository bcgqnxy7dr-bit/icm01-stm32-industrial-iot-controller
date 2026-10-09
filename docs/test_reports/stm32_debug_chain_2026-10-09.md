# DEV-02：STM32 最小工程编译、下载、运行与源码调试闭环

日期：2026-10-09（Asia/Shanghai）。硬件与软件验证结果：Passed；Theory Assessment = Pending。Git 提交和推送在这些实际测试通过后执行，最终提交号以仓库历史为准。

## 环境与开始前状态

MCU：STM32F103C8T6 最小系统板，64 KB Flash / 20 KB RAM；ST-LINK/V2，固件 V2J37S7。CubeIDE 2.2.0、CubeMX 6.11.1、GCC 14.3.1、HAL 1.1.9 / STM32CubeF1 V1.8.5；ST-LINK GDB Server 7.14.0，GDB 15.2.90.20241229-git，CubeProgrammer 2.23.0。

开始时 main 分支、工作区干净，origin 为 https://github.com/bcgqnxy7dr-bit/icm01-stm32-industrial-iot-controller.git，基线提交 bbc0257。已阅读 README、project_status、相关主程序和启动文件，没有覆盖用户修改。

Windows PnP：STM32 STLink，Status OK。官方 CLI SWD 查询：Device ID 0x410，Cortex-M3，中容量 STM32F101/F102/F103，64 KB NVM，初检 3.29 V、下载时 3.30 V。请求 SWD 1000 kHz，CLI 实际 950 kHz。共享系列 ID 不单独证明型号后缀或真伪。

## 重新构建与 ELF

使用现有 CubeIDE headless builder 的 -cleanBuild icm01_stm32/Debug，真正清理后重编译，不是只检查现有 ELF。

构建退出码 0；0 errors、0 warnings；编译和链接成功。text 3592 B，data 12 B，GNU size bss 汇总 1572 B，与 DEV-01 完全一致。

Flash：3604 / 65536 B（5.50%）。RAM 链接预算：1584 / 20480 B（7.73%，包括默认堆栈预留和对齐），不是运行时最大栈测量。

ELF：firmware/icm01_stm32/Debug/icm01_stm32.elf。

SHA256：E61BCA5B37F247B263A90E31495C8CFAE703568ECFF5EE724218AE76EFAAD044，与 DEV-01 记录一致。ELF LOAD 段实际 Flash 文件数据合计 3604 B。

## 下载与校验

实际通过 CubeIDE 内置官方 CLI 执行（使用安装目录内绝对路径，不改系统 PATH）：

```text
STM32_Programmer_CLI.exe -c port=SWD mode=NORMAL freq=1000 -d firmware/icm01_stm32/Debug/icm01_stm32.elf -v
```

结果：退出码 0；File download complete；Download verified successfully。

起始写入地址 0x08000000；实际可加载字节数 3604 B（CLI 显示四舍五入的 3.52 KB）。CLI 只擦除固件覆盖的内部页/扇区 [0 3]，没有 Mass Erase。未修改 Option Bytes、读保护、Flash 保护或 Boot 配置。

## 真实复位与源码调试

使用官方 ST-LINK GDB Server，SWD 模式，请求 1000 kHz，端口 61234；CubeProgrammer 路径由本机 CubeIDE 内部定位。GDB 加载本次 ELF 的源码符号，不重新下载。

可复现入口：tools/debug_stm32.ps1；实际命令序列：tools/verify_dev02.gdb。该入口会复位目标，要求目标已烧录与本地 Debug ELF 一致的固件，不自动烧录。

| 验证 | 真实结果 |
| --- | --- |
| 软件系统复位 | monitor reset 返回 STM32 Successfully completed reset operation (System reset) |
| Reset_Handler | 硬件断点捕获；PC 0x080002D8，startup_stm32f103c8tx.s:64，下一指令调用 SystemInit |
| C 运行时初始化 | __libc_init_array 内临时断点实际命中，PC 0x08000D88；此前启动汇编完成 .data 复制与 .bss 清零，观察 uwTick=0 |
| main 断点 | Breakpoint 2 实际命中 main.c:74；PC 0x08000150 |
| HAL_Init | step 进入 stm32f1xx_hal.c:152，next 到 :157，finish 返回 main.c:81，返回值 HAL_OK；uwTickPrio=15 |
| SystemClock_Config | step 进入 main.c:110，next 到 :111 和 :116，finish 返回 main.c:88 |
| while (1) | 临时断点命中 main.c:95，PC 0x0800015C |
| 指令单步 | 0x0800015C 的 nop -> 0x0800015E 的 b.n -> 0x0800015C，实际返回空循环 |
| Fault 状态 | CFSR=0x00000000 |
| 正常脱离 | 删除断点、detach 成功；目标获释运行，结束本次服务进程 |

真实观察到 Reset_Handler -> 启动初始化 -> __libc_init_array -> main -> HAL_Init -> SystemClock_Config -> 空 while(1)。没有伪造断点或以源文件存在代替运行验证。

## 时钟验证与发现

最终 SystemCoreClock=8000000。RCC_CR=0x00008383：HSI 开启且就绪，HSE/PLL 未开启；RCC_CFGR=0x00000000：HSI 为系统时钟，各总线分频为 1。结果与 .ioc 的 HSI 8 MHz 配置一致。

发现生成模板 Core/Src/system_stm32f1xx.c:141 的静态初值为 SystemCoreClock=16000000。GDB 在 C 运行时初始化阶段确实读到 16000000；这只是变量初值，不代表硬件已切换到 16 MHz。

HAL_Init 后、SystemClock_Config 前，SysTick LOAD 实读 15999；SystemClock_Config 后 LOAD 为 7999，SystemCoreClock 更新为 8000000。按 HSI 8 MHz 推算，初期时基存在短暂偏差；本次没有用外部仪器测量该间隔。该问题需要导师评估，按任务边界保留生成源码，不主动修复或更改时钟架构。

## 实际调试问题与处理

1. 首次脚本直接复位/暂停后读 PC，GDB 缓存仍显示原 main 循环位置；寄存器位运算还因类型未显式转换失败。没有把失败尝试算作通过。修复：在 Reset_Handler 设置硬件断点，复位后刷新寄存器缓存，并明确转换 PC 类型。复验捕获真实复位入口。
2. 中文仓库路径使 GDB/BFD 在 detach 时重开 ELF 提示路径警告。修复：启动器将同一仓库临时映射至空闲 ASCII 盘符；工程没有移动或复制。最终运行无该警告，finally 自动释放别名并停止本次服务。
3. 当前 GDB 未编入 Python 脚本支持，采用原生 GDB 命令、条件断言和 PowerShell 输出检查。未安装或升级调试器。

## 证据和安全边界

原始日志保存在 .cache/dev02/build.log、flash.log、gdb.log、server.stdout.log、runner.log，全部由现有 .gitignore 排除，不上传设备序列号或原始日志。

复验脚本退出成功并出现 DEV02_DEBUG_CHECKS_PASSED；入口进一步检查 main 断点、HAL/时钟源码帧及 HAL_OK。git diff -- firmware 为空：没有修改业务代码、CubeMX 配置、启动文件、链接脚本或驱动。

## 尚未验证

独立断电上电启动、长时间运行、外部仪器时钟测量、实际最大堆栈占用、启动阶段临时时基的实测间隔、所有正式外设及业务功能。本报告只验收本次最小开发闭环。

## 用户需要理解

1. ELF 符号用于源码调试，Flash 占用与 ELF 磁盘大小不同。
2. 下载校验与程序运行是两项不同验证；只擦除必要 Flash 页。
3. Reset_Handler 负责运行环境初始化，再进入 main。
4. step/next/finish 与硬件断点的职责不同。
5. SystemCoreClock 是软件变量，应结合 RCC 和初始化阶段理解。

重点阅读：Core/Startup/startup_stm32f103c8tx.s:62；Core/Src/main.c:64 与 :108；Core/Src/system_stm32f1xx.c:141。

小练习：根据本报告 PC 记录画出启动和初始化调用顺序，解释为何 0x0800015C -> 0x0800015E -> 0x0800015C 能证明进入空循环。无需改代码。

## 下一步

开始第一个正式外设实验 GPIO。仅建议，等待导师安排。
