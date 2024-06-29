#ifndef XC_config_18F67J60_H
#define	XC_config_18F67J60_H


// PIC18F67J60 Configuration Bit Settings

// 'C' source line config statements

// CONFIG1L
#pragma config WDT = OFF        // Watchdog Timer Enable bit (WDT disabled (control is placed on SWDTEN bit))
#pragma config STVR = OFF       // Stack Overflow/Underflow Reset Enable bit (Reset on stack overflow/underflow disabled)
#pragma config XINST = OFF       // Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode enabled)

// CONFIG1H
#pragma config CP0 = OFF        // Code Protection bit (Program memory is not code-protected)

// CONFIG2L
#pragma config FOSC = HS        // Oscillator Selection bits (HS oscillator)
#pragma config FOSC2 = OFF      // Default/Reset System Clock Select bit (INTRC enabled as system clock when OSCCON<1:0> = 00)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor disabled)
#pragma config IESO = OFF       // Two-Speed Start-up (Internal/External Oscillator Switchover) Control bit (Two-Speed Start-up disabled)

// CONFIG2H
#pragma config WDTPS = 32768    // Watchdog Timer Postscaler Select bits (1:32768)

// CONFIG3L

// CONFIG3H
#pragma config ETHLED = OFF     // Ethernet LED Enable bit (RA0/RA1 function as I/O regardless of Ethernet module status)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#endif	/* XC_config_18F67J60_H */