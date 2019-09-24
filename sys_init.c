#include <stm32f1xx.h>
#include "sys_init.h"

const uint16_t HseStartupTimeout = 0xFFFF; // ~ 8ms @ 8MHz

int sys_configure_clock() {
    uint16_t timeout = HseStartupTimeout;
    // Enable HSE clock source
    RCC->CR |= RCC_CR_HSEON;
    // Wait for HSE to start
    while (!(RCC->CR & RCC_CR_HSERDY) && timeout--);
    // Cannot start HSE
    if (!timeout) {
        return -1;
    }
    // Enable flash prefetch
    FLASH->ACR |= FLASH_ACR_PRFTBE;
    // Set flash latency to 2 wait states since we're going for 72MHz
    FLASH->ACR |= FLASH_ACR_LATENCY_2;
    // Set AHB to SYSCLK
    RCC->CFGR |= RCC_CFGR_HPRE_DIV1;
    // Set APB2 (high speed) to HCLK
    RCC->CFGR |= RCC_CFGR_PPRE2_DIV1;
    // Set APB1 (low speed) to HCLK/2
    RCC->CFGR |= RCC_CFGR_PPRE1_DIV2;
    // Reset PLL related bits
    RCC->CFGR &= ~(RCC_CFGR_PLLSRC | RCC_CFGR_PLLXTPRE | RCC_CFGR_PLLMULL);
    // Set PLL source to HSE, PLL multiplier to 9 (8*9=72MHz)
    RCC->CFGR |= (RCC_CFGR_PLLSRC | RCC_CFGR_PLLMULL9);
    // Enable PLL
    RCC->CR |= RCC_CR_PLLON;
    // Wait for PLL ready
    while (!(RCC->CR & RCC_CR_PLLRDY));
    // Switch to PLL as clock source
    RCC->CFGR &= ~RCC_CFGR_SW;
    RCC->CFGR |= RCC_CFGR_SW_PLL;
    // Wait while switching to PLL
    while ((RCC->CFGR & RCC_CFGR_SWS) != RCC_CFGR_SWS_1);
    return 0;
}
