//
//    FILE: dht.h
//  AUTHOR: Rob Tillaart
// VERSION: 0.1.21
// PURPOSE: DHT Temperature & Humidity Sensor library for Arduino
//     URL: http://arduino.cc/playground/Main/DHTLib
//
// HISTORY:
// see dht.cpp file
//

#ifndef dht_h
#define dht_h


#include<xc.h>

#include "config.h"


#include <stdint.h>

#define min(a,b) (a < b ? a : b)

#define DHT_LIB_VERSION "0.1.21"

#define DHTLIB_OK                    0
#define DHTLIB_ERROR_CHECKSUM        1
#define DHTLIB_ERROR_TIMEOUT         2
#define DHTLIB_ERROR_CONNECT         3
#define DHTLIB_ERROR_ACK_L           4
#define DHTLIB_ERROR_ACK_H           5

#define DHTLIB_DHT11_WAKEUP         20
#define DHTLIB_DHT_WAKEUP           2   

#define DHTLIB_DHT11_LEADING_ZEROS  1
#define DHTLIB_DHT_LEADING_ZEROS    6

// max timeout is 100 usec.
// For a 16 Mhz proc 100 usec is 1600 clock cycles
// loops using DHTLIB_TIMEOUT use at least 4 clock cycli
// so 100 us takes max 400 loops
// so by dividing F_CPU by 40000 we "fail" as fast as possible
#ifndef F_CPU
#define DHTLIB_TIMEOUT 400ul  
#else
#define DHTLIB_TIMEOUT (F_CPU/40000)
#endif


typedef struct
{
    unsigned int humidity;
    unsigned int temperature;
    unsigned char bitmask;
    volatile unsigned char *port;
    volatile unsigned char *ddr;
}_dht;

void dht_init(_dht * dht, volatile unsigned char *port, volatile unsigned char *ddr, unsigned char pin);
char dht_read11(_dht *dht);
char dht_read(_dht *dht);

#define  dht_read21(dht) read(dht)
#define  dht_read22(dht) read(dht)
#define  dht_read33(dht) read(dht)
#define  dht_read44(dht) read(dht)
  
#endif
//
// END OF FILE
//