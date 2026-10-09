"""DEV-01 checks: target identity, minimal configuration and built ARM ELF."""
from pathlib import Path
import re
import struct
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / 'firmware' / 'icm01_stm32'

def check(condition, message):
    if not condition:
        raise SystemExit('FAIL: ' + message)
    print('PASS: ' + message)

settings = dict(line.split('=', 1) for line in (PROJECT / 'icm01_stm32.ioc').read_text().splitlines() if '=' in line)
check(settings['Mcu.CPN'] == 'STM32F103C8T6', 'exact MCU STM32F103C8T6')
check(settings['ProjectManager.FirmwarePackage'] == 'STM32Cube FW_F1 V1.8.5' and settings['ProjectManager.LastFirmware'] == 'false', 'firmware package fixed at V1.8.5')
check(settings['SYS.Debug'] == 'Serial_Wire' and settings['PA13.Signal'] == 'SYS_JTMS-SWDIO' and settings['PA14.Signal'] == 'SYS_JTCK-SWCLK', 'SWD on PA13/PA14')
ips = {v for k, v in settings.items() if re.fullmatch(r'Mcu.IP\d+', k)}
check(ips == {'NVIC', 'RCC', 'SYS'}, 'no application peripherals or middleware enabled')
for filename in ['Core/Startup/startup_stm32f103c8tx.s', 'Core/Inc/stm32f1xx_hal_conf.h', 'Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c', 'STM32F103C8TX_FLASH.ld']:
    check((PROJECT / filename).is_file(), filename + ' exists')
ET.parse(PROJECT / '.project')
cproject = ET.parse(PROJECT / '.cproject')
check(any(o.get('name') == 'MCU' and o.get('value') == 'STM32F103C8Tx' for o in cproject.iter('option')), 'CubeIDE target metadata is C8')
main = (PROJECT / 'Core/Src/main.c').read_text()
check('HAL_Init();' in main and 'SystemClock_Config();' in main, 'HAL and clock initialization called')
check('RCC_SYSCLKSOURCE_HSI' in main and 'RCC_HSI_ON' in main and 'RCC_PLL_NONE' in main and main.count('RCC_HCLK_DIV1') == 2 and 'RCC_SYSCLK_DIV1' in main, 'HSI with undivided system/AHB/APB clocks; no PLL configuration')
check(settings['RCC.APB1Freq_Value'] == '8000000' and settings['RCC.APB2Freq_Value'] == '8000000', 'clock configuration is 8 MHz')
loop = re.search(r'while \(1\)\s*\{(.*?)\}', main, re.S)
check(loop is not None and not re.sub(r'/\*.*?\*/', '', loop.group(1), flags=re.S).strip(), 'application while loop is empty')
check('HAL_GPIO_Init(' not in main and 'HAL_GPIO_WritePin(' not in main and 'HAL_GPIO_TogglePin(' not in main, 'no GPIO business logic')
msp = (PROJECT / 'Core/Src/stm32f1xx_hal_msp.c').read_text()
check('__HAL_AFIO_REMAP_SWJ_NOJTAG();' in msp, 'generated MSP preserves SWD')
linker = (PROJECT / 'STM32F103C8TX_FLASH.ld').read_text()
check('LENGTH = 64K' in linker and 'LENGTH = 20K' in linker, 'linker limits Flash/RAM to 64 KB/20 KB')
elf = (PROJECT / 'Debug/icm01_stm32.elf').read_bytes()
check(elf[:7] == b'\x7fELF\x01\x01\x01' and struct.unpack_from('<H', elf, 18)[0] == 40, 'ELF32 little-endian ARM executable')
entry = struct.unpack_from('<I', elf, 24)[0]
check(0x08000000 <= (entry & ~1) < 0x08010000 and entry & 1, 'Thumb entry lies in 64 KB Flash')
log = (ROOT / 'docs/test_reports/dev01_logs/cubeide_debug_build.log').read_text(encoding='utf-8-sig')
check('0 errors, 0 warnings' in log and 'Finished building target: icm01_stm32.elf' in log, 'first build compiled and linked with no errors or warnings')
print('DEV-01 software checks passed. Hardware verification remains pending.')
