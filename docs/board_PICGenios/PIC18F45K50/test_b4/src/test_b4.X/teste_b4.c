/* ########################################################################

   PICsim - PIC simulator http://sourceforge.net/projects/picsim/

   ########################################################################

   Copyright (c) : 2022  Luis Claudio Gambôa Lopes

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

/* ----------------------------------------------------------------------- */

#include <xc.h>


#include "config.h"


#include "atraso.h"
#include "lcd.h"
#include "display7s.h"
#if defined(_18F4550 ) || defined(_18F45K50 )  
#else
#include "i2c.h"
#include "eeprom_ext.h"
#include "rtc.h"
#endif
#include "serial.h"
#if !defined(_16F777) && !defined(_18F47K40)
#include "eeprom.h"
#endif
#include "adc.h"
#include "itoa.h"
#include "teclado.h"


#ifndef _16F777
__EEPROM_DATA(0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77);
__EEPROM_DATA(0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF);
#endif

#define print_msg(x)  lcd_str(x);serial_tx_str(x);serial_tx_str("\r\n");

void test_ADC(void);
void test_EEPROM_EXT(void);
void test_EEPROM_INT(void);
void test_LCD(void);
void test_LEDS(void);
void test_RTC(void);
void test_buzzer(void);
void test_switchs(void);
void test_display7s(void);
void test_relay(void);
void test_serial(void);
void test_keypad(void);
void test_keypad2(unsigned char num);
void test_temp(void);

static unsigned char cnt;
static unsigned int t1cont;

//char buffer[45];

void main() {

    TRISA = 0xC3;
    TRISB = 0x01;
    TRISC = 0x01;
    TRISD = 0x00;
    TRISE = 0x00;

#if defined(_18F47K40)
    ANSELA = 0x07;
    ANSELB = 0;
    ANSELC = 0;
    ANSELD = 0;
    ANSELE = 0;
#endif

#if defined(_16F877A) || defined(_16F777)  || defined(_18F47K40) 
#else  
    INTCON2bits.RBPU = 0;
#endif

    lcd_init();
    lcd_cmd(L_NCR);
#if defined(_18F4550 ) || defined(_18F45K50 )  
#else    
    i2c_init();
#endif  
    adc_init();
#ifndef _18F47K40
#ifdef _18F452
    ADCON1 = 0x06;
#else
    ADCON1 = 0x0F;
#if !defined(_18F45K50) && !defined(_18F47K40)  
    CMCON = 0x07;
#endif  
#endif
#endif
    PORTA = 0;
    PORTCbits.RC1 = 1; //turn off beep
    PORTCbits.RC5 = 0; //turn off heater
    PORTCbits.RC6 = 0;

    TRISCbits.TRISC7 = 1; //RX
    TRISCbits.TRISC6 = 0; //TX
    serial_init();


    //dip
    TRISB = 0x03;
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("Turn On all DIP");
    lcd_cmd(L_L2);
    print_msg("Press. RB1");
    while (PORTBbits.RB1);
    atraso_ms(100);
    while (!PORTBbits.RB1);
    atraso_ms(100);
    //dip
    TRISB = 0x03;
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("Turn Off RTC DIP");
    lcd_cmd(L_L2);
    print_msg("Press. RB1");
    while (PORTBbits.RB1);

    test_LCD();
    test_buzzer();
    test_display7s();
    test_LEDS();
    test_switchs();
    test_serial();
    test_ADC();
    test_relay();
    test_temp();
    test_RTC();
    test_keypad();
    test_EEPROM_INT();
    test_EEPROM_EXT();


    //end test
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("      End");
    lcd_cmd(L_L2);
    print_msg(" PresS RESET");


    while (1);

}



//----------------------------------------------------------------------------
// High priority interrupt routine

