# ICM-01 项目进度

更新日期：2026-10-09（Asia/Shanghai）。

## 当前阶段

开发工具链验证；尚未进入业务功能开发。

| 任务 | 完成内容 | Software Verification | Hardware Verification | Theory Assessment | 学习状态 |
| --- | --- | --- | --- | --- | --- |
| DEV-01 最小HAL工程创建与构建 | 精确 STM32F103C8T6；CubeMX 生成 HAL 工程；CubeIDE Debug 编译/链接；ELF 生成 | Passed | Pending | Pending | 待用户学习与导师验收 |
| DEV-02 编译、下载、运行与源码调试闭环 | 重构建、下载校验、复位启动链、main 断点、单步、HSI 运行值验证 | Passed | Passed | Pending | 待导师理论验收 |

工程：firmware/icm01_stm32。

配置：HSI 8 MHz，Serial Wire；不启用业务 GPIO、UART、ADC、DMA、I2C、SPI、TIM PWM、RTOS、USB 或 CAN。CubeMX 的 GPIOA 时钟初始化用于系统/SWD 配置，没有业务引脚操作。

构建：0 errors、0 warnings；text 3592 B、data 12 B、GNU size 的 bss 汇总 1572 B。Flash 3604/65536 B；RAM 链接预留 1584/20480 B（包含默认堆栈及对齐）。

报告：[DEV-01 首次构建](test_reports/stm32_minimal_build_2026-10-09.md)。

## 既有硬件验证的边界

之前已完成 ST-Link USB 和目标最小 SWD 识别，Device ID 0x410、NVM 64 KB、电压约 3.29 V。DEV-01 当时未进行下载，历史状态保留 Pending。DEV-02 已实际下载并通过复位、源码单步和空循环运行验证，Hardware Verification = Passed；Theory Assessment = Pending。

## 尚未验证

- 独立断电上电启动与长时间运行。
- 外部仪器时钟测量及启动阶段临时时基的实测间隔。
- 实际栈/堆使用量及所有业务外设。

## 下一项建议

开始第一个正式外设实验 GPIO。仅建议，未自行开始。

## DEV-02 证据与待评估项

报告：[下载与调试链](test_reports/stm32_debug_chain_2026-10-09.md)。main 断点 PC=0x08000150；while 循环 PC=0x0800015C；SystemCoreClock=8000000，RCC 配置确认 HSI 8 MHz。

生成模板的 SystemCoreClock 静态初值为 16000000，时钟配置后更新为 8000000。初始化前后 SysTick LOAD 分别为 15999/7999；临时时基偏差待导师评估，本次不改生成源码。
