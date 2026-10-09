# STM32F103C8T6 最小 SWD 连接验证

日期：2026-10-09（Asia/Shanghai）。环境当前结论：Ready。

## 本次完成

用户确认目标板已接线后，使用 CubeIDE 内置 STM32CubeProgrammer CLI 2.23.0 完成最小 SWD 识别。没有创建工程或业务代码，没有执行下载、擦除、选项字节修改或显式复位命令。

## 技术实现和测试方法

实际命令（通过 CLI 的绝对安装路径调用）：

```text
STM32_Programmer_CLI.exe -c port=SWD mode=HOTPLUG freq=1000
```

HOTPLUG 模式用于附加到当前目标，不要求复位连接。CLI 输出的 Reset mode: Software reset 是复位模式设置字段，本次没有请求执行复位。只执行连接识别，没有指定额外内存读写命令。

预期：工具退出码 0，识别 Cortex-M3、STM32F1 中容量系列及 64 KB NVM，获得目标电压。

实际：退出码 0，目标识别成功。

| 字段 | 实际输出 |
| --- | --- |
| ST-Link 固件 | V2J37S7 |
| 电压 | 3.29 V |
| 实际 SWD 频率 | 950 kHz（请求 1000 kHz） |
| 连接模式 | Hot Plug |
| Device ID | 0x410 |
| Revision ID | Rev A |
| Device name | STM32F101/F102/F103 Medium-density |
| NVM size | 64 KBytes |
| CPU | Cortex-M3 |

原始输出：stm32f103_swd_connection_2026-10-09.log。

## 验证边界

- ST-Link USB Verified。
- Target MCU Verified：最小 SWD 连接及芯片识别通过。
- 结果与用户声明的 STM32F103C8T6 目标一致，但共享系列 Device ID 和容量不能单独证明完整型号后缀或芯片真伪。
- 只确认目标可经 SWD 访问；尚未验证下载、断点、单步、时钟、GPIO、FreeRTOS 或外设。
- CLI 的 Board: -- 不是连接失败；本次退出码和芯片识别信息证明连接成功。

## 修改文件

新增本报告与原始日志；更新环境验收报告中的当前结论和后续连接记录。没有功能源码。

## 用户需要验证和理解

本次无需用户补做软件检查。应阅读本报告的命令和结果，理解 USB 识别与目标 SWD 识别的区别、HOTPLUG 连接模式、Device ID 的系列含义、64 KB 容量边界。

可独立学习练习：根据日志指出哪些字段证明 USB 探针已识别，哪些字段证明目标 MCU 可访问；无需改动硬件或运行额外命令。

## 风险与问题

本次未发现连接错误。产品资源仍按 STM32F103C8T6 官方保证的 64 KB Flash、20 KB RAM 设计。未验证项目编译与下载，不把最小连接通过等同于全部功能测试通过。

## 下一步建议

等待导师安排 STM32F103C8T6 最小 HAL 工程创建与空工程编译任务；本次停止，不自行创建工程。
