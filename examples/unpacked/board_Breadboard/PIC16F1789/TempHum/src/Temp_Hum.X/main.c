#include "config.h"
#include "lcd.h"
#include "itoa.h";

void setup() {
    lcd_init();
    lcd_cmd(L_NCR);
}

char buff[6];
unsigned int val;

void loop() {
    lcd_cmd(L_L1);
    val = adc_sample(0);
    utoa(val, buff);
    lcd_str(buff);

    lcd_cmd(L_L1 + 6);
    lcd_str("T=");
    val = ((val * 5000l / 1023) - 1530) / 23;
    itoa(val, buff);
    lcd_str(buff);
    lcd_str("C");


    lcd_cmd(L_L2);
    val = adc_sample(1);
    utoa(val, buff);
    lcd_str(buff);

    lcd_cmd(L_L2 + 6);
    lcd_str("H=");
    val = ((val * 5000l / 1023) - 500) / 40;
    itoa(val, buff);
    lcd_str(buff);
    lcd_str("%");
}
