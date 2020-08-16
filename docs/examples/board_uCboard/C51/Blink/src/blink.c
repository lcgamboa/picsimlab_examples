// Blink LEDs : Using Delay Function
// compiled with: sdcc -mmcs51 blink.c -o blink.hex

#include <mcs51/8051.h>


void INT0_int(void) __interrupt 0
{
    P3 = ~P3;
}

void ext1_int(void) __interrupt 2
{
    P3 = 0x33;
}

void delay_ms_1(int m)
{
    int i, j;
    for (i = 0; i < m; i++)
        for (j = 0; j < 114; j++) ;
}

void delay_ms(unsigned int count)
{
    TL0 = (8192 - 922) % 32;
    TH0 = (8192 - 922) / 32;
    TR0 = 1;
    while (count > 0)
    {
        while (TF0 == 0);
        TL0 = (8192 - 922) % 32;
        TH0 = (8192 - 922) / 32;
        TF0 = 0;
        
        count--;
    }
    TR0 = 0;
}

void flash_light()
{
    int i;
    P1 = 1;
    for (i = 0; i < 8; i++)
    {
        P1 = 1 << i;
        delay_ms(100);
    }
    for (i = 8; i >= 0; i--)
    {
        P1 = 1 << i;
        delay_ms(100);
    }
}

void main()
{
    char leds=0x00;
    int i = 0;
    
    IE = 0x85;  // EA=1, EX 0=1, EX1 = 1
    
    P0 = 1;
    P1 = 0x1;
    P2 = 0xff;            //Setting all Pins of PORT2 High.
    P3 = 0;
    while (i < 500)
    {
        P0++;
        P2 = leds;          //Output the value of the variable "leds" to PORT2.
        leds = ~leds;       //Complement all the bits of the variable "leds".
        i++;
        P3++;
        flash_light();
    }
}
