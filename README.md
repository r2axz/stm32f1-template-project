# stm32f1-template-project

stm32f1-template-project is a Makefile based template for bare metal stm32f1 projects.

Currently it's configured to support stm32f103c8t6 MCU found on the "Blue Pill" boards. Switching to another MCU requires to change the linker script and possibly startup code.

Note: this project does not support C++;

## TODO

- add include files;
- get rid of __libc_init_array;
