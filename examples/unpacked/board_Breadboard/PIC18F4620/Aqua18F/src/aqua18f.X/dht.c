//
//    FILE: dht.cpp
//  AUTHOR: Rob Tillaart
// VERSION: 0.1.21
// PURPOSE: DHT Temperature & Humidity Sensor library for Arduino
//     URL: http://arduino.cc/playground/Main/DHTLib
//
// HISTORY:
// 0.1.21 replace delay with delayMicroseconds() + small fix
// 0.1.20 Reduce footprint by using uint8_t as error codes. (thanks to chaveiro)
// 0.1.19 masking error for DHT11 - FIXED (thanks Richard for noticing)
// 0.1.18 version 1.16/17 broke the DHT11 - FIXED
// 0.1.17 replaced micros() with adaptive loopcount
//        removed DHTLIB_INVALID_VALUE
//        added  DHTLIB_ERROR_CONNECT
//        added  DHTLIB_ERROR_ACK_L  DHTLIB_ERROR_ACK_H
// 0.1.16 masking unused bits (less errors); refactored bits[]
// 0.1.15 reduced # micros calls 2->1 in inner loop.
// 0.1.14 replace digital read with faster (~3x) code => more robust low MHz machines.
//
// 0.1.13 fix negative temperature
// 0.1.12 support DHT33 and DHT44 initial version
// 0.1.11 renamed DHTLIB_TIMEOUT
// 0.1.10 optimized faster WAKEUP + TIMEOUT
// 0.1.09 optimize size: timeout check + use of mask
// 0.1.08 added formula for timeout based upon clockspeed
// 0.1.07 added support for DHT21
// 0.1.06 minimize footprint (2012-12-27)
// 0.1.05 fixed negative temperature bug (thanks to Roseman)
// 0.1.04 improved readability of code using DHTLIB_OK in code
// 0.1.03 added error values for temp and humidity when read failed
// 0.1.02 added error codes
// 0.1.01 added support for Arduino 1.0, fixed typos (31/12/2011)
// 0.1.00 by Rob Tillaart (01/04/2011)
//
// inspired by DHT11 library
//
// Released to the public domain
//

#include "dht.h"
#include "config.h"


  unsigned char bits[5];  // buffer to receive data
  
  signed char readSensor(_dht *dht, unsigned char wakeupDelay, unsigned char leadingZeroBits);


void dht_init(_dht * dht, volatile unsigned char *port, volatile unsigned char *ddr, unsigned char pin)
{
    dht->bitmask =(unsigned char) (1<<pin);
    dht->port = port;
    dht->ddr = ddr;  
    *dht->ddr|= dht->bitmask; //input
}
  

char dht_read11(_dht *dht)
{
    // READ VALUES
    char result = (char )readSensor(dht, DHTLIB_DHT11_WAKEUP, DHTLIB_DHT11_LEADING_ZEROS);

    // these bits are always zero, masking them reduces errors.
    bits[0] &= 0x7F;
    bits[2] &= 0x7F;

    // CONVERT AND STORE
    dht->humidity    = bits[0];  // bits[1] == 0;
    dht->temperature = bits[2];  // bits[3] == 0;

    // TEST CHECKSUM
    // bits[1] && bits[3] both 0
    unsigned char sum = bits[0] + bits[2];
    if (bits[4] != sum)
    {
        return DHTLIB_ERROR_CHECKSUM;
    }
    return result;
}

char dht_read(_dht *dht)
{
    // READ VALUES
    char result = (char) readSensor(dht, DHTLIB_DHT_WAKEUP, DHTLIB_DHT_LEADING_ZEROS);

    if(result != DHTLIB_OK)return result; 
   
    // these bits are always zero, masking them reduces errors.
    bits[0] &= 0x03;
    bits[2] &= 0x83;

    // CONVERT AND STORE
    dht->humidity = (bits[0]*256 + bits[1]);
    dht->temperature = ((bits[2] & 0x7F)*256 + bits[3]);
    if (bits[2] & 0x80)  // negative temperature
    {
        dht->temperature = -dht->temperature;
    }

   
    // TEST CHECKSUM
    unsigned char sum = bits[0] + bits[1] + bits[2] + bits[3];
    if (bits[4] != sum)
    {
        return DHTLIB_ERROR_CHECKSUM;
    }
    return result;
}

