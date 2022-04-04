
// PIC16F628A Configuration Bit Settings

// 'C' source line config statements

// CONFIG
#pragma config FOSC = HS        // Oscillator Selection bits (HS oscillator: High-speed crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = ON       // RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is MCLR)
#pragma config BOREN = OFF      // Brown-out Detect Enable bit (BOD disabled)
#pragma config LVP = OFF        // Low-Voltage Programming Enable bit (RB4/PGM pin has digital I/O function, HV on MCLR must be used for programming)
#pragma config CPD = OFF        // Data EE Memory Code Protection bit (Data memory code protection off)
#pragma config CP = OFF         // Flash Program Memory Code Protection bit (Code protection off)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#define _XTAL_FREQ 8000000L

#include <xc.h>



unsigned char display7s(unsigned char v);

void main(void) {
    unsigned char count =0x23;
    
    TRISA=0x00;
    TRISB=0x00;
    CMCON=0x07;
    
    while(1)
    {
       PORTB = display7s(count &0x000F); 
       PORTAbits.RA0 = 1;
       PORTAbits.RA0 = 0;
       PORTB = display7s((count &0x00F0 )>>4); 
       PORTAbits.RA1 = 1;
       PORTAbits.RA1 = 0;
        __delay_ms(250);
        count++;
    }
    return;
}


unsigned char display7s(unsigned char v)
{
  switch(v)
  {
    case 0:
      return 0x3F;
    case 1:
      return 0x06;
    case 2:
      return 0x5B;
    case 3:
      return 0x4F;
    case 4:
      return 0x66;
    case 5:
      return 0x6D;
    case 6:
      return 0x7D;
    case 7:
      return 0x07;
    case 8:
      return 0x7F;
    case 9:
      return 0x6F;
    case 10:
      return 0x77;
    case 11:
      return 0x7c;
    case 12:
      return 0x58;
    case 13:
      return 0x5E;
    case 14:
      return 0x79;
    case 15:
      return 0x71;
    default:
      return 0;
  }

}