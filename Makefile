# General Target Settings
TARGET = stm32f1-template-project
SRCS = main.c

# Toolchain & Utils
CC		= arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE 	= arm-none-eabi-size
STFLASH	= st-flash
STUTIL	= st-util
OPENOCD	= openocd

# STM32Cube Path
STM32CUBE 			= ${STM32CUBE_PATH}
STM32_STARTUP 		= startup_stm32f103xb.s
STM32_STARTUP_PATH 	= $(STM32CUBE)/Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc
STM32_SYSINIT		= system_stm32f1xx.c
STM32_SYSINIT_PATH 	= $(STM32CUBE)/Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates
STM32_LDSCRIPT 		= $(STM32CUBE)/Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/linker/STM32F103XB_FLASH.ld

STM32_INCLUDES	+= -I$(STM32CUBE)/Drivers/CMSIS/Core/Include
STM32_INCLUDES	+= -I$(STM32CUBE)/Drivers/CMSIS/Core_A/Include
STM32_INCLUDES	+= -I$(STM32CUBE)/Drivers/CMSIS/Device/ST/STM32F1xx/Include

DEFINES = -DSTM32F103xB
CPUFLAGS = -mthumb -mcpu=cortex-m3
WARNINGS = -Wall -pedantic
OPTIMIZATION = -O3
DEBUG = -ggdb

CFLAGS = $(DEFINES) $(STM32_INCLUDES) $(CPUFLAGS) $(WARNINGS) $(OPTIMIZATION) $(DEBUG) 
LDFLAGS = $(CPUFLAGS) -T$(STM32_LDSCRIPT) --specs=nosys.specs

OBJS = $(SRCS:.c=.o) $(STM32_STARTUP:.s=.o) $(STM32_SYSINIT:.c=.o)
all: $(TARGET).hex size

$(TARGET).hex: $(TARGET).elf
	@$(OBJCOPY) -Oihex $(TARGET).elf $(TARGET).hex

$(TARGET).elf: $(OBJS)
	@$(CC) $(LDFLAGS) $^ -o $@

$(STM32_STARTUP:.s=.o): $(STM32_STARTUP_PATH)/$(STM32_STARTUP)
	@$(CC) -c $< -o $@

$(STM32_SYSINIT:.c=.o): $(STM32_SYSINIT_PATH)/$(STM32_SYSINIT)
	@$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@

.PHONY: flash
flash: all
	@$(STFLASH) --format ihex write $(TARGET).hex

.PHONY: size
size:
	@$(SIZE) $(TARGET).elf

.PHONY: clean
clean:
	rm -f $(OBJS)
