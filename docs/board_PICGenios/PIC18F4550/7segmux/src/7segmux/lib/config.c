#include <xc.h>

#ifdef _18F452
#include"config_452.h"
#endif
#ifdef _18F4620
#include"config_4620.h"
#endif
#ifdef _18F4520
#include"config_4520.h"
#endif
#ifdef _18F4550
#include"config_4550.h"
#endif
#ifdef _18F45K50
#include"config_45K50.h"
#endif
#ifdef _16F877A
#include"config_877A.h"
#endif
#ifdef _16F777
#include"config_777.h"
#endif
#ifdef _16F1939
#include"config_1939.h"
#endif
#ifdef _16F887
#include"config_887.h"
#endif
#ifdef _16F1789
#include"config_1789.h"
#endif
#ifdef _18F47K40
#include"config_47K40.h"
#endif
#ifdef _18F4580
#include"config_4580.h"
#endif

#include "config.h"


void setup();
void loop();

void main() {
    ADCON1 = 0x0C; //AN0,AN1 e AN2 ativados
    TRISA = 0xC7; //0b11000111    
    TRISB = 0x07;
    TRISC = 0x01;
    TRISD = 0x00;
    TRISE = 0x00;

#if defined(_16F887)    
    ANSEL = 0x07;
#endif  

#if defined(_18F47K40)
    ANSELA = 0x07;
    ANSELB = 0x00;
    ANSELC = 0x00;
    ANSELD = 0x00;
    ANSELE = 0x00;
#endif  

    adc_init();
    PWM1_Init(5000);
    serial_init();
    setup();
    while (1) {
        loop();
    }
}

unsigned char digitalRead(unsigned char pin) {
    unsigned char val = (unsigned char) (1 << (0x0F & pin));
    switch ((pin & 0xF0) >> 4) {
        case 0:
            return (unsigned char) ((PORTA & val) == val);
        case 1:
            return (unsigned char) ((PORTB & val) == val);
        case 2:
            return (unsigned char) ((PORTC & val) == val);
        case 3:
            return (unsigned char) ((PORTD & val) == val);
        case 4:
            return (unsigned char) ((PORTE & val) == val);
    }
    return 0;
}

void pinMode(unsigned char pin, unsigned char value) {
    unsigned char val = (unsigned char) (1 << (0x0F & pin));
    switch ((pin & 0xF0) >> 4) {
        case 0:
            if (value)
                TRISA |= val;
            else
                TRISA &= (unsigned char) (~val);
            break;
        case 1:
            if (value)
                TRISB |= val;
            else
                TRISB &= (unsigned char) (~val);
            break;
        case 2:
            if (value)
                TRISC |= val;
            else
                TRISC &= (unsigned char) (~val);
            break;
        case 3:
            if (value)
                TRISD |= val;
            else
                TRISD &= (unsigned char) (~val);
            break;
        case 4:
            if (value)
                TRISE |= val;
            else
                TRISE &= (unsigned char) (~val);
            break;
    }
}

#if !defined(_PIC18)
#define LATA PORTA
#define LATB PORTB
#define LATC PORTC
#define LATD PORTD
#define LATE PORTE
#endif

void digitalWrite(unsigned char pin, unsigned char value) {
    unsigned char val = (unsigned char) (1 << (0x0F & pin));
    switch ((pin & 0xF0) >> 4) {
        case 0:
            if (value)
                LATA |= val;
            else
                LATA &= (unsigned char) (~val);
            break;
        case 1:
            if (value)
                LATB |= val;
            else
                LATB &= (unsigned char) (~val);
            break;
        case 2:
            if (value)
                LATC |= val;
            else
                LATC &= (unsigned char) (~val);
            break;
        case 3:
            if (value)
                LATD |= val;
            else
                LATD &= (unsigned char) (~val);
            break;
        case 4:
            if (value)
                LATE |= val;
            else
                LATE &= (unsigned char) (~val);
            break;
    }
}

void analogWrite(unsigned char pin, unsigned char value) {
    if (pin == 0x22) //RC2
    {
        PWM1_Start();
        PWM1_Set_Duty(value);
    }
}