void interrupt isrh() {
    cnt--;
    if (!cnt) {
        //executada a cada 1 segundo
        t1cont = (((unsigned int) TMR1H << 8) | (TMR1L)) / 7; //ventilador com 7 pï¿½s
        cnt = 125;
        TMR1H = 0;
        TMR1L = 0;
    }
#ifdef _18F47K40
    PIR0bits.TMR0IF = 0;
#else 
    INTCONbits.T0IF = 0;
#endif 
#if defined(_16F877A) || defined(_16F777)  
    TMR0 = 6;
#else
    TMR0H = 0;
    TMR0L = 6; //250 
#endif
}

//----------------------------------------------------------------------------

#if defined(_16F877A) || defined(_16F777)  
#else

void interrupt low_priority isrl() {
#asm
    NOP
#endasm
}
#endif

void test_LCD(void) {
    unsigned char i, tmp;

    //test special character 
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("   Test LCD");

    for (i = 0; i < 10; i++) {
        atraso_ms(100);
        lcd_cmd(0x18); //display shift
    }

    for (i = 0; i < 10; i++) {
        atraso_ms(100);
        lcd_cmd(0x1C); //display shift
    }

    lcd_cmd(L_CR);
    for (i = 0; i < 10; i++) {
        atraso_ms(100);
        lcd_cmd(0x10);
    }
    for (i = 0; i < 10; i++) {
        atraso_ms(100);
        lcd_cmd(0x14);
    }
    lcd_cmd(L_NCR);

    lcd_cmd(0x40); //address

    lcd_dat(0x11);
    lcd_dat(0x19);
    lcd_dat(0x15);
    lcd_dat(0x13);
    lcd_dat(0x13);
    lcd_dat(0x15);
    lcd_dat(0x19);
    lcd_dat(0x11);

    lcd_dat(0x0E);
    lcd_dat(0x11);
    lcd_dat(0x0E);
    lcd_dat(0x05);
    lcd_dat(0x0E);
    lcd_dat(0x14);
    lcd_dat(0x0A);
    lcd_dat(0x11);


    lcd_cmd(L_L2);

    for (i = 0; i < 16; i++) {
        lcd_dat(i % 2);
        atraso_ms(100);
    }

    //test lcd
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("   Test LCD");

    for (i = 32; i >= 32; i++) {
        if ((i % 16) == 0)lcd_cmd(L_L2);
        lcd_dat(i);
        atraso_ms(50);
    }

    atraso_ms(100);
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("   Test LCD");
    lcd_cmd(L_L2);
    print_msg("       Ok");
    atraso_ms(500);
}

void test_buzzer(void) {
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("   Beep");
    PORTCbits.RC1 = 0; //beep
    atraso_ms(500);
    PORTCbits.RC1 = 1;
}

void test_display7s(void) {
    unsigned char i, tmp;

    //test 7s display 

    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("   Test 7 Seg");

#ifndef _18F47K40
#ifdef _18F452
    ADCON1 = 0x06;
#else
    ADCON1 = 0x0F;
#endif
#endif    
    for (i = 0; i < 5; i++) {
        switch (i) {
            case 0:
                PORTA = 0x20;
                break;
            case 1:
                PORTA = 0x10;
                break;
            case 2:
                PORTA = 0x08;
                break;
            case 3:
                PORTA = 0x04;
                break;
            case 4:
                PORTA = 0x3C;
                break;
        }

        for (tmp = 0; tmp < 16; tmp++) {
            PORTD = display7s(tmp);
            atraso_ms(200);
        }
    }
    PORTD = display7s(8);
    atraso_ms(1000);
    PORTA = 0x00;

#ifndef _18F47K40
#ifdef _18F452
    ADCON1 = 0x02;
#else
    ADCON1 = 0x0B;
#endif
    PORTD = 0;
#endif
}

void test_LEDS(void) {
    unsigned char i, tmp;

    //testa LEDs
    TRISB = 0x00;
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1 + 3);
    print_msg("Test LEDs");

    for (tmp = 0; tmp < 3; tmp++) {
        for (i = 1; i > 0; i = i * 2) {
            PORTB = i;
            PORTD = i;
            atraso_ms(200);
        }
    }
    PORTB = 0;
    PORTD = 0;
    for (i = 0; i < 4; i++) {
        PORTB ^= 0xFF;
        PORTD ^= 0xFF;
        atraso_ms(200);
    }
}

