# General Target Settings
TARGET = stm32f1-template-project
SRCS = main.c system_init.c

# Toolchain & Utils
CC		= arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE 	= arm-none-eabi-size
STFLASH	= st-flash
STUTIL	= st-util
OPENOCD	= openocd

STARTUP = stm32/startup/startup_stm32f103xb.s
LDSCRIPT = stm32/linker/STM32F103XB_FLASH.ld

CFLAGS = -mthumb -mcpu=cortex-m3 -Wall -pedantic -O3 -ggdb
LDFLAGS = -T$(LDSCRIPT) --specs=nosys.specs

BUILD_DIR = build
OBJS = $(SRCS:.c=.o) $(STARTUP:.s=.o)

all: $(TARGET).hex size

$(TARGET).hex: $(TARGET).elf
	@$(OBJCOPY) -Oihex $(TARGET).elf $(TARGET).hex

$(TARGET).elf: $(OBJS)
	@$(CC) $(LDFLAGS) $^ -o $@

%.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	@$(CC) $(AFLAGS) -c $< -o $@

.PHONY: flash
flash: all
	@$(STFLASH) --format ihex write $(TARGET).hex

.PHONY: size
size:
	@$(SIZE) $(TARGET).elf

.PHONY: clean
clean:
	rm -f $(OBJS)