/////////////////////////////////////////////////////
//
// PRIVATE
//

signed char readSensor(_dht *dht, unsigned char wakeupDelay, unsigned char leadingZeroBits)
{
    // INIT BUFFERVAR TO RECEIVE DATA
    unsigned char mask = 128;
    unsigned char idx = 0;

    unsigned char data = 0;
    unsigned char state = 0;
    unsigned char pstate = 0;
    unsigned int zeroLoop = DHTLIB_TIMEOUT;
    unsigned int delta = 0;
    unsigned char i;

    leadingZeroBits = 40 - leadingZeroBits; // reverse counting...


   

    // REQUEST SAMPLE
    //pinMode(pin, OUTPUT);
    *dht->ddr&= ~dht->bitmask; //output
      //digitalWrite(pin, LOW); // T-be
    *dht->port&= ~dht->bitmask;
    if(wakeupDelay == DHTLIB_DHT_WAKEUP)
    __delay_ms(DHTLIB_DHT_WAKEUP);                 //1 or 18 ms
    else
    __delay_ms(DHTLIB_DHT11_WAKEUP);                 //1 or 18 ms
        
    //digitalWrite(pin, HIGH); // T-go
    *dht->port|= dht->bitmask;
    //pinMode(pin, INPUT);
    __delay_us(30);                          //20-40 us
    *dht->ddr|= dht->bitmask; //input
   
 
    
    unsigned int loopCount = DHTLIB_TIMEOUT * 2;  // 200uSec max
    // while(digitalRead(pin) == HIGH)
    while ((*dht->port & dht->bitmask) != 0 )       //wait response
    {
        if (--loopCount == 0) return DHTLIB_ERROR_CONNECT;
    }

    // GET ACKNOWLEDGE or TIMEOUT
    loopCount = DHTLIB_TIMEOUT;
    // while(digitalRead(pin) == LOW) 
    while ((*dht->port & dht->bitmask) ==  0)  // T-rel   //80 us low  
    {
        if (--loopCount == 0) return DHTLIB_ERROR_ACK_L;
    }

    loopCount = DHTLIB_TIMEOUT;
    // while(digitalRead(pin) == HIGH)
    while ((*dht->port & dht->bitmask) != 0 )  // T-reh   //80 us high
    {
        if (--loopCount == 0) return DHTLIB_ERROR_ACK_H;
    }

    loopCount = DHTLIB_TIMEOUT;


        
    // READ THE OUTPUT - 40 BITS => 5 BYTES
    for (i = 40; i != 0; )
    {

        //low  50 us 
        //  0- 26 to 28 us high
        //  1- 70 us high 
        
        // WAIT FOR FALLING EDGE 
        state = (*dht->port & dht->bitmask);
  
        if (state == 0 && pstate != 0)
        {
            if (i > leadingZeroBits) // DHT22 first 6 bits are all zero !!   DHT11 only 1
            {
                zeroLoop = min(zeroLoop, loopCount);
                delta = (DHTLIB_TIMEOUT - zeroLoop)/4;
            }
            else if ( loopCount <= (zeroLoop - delta) ) // long -> one
            {
                data |= mask;
            }
            mask >>= 1;
            if (mask == 0)   // next byte
            {
                mask = 128;
                bits[idx] = data;
                idx++;
                data = 0;
            }
            // next bit
            --i;

            // reset timeout flag
            loopCount = DHTLIB_TIMEOUT;
        }
        pstate = state;
        
        // Check timeout
        if (--loopCount == 0)
        {
            return DHTLIB_ERROR_TIMEOUT;
        }
    }
    //pinMode(pin, OUTPUT);
    *dht->ddr&= ~dht->bitmask; //output

    //digitalWrite(pin, HIGH);
    *dht->port|=dht->bitmask;

    
    return DHTLIB_OK;
}
//
// END OF FILE
//