void test_switchs(void) {
    //testa chaves


    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("  Test Switchs");

    //tmp = 0;
#ifndef _18F47K40    
#ifdef _18F452
    ADCON1 = 0x06;
#else
    ADCON1 = 0x0F;
#endif
#endif    


    TRISB = 0x3F;
    lcd_cmd(L_L2);
    print_msg(" RB0          ");
    while (PORTBbits.RB0);
    lcd_cmd(L_L2 + 6);
    print_msg("Ok");
    atraso_ms(500);

    lcd_cmd(L_L2);
    print_msg(" RB1          ");
    while (PORTBbits.RB1);
    lcd_cmd(L_L2 + 6);
    print_msg("Ok");
    atraso_ms(500);

    lcd_cmd(L_L2);
    print_msg(" RB2          ");
    while (PORTBbits.RB2);
    lcd_cmd(L_L2 + 6);
    print_msg("Ok");
    atraso_ms(500);

    lcd_cmd(L_L2);
    print_msg(" RB3          ");
    while (PORTBbits.RB3);
    lcd_cmd(L_L2 + 6);
    print_msg("Ok");
    atraso_ms(500);

    lcd_cmd(L_L2);
    print_msg(" RB4          ");
    while (PORTBbits.RB4);
    lcd_cmd(L_L2 + 6);
    print_msg("Ok");
    atraso_ms(500);


    lcd_cmd(L_L2);
    print_msg(" RB5          ");
    while (PORTBbits.RB5);
    lcd_cmd(L_L2 + 6);
    print_msg("Ok");
    atraso_ms(500);
    /*
        TRISA |= 0x20;
        lcd_cmd(L_L2);
        print_msg(" RA5          ");
        while (PORTAbits.RA5);
        lcd_cmd(L_L2 + 6);
        print_msg("Ok");
        atraso_ms(500);
        TRISA &= ~0x20;
     */

    PORTB = 0;

#ifndef _18F47K40    
#ifdef _18F452
    ADCON1 = 0x02;
#else
    ADCON1 = 0x0B;
#endif
#endif
}

void test_serial(void) {
    unsigned char i, tmp;

    //teste serial
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("Test Serial TX");
    // testar ? 
    lcd_cmd(L_L2);
    print_msg(" (Y=RB0 N=RB1) ?");

    TRISB = 0x03;
    while (PORTBbits.RB0 && PORTBbits.RB1);

    if (PORTBbits.RB0 == 0) {

        //TRISCbits.TRISC7 = 1; //RX
        //TRISCbits.TRISC6 = 0; //TX
        //serial_init();

        lcd_cmd(L_L2 + 4);
        print_msg("9600 8N1");

        serial_tx_str("\r\n Picsimlab\r\n Test Serial TX\r\n");

        for (i = 0; i < 4; i++) {
            serial_tx(i + 0x30);
            serial_tx_str(" PicsimLab\r\n");
        }
        atraso_ms(1000);

        lcd_cmd(L_CLR);
        lcd_cmd(L_L1);
        print_msg("Test Serial RX");
        serial_tx_str(" Type!\r\n");
        for (i = 0; i < 32; i++) {
            if (!(i % 16)) {
                lcd_cmd(L_L2);
                serial_tx_str("\r\n");
            }
            tmp = serial_rx(2000);
            lcd_dat(tmp);
            serial_tx(tmp);
        }
        atraso_ms(100);
        //serial_end();
        //PORTCbits.RC6 = 0;
    }
}

void test_ADC(void) {
    unsigned char i;
    unsigned char tmp;
    char str[6];

    //teste ADC
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg(" Test ADC (P1)");

    for (i = 0; i < 200; i++) {
        tmp = (adc_amostra(0)*10) / 204;
        lcd_cmd(L_L2 + 6);
        itoa(tmp, str);
        lcd_dat(str[3]);
        lcd_dat(',');
        lcd_dat(str[4]);
        lcd_dat('V');
        atraso_ms(10);
    }

    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg(" Test ADC (P2)");

    for (i = 0; i < 200; i++) {
        tmp = ((unsigned int) adc_amostra(1)*10) / 204;
        lcd_cmd(L_L2 + 6);
        itoa(tmp, str);
        lcd_dat(str[3]);
        lcd_dat(',');
        lcd_dat(str[4]);
        lcd_dat('V');
        atraso_ms(10);
    }

}

