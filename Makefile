# General Target Settings
TARGET = stm32f1-template-project
SRCS = main.c

# Toolchain & Utils
CC		= arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE 	= arm-none-eabi-size
STFLASH	= st-flash
STUTIL	= st-util

# STM32Cube Path
STM32CUBE 			= ${STM32CUBE_PATH}
STM32_STARTUP 		= $(STM32CUBE)/Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/startup_stm32f103xb.s
STM32_SYSINIT 		= $(STM32CUBE)/Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/system_stm32f1xx.c
STM32_LDSCRIPT 		= $(STM32CUBE)/Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/linker/STM32F103XB_FLASH.ld

STM32_INCLUDES	+= -I$(STM32CUBE)/Drivers/CMSIS/Core/Include
STM32_INCLUDES	+= -I$(STM32CUBE)/Drivers/CMSIS/Core_A/Include
STM32_INCLUDES	+= -I$(STM32CUBE)/Drivers/CMSIS/Device/ST/STM32F1xx/Include

DEFINES 		= -DSTM32F103xB
CPUFLAGS 		= -mthumb -mcpu=cortex-m3
WARNINGS 		= -Wall -pedantic
OPTIMIZATION 	= -O3
DEBUG 			= -ggdb

CFLAGS = $(DEFINES) $(STM32_INCLUDES) $(CPUFLAGS) $(WARNINGS) $(OPTIMIZATION) $(DEBUG) 
LDFLAGS = $(CPUFLAGS) -T$(STM32_LDSCRIPT) --specs=nosys.specs

BUILD_DIR = build
OBJS += $(SRCS:%.c=$(BUILD_DIR)/%.o)
OBJS += $(STM32_SYSINIT:%.c=$(BUILD_DIR)/%.o)
DEPS += $(SRCS:%.c=$(BUILD_DIR)/%.d)
DEPS += $(STM32_SYSINIT:%.c=$(BUILD_DIR)/%.d)
STARTUP += $(STM32_STARTUP:%.s=$(BUILD_DIR)/%.o)

all: $(TARGET).hex size

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -Oihex $(TARGET).elf $(TARGET).hex

$(TARGET).elf: $(OBJS) $(STARTUP)
	$(CC) $(LDFLAGS) $^ -o $@

$(OBJS): $(BUILD_DIR)/%.o: %.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(DEPS): $(BUILD_DIR)/%.d: %.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) $< -MM -MT $(@:.d=.o) > $@

$(STARTUP): $(BUILD_DIR)/%.o: %.s
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: flash
flash: all
	$(STFLASH) --format ihex write $(TARGET).hex

.PHONY: size
size:
	$(SIZE) $(TARGET).elf

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: distclean
distclean: clean
	rm -rf $(TARGET).elf $(TARGET).hex

-include $(DEPS)