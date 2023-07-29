/*
 Simple LED sequencer example
 */

#include "config.h"
#include <xc.h>

void main(void) {
    unsigned char aux;
    unsigned int speed;

    ANSELA = 0x00;
    ANSELB = 0x00;
    ANSELC = 0x00;

    SW_DIR = 1;
    POT_DIR = 1;

    LED0_DIR = 0;
    LED1_DIR = 0;
    LED2_DIR = 0;
    LED3_DIR = 0;

    LED0 = 0;
    LED1 = 0;
    LED2 = 0;
    LED3 = 0;

#ifdef _16F1619
    ADCON1bits.ADCS = 6;
    ADCON1bits.ADFM = 1;
    ADCON0bits.CHS = POT_CHANNEL;
#else
    ADCON0bits.ADFM = 1;
    ADCON0bits.ADCS = 1;
    ADPCH = POT_CHANNEL;
#endif

    ADCON0bits.ADON = 1;

    aux = 1;
    while (1) {
        LED0 = !!(aux & 0x01);
        LED1 = !!(aux & 0x02);
        LED2 = !!(aux & 0x04);
        LED3 = !!(aux & 0x08);

        if (SW) {
            aux = (unsigned char) (aux << 1);
            if (aux > 8)aux = 1;
        } else {
            aux = (unsigned char) (aux >> 1);
            if (aux == 0)aux = 8;
        }

        ADCON0bits.ADGO = 1;
        while (ADCON0bits.ADGO); //wait
        speed = (unsigned int) (((ADRESH << 8) | ADRESL) + 100);

        for (unsigned int i = 0; i < speed; i++) {
            __delay_ms(1);
        }
    }
    return;
}