void test_relay(void) {
    unsigned char i;
    //teste RELE

    TRISCbits.TRISC0 = 0;
    TRISEbits.TRISE0 = 0;

    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("Test Relay1 1");


    for (i = 0; i < 5; i++) {
        PORTCbits.RC0 ^= 1;
        atraso_ms(500);
    }
    PORTCbits.RC0 = 0;

    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("Test Relay2 2");

    for (i = 0; i < 5; i++) {
        PORTEbits.RE0 ^= 1;
        atraso_ms(500);
    }
    PORTEbits.RE0 = 0;

}

void test_temp(void) {
    unsigned char i;
    unsigned int tmpi;
    char str[6];

    //dip
    TRISB = 0x03;
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("Turn Off REL1 DIP");
    lcd_cmd(L_L2);
    print_msg("Press. RB1");
    while (PORTBbits.RB1);


    //teste TEMP
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("   Test TEMP");

    TRISA = 0x07;

    adc_init();

    for (i = 0; i < 100; i++) {
        tmpi = (adc_amostra(2)*10) / 2;
        lcd_cmd(L_L2 + 5);
        itoa(tmpi, str);
        lcd_dat(str[2]);
        lcd_dat(str[3]);
        lcd_dat(',');
        lcd_dat(str[4]);
        lcd_dat('C');
        atraso_ms(20);
    }


    //teste Aquecimento
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("   Test Heater");
    PORTCbits.RC5 = 1;
    for (i = 0; i < 200; i++) {
        tmpi = (adc_amostra(2)*10) / 2;
        lcd_cmd(L_L2 + 5);
        itoa(tmpi, str);
        lcd_dat(str[2]);
        lcd_dat(str[3]);
        lcd_dat(',');
        lcd_dat(str[4]);
        lcd_dat('C');
        atraso_ms(50);
    }
    PORTCbits.RC5 = 0;

    //teste Resfriamento

    TRISCbits.TRISC0 = 1;
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("   Test Cooler");

    //timer0 temporizador
#if defined(_16F877A) || defined(_16F777)  
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.PSA = 0;
    OPTION_REGbits.PS0 = 0;
    OPTION_REGbits.PS1 = 0;
    OPTION_REGbits.PS2 = 1;
#elif _18F47K40
    T0CON0bits.T0OUT = 0;
    T0CON0bits.T016BIT = 0;
    T0CON0bits.T0OUTPS = 0;

    T0CON1bits.T0CS = 2; //FOSC/4
    T0CON1bits.T0ASYNC = 0;
    T0CON1bits.T0CKPS = 5; // 32

    T0CON0bits.T0EN = 1;
    TMR0H = 255;
#else
    T0CONbits.T0CS = 0;
    T0CONbits.PSA = 0;
    T0CONbits.T08BIT = 1;
    T0CONbits.T0PS0 = 0; // divide por 32
    T0CONbits.T0PS1 = 0;
    T0CONbits.T0PS2 = 1;
    T0CONbits.TMR0ON = 1;
#endif

#ifdef _18F47K40
    PIE0bits.TMR0IE = 1;
#else 
    INTCONbits.T0IE = 1;
#endif
    //T = 32x250x125 = 1segundo;

    //timer1 contador
#ifdef _18F47K40
    T1CONbits.CKPS = 0;
    TMR1CLKbits.CS = 1; //FOSC/4

    T1CONbits.ON = 1;
#else 
    T1CONbits.TMR1CS = 1;
    T1CONbits.T1CKPS1 = 0;
    T1CONbits.T1CKPS0 = 0;
#endif 

#ifdef _18F47K40
    PIR0bits.TMR0IF = 0;
#else 
    INTCONbits.T0IF = 0;
#endif 
#if defined(_16F877A) || defined(_16F777)  
    TMR0 = 6;
#else
    TMR0H = 0;
    TMR0L = 6; //250
#endif
    cnt = 125;
    INTCONbits.GIE = 1;

    TMR1H = 0;
    TMR1L = 0;
    T1CONbits.TMR1ON = 1;

    PORTCbits.RC2 = 1;
    for (i = 0; i < 150; i++) {
        tmpi = (adc_amostra(2)*10) / 2;
        lcd_cmd(L_L2 + 2);
        itoa(tmpi, str);
        lcd_dat(str[2]);
        lcd_dat(str[3]);
        lcd_dat(',');
        lcd_dat(str[4]);
        lcd_dat('C');

        lcd_cmd(L_L2 + 8);
        itoa(t1cont, str);
        lcd_dat(str[1]);
        lcd_dat(str[2]);
        lcd_dat(str[3]);
        lcd_dat(str[4]);
        lcd_dat('R');
        lcd_dat('P');
        lcd_dat('S');

        atraso_ms(10);
    }

    INTCONbits.GIE = 0;
    PORTCbits.RC2 = 0;


#ifdef _18F452
    ADCON1 = 0x06;
#else
    ADCON1 = 0x0F;
#endif

}

