/*************************************************** 
  This is a library for the Adafruit BMP085/BMP180 Barometric Pressure + Temp sensor

  Designed specifically to work with the Adafruit BMP085 or BMP180 Breakout 
  ----> http://www.adafruit.com/products/391
  ----> http://www.adafruit.com/products/1603

  These displays use I2C to communicate, 2 pins are required to  
  interface
  Adafruit invests time and resources providing this open source code, 
  please support Adafruit and open-source hardware by purchasing 
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.  
  BSD license, all text above must be included in any redistribution
 ****************************************************/

#ifndef ADAFRUIT_BMP085_H
#define ADAFRUIT_BMP085_H

#include<stdint.h>

/*
#define uint8_t unsigned char
#define int16_t int
#define uint16_t unsigned int
#define int32_t long 
#define uint32_t unsigned long 
*/

#define BMP085_DEBUG 0

#define BMP085_I2CADDR 0xEF

#define BMP085_ULTRALOWPOWER 0
#define BMP085_STANDARD      1
#define BMP085_HIGHRES       2
#define BMP085_ULTRAHIGHRES  3
#define BMP085_CAL_AC1           0xAA  // R   Calibration data (16 bits)
#define BMP085_CAL_AC2           0xAC  // R   Calibration data (16 bits)
#define BMP085_CAL_AC3           0xAE  // R   Calibration data (16 bits)    
#define BMP085_CAL_AC4           0xB0  // R   Calibration data (16 bits)
#define BMP085_CAL_AC5           0xB2  // R   Calibration data (16 bits)
#define BMP085_CAL_AC6           0xB4  // R   Calibration data (16 bits)
#define BMP085_CAL_B1            0xB6  // R   Calibration data (16 bits)
#define BMP085_CAL_B2            0xB8  // R   Calibration data (16 bits)
#define BMP085_CAL_MB            0xBA  // R   Calibration data (16 bits)
#define BMP085_CAL_MC            0xBC  // R   Calibration data (16 bits)
#define BMP085_CAL_MD            0xBE  // R   Calibration data (16 bits)

#define BMP085_CONTROL           0xF4 
#define BMP085_TEMPDATA          0xF6
#define BMP085_PRESSUREDATA      0xF6
#define BMP085_READTEMPCMD          0x2E
#define BMP085_READPRESSURECMD            0x34


typedef struct  {       
  uint8_t oversampling;
  int16_t ac1, ac2, ac3, b1, b2, mb, mc, md;
  uint16_t ac4, ac5, ac6;
} _BMP085;

 
  uint8_t bmp_begin(_BMP085 *bmp, uint8_t mode );  // by default go highres BMP085_ULTRAHIGHRES
  float bmp_readTemperature(_BMP085 *bmp);
  int32_t bmp_readPressure(_BMP085 *bmp);
  int32_t bmp_readSealevelPressure(_BMP085 *bmp, float altitude_meters ); // 0
  float bmp_readAltitude(_BMP085 *bmp, float sealevelPressure ); // std atmosphere 101325
  uint16_t bmp_readRawTemperature(_BMP085 *bmp);
  uint32_t bmp_readRawPressure(_BMP085 *bmp);
  

#endif //  ADAFRUIT_BMP085_H
