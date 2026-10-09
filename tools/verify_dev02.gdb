set pagination off
set confirm off
set remotetimeout 10
file firmware/icm01_stm32/Debug/icm01_stm32.elf
target remote localhost:61234
hbreak *Reset_Handler
monitor reset
monitor halt
maintenance flush register-cache
echo === RESET_HANDLER ===\n
info registers pc
x/i $pc
if (((unsigned int)$pc & 0xfffffffe) != ((unsigned int)&Reset_Handler & 0xfffffffe))
  echo FAIL: reset PC is not Reset_Handler\n
  quit 1
end
break main
tbreak __libc_init_array
continue
echo === C_RUNTIME_INIT ===\n
info symbol $pc
print SystemCoreClock
print uwTick
continue
echo === MAIN_BREAKPOINT ===\n
frame
info registers pc
step
echo === STEP_INTO_HAL_INIT ===\n
frame
next
finish
echo === HAL_INIT_RETURNED ===\n
frame
print uwTickPrio
printf "SysTick_LOAD_before_clock=%u\n", *(unsigned int*)0xe000e014
step
echo === STEP_INTO_CLOCK_CONFIG ===\n
frame
next
next
finish
echo === CLOCK_CONFIG_RETURNED ===\n
printf "SysTick_LOAD_after_clock=%u\n", *(unsigned int*)0xe000e014
frame
print SystemCoreClock
printf "RCC_CR=0x%08x\n", *(unsigned int*)0x40021000
printf "RCC_CFGR=0x%08x\n", *(unsigned int*)0x40021004
if SystemCoreClock != 8000000
  echo FAIL: runtime clock differs from 8 MHz\n
  quit 1
end
if ((*(unsigned int*)0x40021000 & 0x03030003) != 3)
  echo FAIL: HSI/HSE/PLL status mismatch\n
  quit 1
end
if (*(unsigned int*)0x40021004 & 0xfffc)
  echo FAIL: clock source or bus dividers mismatch\n
  quit 1
end
tbreak main.c:95
continue
echo === MAIN_WHILE_LOOP ===\n
frame
info registers pc
x/2i $pc
set $loop_pc = $pc
stepi
info registers pc
stepi
info registers pc
if $pc != $loop_pc
  echo FAIL: empty while loop PC changed unexpectedly\n
  quit 1
end
printf "SystemCoreClock=%u\n", SystemCoreClock
printf "CFSR=0x%08x\n", *(unsigned int*)0xe000ed28
if (*(unsigned int*)0xe000ed28 != 0)
  echo FAIL: fault status is nonzero\n
  quit 1
end
echo === DEV02_DEBUG_CHECKS_PASSED ===\n
delete breakpoints
detach
quit