void test_RTC(void) {
#if defined(_18F4550 ) || defined(_18F45K50 )  
#else 
    unsigned char i;
    //teste RTC
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("Test RTC");

    rtc_w();

    rtc_r();
    lcd_cmd(L_L2);
    print_msg((const char *) date);
    atraso_ms(2000);
    for (i = 0; i < 10; i++) {
        rtc_r();
        lcd_cmd(L_L2);
        print_msg((const char *) time);
        atraso_ms(1000);
    }
#endif
}

void test_keypad(void) {
    //teste teclado 
    //dip
    TRISB = 0x07;
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("Test Keytpad");

    //Linha 1 
    lcd_cmd(L_L2);
    print_msg("Press. 1      ");
    PORTD = 0x07; //RD3 LOW
    while (PORTBbits.RB0);
    lcd_cmd(L_L2 + 10);
    print_msg("Ok");
    atraso_ms(500);

    lcd_cmd(L_L2);
    print_msg("Press. 2      ");
    PORTD = 0x07; //RD3 LOW
    while (PORTBbits.RB1);
    lcd_cmd(L_L2 + 10);
    print_msg("Ok");
    atraso_ms(500);

    lcd_cmd(L_L2);
    print_msg("Press. 3      ");
    PORTD = 0x07; //RD3 LOW
    while (PORTBbits.RB2);
    lcd_cmd(L_L2 + 10);
    print_msg("Ok");
    atraso_ms(500);

    //Linha 2 
    lcd_cmd(L_L2);
    print_msg("Press. 4      ");
    PORTD = 0x0B; //RD2 LOW
    while (PORTBbits.RB0);
    lcd_cmd(L_L2 + 10);
    print_msg("Ok");
    atraso_ms(500);

    lcd_cmd(L_L2);
    print_msg("Press. 5      ");
    PORTD = 0x0B; //RD2 LOW
    while (PORTBbits.RB1);
    lcd_cmd(L_L2 + 10);
    print_msg("Ok");
    atraso_ms(500);

    lcd_cmd(L_L2);
    print_msg("Press. 6      ");
    PORTD = 0x0B; //RD2 LOW
    while (PORTBbits.RB2);
    lcd_cmd(L_L2 + 10);
    print_msg("Ok");
    atraso_ms(500);

    //Linha 3 
    lcd_cmd(L_L2);
    print_msg("Press. 7      ");
    PORTD = 0x0D; //RD1 LOW
    while (PORTBbits.RB0);
    lcd_cmd(L_L2 + 10);
    print_msg("Ok");
    atraso_ms(500);

    lcd_cmd(L_L2);
    print_msg("Press. 8      ");
    PORTD = 0x0D; //RD1 LOW
    while (PORTBbits.RB1);
    lcd_cmd(L_L2 + 10);
    print_msg("Ok");
    atraso_ms(500);

    lcd_cmd(L_L2);
    print_msg("Press. 9      ");
    PORTD = 0x0D; //RD1 LOW
    while (PORTBbits.RB2);
    lcd_cmd(L_L2 + 10);
    print_msg("Ok");
    atraso_ms(500);

    //Linha 4 
    lcd_cmd(L_L2);
    print_msg("Press. <      ");
    PORTD = 0x0E; //RD0 LOW
    while (PORTBbits.RB0);
    lcd_cmd(L_L2 + 10);
    print_msg("Ok");
    atraso_ms(500);

    lcd_cmd(L_L2);
    print_msg("Press. 0      ");
    PORTD = 0x0E; //RD0 LOW
    while (PORTBbits.RB1);
    lcd_cmd(L_L2 + 10);
    print_msg("Ok");
    atraso_ms(500);

    lcd_cmd(L_L2);
    print_msg("Press. >      ");
    PORTD = 0x0E; //RD0 LOW
    while (PORTBbits.RB2);
    lcd_cmd(L_L2 + 10);
    print_msg("Ok");
    atraso_ms(500);

}

