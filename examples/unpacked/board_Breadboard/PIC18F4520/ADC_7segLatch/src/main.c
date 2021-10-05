/* ########################################################################

   PICSimLab - PIC simulator http://sourceforge.net/projects/picsimlab/

   ########################################################################

   Copyright (c) : 2021  Luis Claudio Gambôa Lopes

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

   For e-mail suggestions :  lcgamboa@yahoo.com
   ######################################################################## */


#include <xc.h>
#define _XTAL_FREQ 8000000L

#pragma config OSC = HS
#pragma config WDT = OFF
#pragma config LVP = OFF
#pragma config BOREN = SBORDIS
#pragma config PBADEN = OFF

void adc_init(void);
unsigned int adc_sample(unsigned char canal);

void main(void) {
    int value;

    TRISA = 0xFF;
    TRISD = 0x00; // configure PORTD as all output

    adc_init();

    PORTD = 0xFF;

    while (1) {
        value = adc_sample(0);

        PORTD = 0xF0 | ((value / 1000) % 10);
        PORTDbits.RD4 = 0; //latch write
        __delay_us(50);
        PORTDbits.RD4 = 1;

        PORTD = 0xF0 | ((value / 100) % 10);
        PORTDbits.RD5 = 0; //latch write
        __delay_us(50);
        PORTDbits.RD5 = 1;

        PORTD = 0xF0 | ((value / 10) % 10);
        PORTDbits.RD6 = 0; //latch write
        __delay_us(50);
        PORTDbits.RD6 = 1;


        PORTD = 0xF0 | (value % 10);
        PORTDbits.RD7 = 0; //latch write
        __delay_us(50);
        PORTDbits.RD7 = 1;

    }
}

void adc_init(void) {
#if defined (_18F452) || defined(_16F877A)
    ADCON1 = 0x02;
    ADCON0 = 0x81;
#else
    ADCON0 = 0x01;
    ADCON1 = 0x0C;
    ADCON2 = 0x01;
#endif


}

unsigned int adc_sample(unsigned char canal) {
    ADCON0bits.CHS = canal;

    __delay_us(20);

    ADCON0bits.GO = 1;
    while (ADCON0bits.GO == 1);

    return (unsigned int) ((((unsigned int) ADRESH) << 2) | (ADRESL >> 6));
}
