#include <xc.h>
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
#include "i2c.h"

void main(void) {

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
    int rtc_seg;
    char t;
    int v;
    setSeconds(0);
    char slot = 0;
    char seg_slot = 0;
    for (;;) {
        timerReset(5000);
        i++;
        switch (slot) {
            case 0:
                if (i >= 200) {
                    switch (seg_slot) {
                        case 0:
                            seg++;
                            lcdCommand_nodelay(0x88);
                            seg_slot++;
                            break;
                        case 1:
                            lcdChar_nodelay((seg / 10) % 10 + 48);
                            seg_slot++;
                            break;
                        case 2:
                            lcdChar_nodelay((seg / 1) % 10 + 48);
                            seg_slot++;
                            break;
                        case 3:
                            lcdChar_nodelay('-');
                            seg_slot++;
                            break;
                        case 4:
                            i2cWriteByte(1, 0, DS1307_CTRL_ID | I2C_WRITE);
                            i2cWriteByte(0, 0, SEC);
                            seg_slot++;
                            break;
                        case 5:
                            i2cWriteByte(1, 0, DS1307_CTRL_ID | I2C_READ);
                            rtc_seg = i2cReadByte(1, 1);
                            rtc_seg = bcd2dec(rtc_seg & 0x7f);
                            seg_slot++;
                            break;
                        case 6:
                            lcdChar_nodelay(((rtc_seg / 10) % 10) + 48);
                            seg_slot++;
                            break;
                        case 7:
                            lcdChar_nodelay((rtc_seg % 10) + 48);
                            i -= 200;
                            slot++;
                            seg_slot = 0;
                            break;
                    }
                    break;
                }
                slot++;
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
                slot++;
                break;
            case 2:
                t = serialRead();
                if (t) {
                    lcdChar(t);
                    serialSend(t);
                }
                slot++;
                break;
            case 3:
                v = adcRead(2);
                ssdDigit(((v / 1) % 10), 3);
                ssdDigit(((v / 10) % 10), 2);
                ssdDigit(((v / 100) % 10), 1);
                ssdDigit(((v / 1000) % 10), 0);
            default:
                slot = 0;
                break;
        }

        ssdUpdate();
        timerWait();
    }
}