void test_keypad2(unsigned char num) {
    unsigned char i;
    unsigned char tmp;

    TRISB = 0x07;
    //teste Teclado
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1 + 2);
    print_msg("Test Keypad");

    lcd_cmd(L_L2 + 1);

    i = 0;
    while (i < num) {
        tmp = tc_tecla(1500) + 0x30;
        if (!(i % 15)) {
            lcd_cmd(L_L2 + 1);
        }
        lcd_dat(tmp);
        i++;
    }

}

void test_EEPROM_INT(void) {
#if  !defined(_16F777) &&  !defined(_18F47K40)
    unsigned char tmp;
    unsigned char i;

    TRISB = 0x03;
    //teste EEPROM INT
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("Test EEPROM INT");
    // testar ? 
    lcd_cmd(L_L2);
    print_msg(" (Y=RB0 N=RB1) ?");


    TRISB = 0x03;

    while (PORTBbits.RB0 && PORTBbits.RB1);

    if (PORTBbits.RB0 == 0) {
        tmp = e2prom_r(10);
        lcd_dat(tmp);

        e2prom_w(10, 0xA5);
        e2prom_w(10, 0x5A);
        i = e2prom_r(10);

        e2prom_w(10, tmp);

        lcd_cmd(L_CLR);
        lcd_cmd(L_L1);
        print_msg("Test EEPROM INT");
        lcd_cmd(L_L2);
        if (i == 0x5A) {
            print_msg("       OK");
        } else {
            print_msg("      ERRO");
        }

        atraso_ms(1000);
    } else {
        while (PORTBbits.RB1 == 0);
    }
#endif
}

void test_EEPROM_EXT(void) {
#if defined(_18F4550 ) || defined(_18F45K50 )  
#else  
    unsigned char i, tmp;

    //teste EEPROM EXT
    lcd_cmd(L_CLR);
    lcd_cmd(L_L1);
    print_msg("Test EEPROM EXT");
    // testar ? 
    lcd_cmd(L_L2);
    print_msg(" (Y=RB0 N=RB1) ?");

    TRISB = 0x03;

    while (PORTBbits.RB0 && PORTBbits.RB1);

    if (PORTBbits.RB0 == 0) {
        tmp = e2pext_r(10);
        lcd_dat(tmp);

        e2pext_w(10, 0xA5);
        e2pext_w(10, 0x5A);
        i = e2pext_r(10);

        e2pext_w(10, tmp);

        lcd_cmd(L_CLR);
        lcd_cmd(L_L1);
        print_msg("Test EEPROM EXT");
        lcd_cmd(L_L2);
        if (i == 0x5A) {
            print_msg("       OK");
        } else {
            print_msg("      ERRO");
        }
        atraso_ms(1000);

    } else {
        while (PORTBbits.RB1 == 0);
    }

#endif
    TRISB = 0x00;
    PORTB = 0;
}