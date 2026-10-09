# ICM-01 项目进度

更新日期：2026-10-09（Asia/Shanghai）。

## 当前阶段

开发工具链验证；尚未进入业务功能开发。

| 任务 | 完成内容 | Software Verification | Hardware Verification | 学习状态 |
| --- | --- | --- | --- | --- |
| DEV-01 最小HAL工程创建与构建 | 精确 STM32F103C8T6；CubeMX 生成 HAL 工程；CubeIDE Debug 编译/链接；ELF 生成 | Passed | Pending | 待用户学习与导师验收 |

工程：firmware/icm01_stm32。

配置：HSI 8 MHz，Serial Wire；不启用业务 GPIO、UART、ADC、DMA、I2C、SPI、TIM PWM、RTOS、USB 或 CAN。CubeMX 的 GPIOA 时钟初始化用于系统/SWD 配置，没有业务引脚操作。

构建：0 errors、0 warnings；text 3592 B、data 12 B、GNU size 的 bss 汇总 1572 B。Flash 3604/65536 B；RAM 链接预留 1584/20480 B（包含默认堆栈及对齐）。

报告：[DEV-01 首次构建](test_reports/stm32_minimal_build_2026-10-09.md)。

## 既有硬件验证的边界

之前已完成 ST-Link USB 和目标最小 SWD 识别，Device ID 0x410、NVM 64 KB、电压约 3.29 V。这不代表 DEV-01 生成的固件已经下载或运行。本任务 Hardware Verification 保持 Pending。

## 尚未验证

- 本工程下载与上电运行。
- main 断点、单步调试和运行时钟。
- 实际栈/堆使用量及所有业务外设。

## 下一项建议

由导师安排最小工程下载与 main 断点/单步验证。未自行开始。
