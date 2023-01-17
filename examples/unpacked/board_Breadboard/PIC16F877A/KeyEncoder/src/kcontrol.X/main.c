
// PIC16F877A Configuration Bit Settings

// 'C' source line config statements

// CONFIG
#pragma config FOSC = HS        // Oscillator Selection bits (HS oscillator)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = ON       // Power-up Timer Enable bit (PWRT enabled)
#pragma config BOREN = OFF      // Brown-out Reset Enable bit (BOR disabled)
#pragma config LVP = OFF        // Low-Voltage (Single-Supply) In-Circuit Serial Programming Enable bit (RB3 is digital I/O, HV on MCLR must be used for programming)
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection bit (Data EEPROM code protection off)
#pragma config WRT = OFF        // Flash Program Memory Write Enable bits (Write protection off; all program memory may be written to by EECON control)
#pragma config CP = OFF         // Flash Program Memory Code Protection bit (Code protection off)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#define _XTAL_FREQ  8000000

#include <xc.h>


const unsigned char codes[] = {0x00,
    0x06, 0x5B, 0x4F, 0x77,
    0x66, 0x6D, 0x7D, 0x7C,
    0x07, 0x7F, 0x6F, 0x39,
    0x79, 0x3F, 0x71, 0x5E};


unsigned char Seg7_Data(unsigned char disp_val);

#define SEG7    PORTD
#define KEYPAD  PORTB
#define DA      RB0

void main() {
    TRISB = 0b11110001;
    TRISD = 0x00;

    unsigned char Key_Data = 0;

    SEG7 = 0;
    while (1) {
        //check key pressed
        if (DA == 1) {
            //read keypad data
            Key_Data = (KEYPAD >> 4) & 0x0F;
            //display
            SEG7 = codes[Key_Data + 1];
        }
    }
}
