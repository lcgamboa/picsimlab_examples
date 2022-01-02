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

#include "config.h"


void setup();
void loop();

void main()
{
    ADCON1=0x0C;//AN0,AN1 e AN2 ativados
    TRISA=0xC7; //0b11000111    
    TRISB=0x07;
    TRISC=0x01;
    TRISD=0x00;
    TRISE=0x00; 
    
#if defined(_16F887)    
    ANSEL=0x07;  
#endif  

    adc_init();
    
    PWM1_Init(5000);
   
    
    serial_init();
    
    setup();
    
    
    
    while(1)
    {
        loop();
    }
}



unsigned char digitalRead(unsigned char pin)
{
    unsigned char val = 1<<(0x0F & pin);
    switch((pin & 0xF0)>>4)
    {
       case 0:
         return (PORTA & val) == val;
       case 1:
         return (PORTB & val) == val;  
       case 2:
         return (PORTC & val) == val;
        case 3:
         return (PORTD & val) == val;  
       case 4:
         return (PORTE & val) == val;      
    }
    return 0;
}

void pinMode(unsigned char pin, unsigned char value)
{
    unsigned char val = 1<<(0x0F & pin);
    switch((pin & 0xF0)>>4)
    {
       case 0:
         if(value)
             TRISA|=val;
         else
             TRISA&=~val;
         break;
       case 1:
         if(value)
             TRISB|=val;
         else
             TRISB&=~val;
         break;
       case 2:
         if(value)
             TRISC|=val;
         else
             TRISC&=~val;
         break;
       case 3:
         if(value)
             TRISD|=val;
         else
             TRISD&=~val;
         break;
       case 4:
         if(value)
             TRISE|=val;
         else
             TRISE&=~val;
         break;
    }
}


void digitalWrite(unsigned char pin, unsigned char value)
{
    unsigned char val = 1<<(0x0F & pin);
    switch((pin & 0xF0)>>4)
    {
       case 0:
         if(value)
             PORTA|=val;
         else
             PORTA&=~val;
         break;
       case 1:
         if(value)
             PORTB|=val;
         else
             PORTB&=~val;
         break;
       case 2:
         if(value)
             PORTC|=val;
         else
             PORTC&=~val;
         break;
       case 3:
         if(value)
             PORTD|=val;
         else
             PORTD&=~val;
         break;
       case 4:
         if(value)
             PORTE|=val;
         else
             PORTE&=~val;
         break;
    }
}


void analogWrite(unsigned char pin, unsigned char value)
{
    if(pin == 0x22) //RC2
    {
      PWM1_Start();
      PWM1_Set_Duty(value);
    }
}
