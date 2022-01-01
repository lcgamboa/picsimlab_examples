#include "config.h"
#include "lcd.h"
#include "itoa.h"

void setup() {

    lcd_init();
    lcd_cmd(L_NCR);
    lcd_str("ADC ext ref");

    TRISAbits.TRISA3 = 1;
#if defined(_18F4550)       
    ADCON1bits.VCFG0 = 1; //VREF+= AN3
    ADCON1bits.PCFG = 0x0B; // AN0 to AN3 analog        
#endif
#if defined(_16F877A)    
    ADCON1bits.PCFG = 0x01; // AN0 to AN2 analog  VREF+= AN3      
#endif
#if defined(_16F887)    
    ANSELbits.ANS3 = 1;
    ADCON1bits.VCFG0 = 1; //VREF+= AN3     
#endif
    
}

int value;
char buff[6];

void loop() {

    value = adc_sample(0);
    itoa(value, buff);
    lcd_cmd(L_L2);
    lcd_str(buff);

    lcd_cmd(L_L2 + 8);
    lcd_str("T=");
    // Vout = 10mV/°C + 500mV
    value = ((value * 175l / 1023) - 50);

    if (value >= 0) {
        itoa(value, buff);
        lcd_str(buff + 2);
    }
    else {
        itoa(-value, buff);
        buff[2] = '-';
        lcd_str(buff + 2);
        lcd_str("C");
    }

}
