#include "config.h"
#include "lcd.h"
#include "itoa.h"
#include <math.h>

void setup() {
    lcd_init();
    lcd_cmd(L_NCR);
    lcd_str("LDR Lux meter");
}

#define GAMMA  0.7
#define RL10  20000

float v;
float Rl;
unsigned long lux;
unsigned int val;
char buff[6];

void loop() {
    val = adc_sample(0);
    utoa(val, buff);
    lcd_cmd(L_L2);
    lcd_str(buff + 1);

    v =  (val * 5.0 / 1023.0);
    Rl = ((10000.0 * v) / (5.0 - v));
    lux = (long)(10.0 * pow(10, log10(RL10 / Rl) / GAMMA));

    if (lux < 10000) {
        utoa(lux, buff);
        lcd_cmd(L_L2 + 6);
        lcd_str("Lux=");
        lcd_str(buff);
        lcd_str(" ");
    } else {
        lux /=1000;
        utoa(lux, buff);
        lcd_cmd(L_L2 + 6);
        lcd_str("Lux=");
        lcd_str(buff);
        lcd_str("k");
    }
}
