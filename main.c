#include <stm32f1xx.h>
#include "sys_init.h"

void dummy_delay(unsigned int count) {
    volatile unsigned int _count = count;
    while (_count--)
        ;
}

int main() {
    sys_configure_clock();
    // Enable GPIOC clock
    RCC->APB2ENR |= RCC_APB2ENR_IOPCEN;
    GPIOC->CRH &= ~GPIO_CRH_CNF13;
    GPIOC->CRH |= GPIO_CRH_MODE13_1;
    while (1) {
        GPIOC->BSRR = GPIO_BSRR_BR13;
        dummy_delay(9000000);
        GPIOC->BSRR = GPIO_BSRR_BS13;
        dummy_delay(9000000);
    }
    return 0;
}
