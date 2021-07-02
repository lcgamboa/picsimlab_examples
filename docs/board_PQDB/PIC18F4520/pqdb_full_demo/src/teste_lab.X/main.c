#include "adc.h"
#include "bits.h"
#include "config.h"  
#include "ds1307.h"
#include "io.h"
#include "keypad.h"
#include "lcd.h"
#include "pwm.h"
#include "serial.h"
#include "ssd.h"
#include "timer.h"
#include "so.h"
#include "rgb.h"

#include <pic18f4520.h>

void main(void) {

   /* pinMode(SCL_PIN,OUTPUT);
    pinMode(SDA_PIN,OUTPUT);
    for(;;){
        digitalWrite(SCL_PIN,HIGH);
        digitalWrite(SDA_PIN,HIGH);
    }*/
    //Cada linha é representada por um caracter
    char logo[48] = {
        0x01, 0x03, 0x03, 0x0E, 0x1C, 0x18, 0x08, 0x08, //0,0
        0x11, 0x1F, 0x00, 0x01, 0x1F, 0x12, 0x14, 0x1F, //0,1
        0x10, 0x18, 0x18, 0x0E, 0x07, 0x03, 0x02, 0x02, //0,2
        0x08, 0x18, 0x1C, 0x0E, 0x03, 0x03, 0x01, 0x00, //1,0
        0x12, 0x14, 0x1F, 0x08, 0x00, 0x1F, 0x11, 0x00, //1,1
        0x02, 0x03, 0x07, 0x0E, 0x18, 0x18, 0x10, 0x00 //1,2
    };
    
    lcdInit();
    int i;
    lcdCommand(0x40); //Configura para a primeira posição de memória
    //Envia cada uma das linhas em ordem
    for (i = 0; i < 48; i++) {
        lcdChar(logo[i]);
    }

    lcdCommand(0x80);
    lcdChar(0);
    lcdChar(1);
    lcdChar(2);
    lcdCommand(0xC0);
    lcdChar(3);
    lcdChar(4);
    lcdChar(5);

    rgbInit();
    pwmInit();
    ssdInit();
    kpInit();
    adcInit();
    dsInit();
    dsStartClock();
    serialInit();
    pwmInit();
    timerInit();
    i = 0;
    int seg = 0;
    char t;
    int v;
    setSeconds(0);
    char slot =0;
    for (;;) {
        timerReset(20000);
        i++;
        switch(slot){
            case 0:
                if (i > 50) {
                    seg++;
                    lcdCommand(0x88);
                    lcdChar((seg / 10) % 10 + 48);
                    lcdChar((seg/1) % 10 + 48);
                    lcdChar('-');
                    lcdChar(((getSeconds() / 10) % 10) + 48);
                    lcdChar((getSeconds() % 10) + 48);
                    i = 0;
                }
                slot = 1;
                break;
            case 1:
                kpDebounce();
                if (kpReadKey() != 0) {
                    lcdChar(kpReadKey());
                    if (kpReadKey() == 'S') {
                        pwmSet(100);
                    } else {
                        pwmSet(0);
                    }
                }
                slot = 2;
                break;
            case 2:
                t = serialRead();
                if (t) {
                    lcdChar(t);
                    serialSend(t);
                }
                slot =3 ;
                break;
            case 3:
                v = adcRead(0);
                ssdDigit(((v/1)%10),3);
                ssdDigit(((v/10)%10),2);
                ssdDigit(((v/100)%10),1);
                ssdDigit(((v/1000)%10),0);
                slot =0 ;
                break;
            default :
                slot = 0;
                break;
        }
        
        ssdUpdate();
        timerWait();
    }
}
