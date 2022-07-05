
#include <xc.h>


#include "config.h" 
#include "serial.h"
#include "Adafruit_BMP085.h"
#include "itoa.h"
#include "dht.h"
#include "OneWire.h"
#include "lcd_4.h" //ds18b20

#define byte unsigned char

#define SAIDA1 LATBbits.LATB1

#define TLIGA 290
#define TDESL 288

//sem definir usa DHT22
//#define DHT11

const char * erros[] = {
    "ERR: NONE",
    "ERR:BMP085 Fault",
    "ERR:DHT22 CSum.",
    "ERR:DHT22 Tout",
    "ERR:DHT22 Conn.",
    "ERR:DHT22 Ack L.",
    "ERR:DHT22 Ack H.",
    "ERR:DHT22 Unkn.",
    "ERR:DS18B20 read",
};

int main() {

    char strbuff[20];
    _BMP085 bmp;
    unsigned char bmp_started = 0;
    struct OneWire ds; // on pin 10 (a 4.7K resistor is necessary)
    _dht dht;
    byte i;
    byte present = 0;
    byte owdata[12];
    byte addr1[8] = {0x28, 0xFF, 0x64, 0x7E, 0x60, 0x17, 0x03, 0x3E};
    int celsius = 0;
    float bmp_temp = 0;
    float bmp_press = 0;
    int16_t raw;
    byte cfg;
    byte erro;

    ADCON1 = 0x0F;

    TRISCbits.TRISC3 = 0; //i2c CLK
    TRISCbits.TRISC4 = 0; //i2c DAT

    TRISAbits.TRISA2 = 1; //Onewire

    TRISAbits.TRISA3 = 1; //DHT

    TRISCbits.TRISC6 = 0; //TX
    TRISCbits.TRISC7 = 1; //RX

    TRISBbits.TRISB1 = 0; //SAIDA1

    //inicia LEDS desligados
    SAIDA1 = 0;

    //inicia i2c
    PORTCbits.RC3 = 1;
    PORTCbits.RC4 = 1;


    serial_init();

    lcd4_init();
    lcd4_cmd(L_CLR);
    lcd4_cmd(L_NCR);
    lcd4_str("Start");

    OneWire_Init(&ds, &PORTA, &TRISA, 2);
    dht_init(&dht, &PORTA, &TRISA, 3);

    __delay_ms(2000);
    dht_read(&dht); //for start

    if (bmp_begin(&bmp, BMP085_ULTRAHIGHRES)) {
        bmp_started = 1;
    } else {
        serial_tx_str("Could not find a valid BMP085 sensor, check wiring!\r\n");
    }

    __delay_ms(100);

    while (1) {
        erro = 0;

        if (bmp_started) {
            //bmp180
            bmp_temp = bmp_readTemperature(&bmp);
            bmp_press = bmp_readPressure(&bmp);

        } else {
            if (bmp_begin(&bmp, BMP085_ULTRAHIGHRES)) {
                bmp_started = 1;
            } else {
                erro |= 0x01;
            }
        }

        //DHT11 -----------------------------------------------------------------------

        __delay_ms(1000);

        // READ DATA
#ifdef DHT11
        char chk = dht_read11(&dht);
#else //DHT22
        char chk = dht_read(&dht);
#endif
        switch (chk) {
            case DHTLIB_OK:
                break;
            case DHTLIB_ERROR_CHECKSUM:
                erro |= 0x02;
                break;
            case DHTLIB_ERROR_TIMEOUT:
                erro |= 0x04;
                break;
            case DHTLIB_ERROR_CONNECT:
                erro |= 0x08;
                break;
            case DHTLIB_ERROR_ACK_L:
                erro |= 0x10;
                break;
            case DHTLIB_ERROR_ACK_H:
                erro |= 0x20;
                break;
            default:
                erro |= 0x40;
                break;
        }

        __delay_ms(20);


        //sensor1 -------------------------------------------------------------------
        OneWire_reset(&ds);
        OneWire_select(&ds, addr1);
        OneWire_write(&ds, 0x44); // start conversion, with parasite power on at the end

        __delay_ms(1000); // maybe 750ms is enough, maybe not
        // we might do a ds.depower() here, but the reset will take care of it.

        present = OneWire_reset(&ds);
        OneWire_select(&ds, addr1);
        OneWire_write(&ds, 0xBE); // Read Scratchpad


        for (i = 0; i < 9; i++) { // we need 9 bytes
            owdata[i] = OneWire_read(&ds);
        }

        // Convert the data to actual temperature
        // because the result is a 16 bit signed integer, it should
        // be stored to an "int16_t" type, which is always 16 bits
        // even when compiled on a 32 bit processor.
        raw = (owdata[1] << 8) | owdata[0];

        cfg = (owdata[4] & 0x60);
        // at lower res, the low bits are undefined, so let's zero them
        if (cfg == 0x00) raw = raw & ~7; // 9 bit resolution, 93.75 ms
        else if (cfg == 0x20) raw = raw & ~3; // 10 bit res, 187.5 ms
        else if (cfg == 0x40) raw = raw & ~1; // 11 bit res, 375 ms
        //// default is 12 bit resolution, 750 ms conversion time
        //}
        celsius = 10 * raw / 16;

        //controle ventilador


        if (celsius) {
            if (celsius > TLIGA) //temp liga 28,5
                SAIDA1 = 1;

            if (celsius <= TDESL) //temp desliga
                SAIDA1 = 0;
        } else {
            erro |= 0x80;
            celsius = (int) (bmp_temp * 10);
            if (celsius > (TLIGA + 30)) //temp liga 28,5
                SAIDA1 = 1;

            if (celsius <= (TDESL + 30)) //temp desliga
                SAIDA1 = 0;
        }


        lcd4_cmd(L_L1);
        //imprime saídas

#ifdef DHT11
        lcd4_str("DHT:");
        serial_tx_str("DHT:");
        
        utoa(dht.temperature, strbuff);
        serial_tx(strbuff[2]);
        serial_tx(strbuff[3]);
        serial_tx(strbuff[4]);
        serial_tx_str(" ");

        lcd4_dat(strbuff[2]);
        lcd4_dat(strbuff[3]);
        lcd4_dat(strbuff[4]);
        lcd4_str("C");
        lcd4_str(" ");
#else //DHT22
        lcd4_str("DHT:");
        serial_tx_str("DHT:");
        
        itoa(dht.temperature, strbuff);
        serial_tx(strbuff[0]);
        serial_tx(strbuff[3]);
        serial_tx(strbuff[4]);
        serial_tx_str(".");
        serial_tx(strbuff[5]);
        serial_tx_str(" ");

        lcd4_dat(strbuff[0]);
        lcd4_dat(strbuff[3]);
        lcd4_dat(strbuff[4]);
        lcd4_str(".");
        lcd4_dat(strbuff[5]);
        lcd4_str("C");
        lcd4_str(" ");
#endif  
        
                // DHT11
#ifdef DHT11
        utoa(dht.humidity, strbuff);
        serial_tx(strbuff[2]);
        serial_tx(strbuff[3]);
        serial_tx(strbuff[4]);
        serial_tx_str(" ");

        lcd4_dat(strbuff[2]);
        lcd4_dat(strbuff[3]);
        lcd4_dat(strbuff[4]);
        lcd4_str(" ");
#else //DHT22
        utoa(dht.humidity, strbuff);
        serial_tx(strbuff[1]);
        serial_tx(strbuff[2]);
        serial_tx(strbuff[3]);
        serial_tx_str("% ");

        lcd4_dat(strbuff[1]);
        lcd4_dat(strbuff[2]);
        lcd4_dat(strbuff[3]);
        lcd4_str("%");
#endif 


        lcd4_cmd(L_L2);
        lcd4_str("BMP:");
        serial_tx_str("BMP:");
        
        
        ltoa((long) bmp_press, strbuff);

        serial_tx(strbuff[6]);
        serial_tx(strbuff[7]);
        serial_tx(strbuff[8]);
        serial_tx(strbuff[9]);
        serial_tx(strbuff[10]);
        serial_tx(strbuff[11]);
        serial_tx_str(" ");

        lcd4_dat(strbuff[6]);
        lcd4_dat(strbuff[7]);
        lcd4_dat(strbuff[8]);
        lcd4_dat(strbuff[9]);
        lcd4_dat(strbuff[10]);
        lcd4_dat(strbuff[11]);
        lcd4_str(" ");

        itoa(bmp_temp*10, strbuff);
        serial_tx(strbuff[0]);
        serial_tx(strbuff[3]);
        serial_tx(strbuff[4]);
        serial_tx('.');
        serial_tx(strbuff[5]);
        serial_tx_str(" ");

        lcd4_dat(strbuff[0]);
        lcd4_dat(strbuff[3]);
        lcd4_dat(strbuff[4]);
        lcd4_dat('.');
        lcd4_dat(strbuff[5]);
        lcd4_str("C");
        
 

        lcd4_cmd(L_L3);
        lcd4_str("DS1:");
        serial_tx_str("DS1:");
        
        //ds18b20 1
        itoa(celsius, strbuff);
        serial_tx(strbuff[0]);
        serial_tx(strbuff[3]);
        serial_tx(strbuff[4]);
        serial_tx('.');
        serial_tx(strbuff[5]);
        serial_tx_str(" ");

        lcd4_dat(strbuff[0]);
        lcd4_dat(strbuff[3]);
        lcd4_dat(strbuff[4]);
        lcd4_dat('.');
        lcd4_dat(strbuff[5]);
        lcd4_str("C");


        lcd4_cmd(L_L4);
        lcd4_str("OUT:");
        serial_tx_str("OUT:");
        
        //on/off status
        serial_tx(' ');
        serial_tx(SAIDA1 + 0x30);
        serial_tx(' ');

        lcd4_dat(' ');
        lcd4_dat(SAIDA1 + 0x30);
        lcd4_dat(' ');
        
        lcd4_str(" ERR:");
        serial_tx_str(" ERR:");

        utoah(erro, strbuff);
        serial_tx_str("0x");
        serial_tx(strbuff[4]);
        serial_tx(strbuff[5]);
        serial_tx_str("\r\n");

        lcd4_dat(strbuff[4]);
        lcd4_dat(strbuff[5]);


        if (erro) {
            serial_tx_str("Erros:\r\n");

            for (int i = 0; i < 8; i++) {
                if (erro & (1 << i)) {
                    serial_tx_str("---> ");
                    serial_tx_str(erros[i + 1]);
                    serial_tx_str("\r\n");
                }
            }
        }
    }

    return 0;
}