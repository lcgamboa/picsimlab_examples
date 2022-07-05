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

#include "Adafruit_BMP085.h"
#include "sw_i2c.h"
#include "serial.h"
#include "itoa.h"
#include <math.h>

#include "config.h"

char itoabuff[20]; 

int32_t bmp_computeB5(_BMP085 *bmp, int32_t UT);
uint8_t bmp_read8(_BMP085 *bmp, uint8_t addr);
uint16_t bmp_read16(_BMP085 *bmp, uint8_t addr);
void bmp_write8(_BMP085 *bmp, uint8_t addr, uint8_t data);



uint8_t bmp_begin(_BMP085 *bmp, uint8_t mode) {
  unsigned char valor;
  
  if (mode > BMP085_ULTRAHIGHRES) 
    mode = BMP085_ULTRAHIGHRES;
  bmp->oversampling = mode;

  i2c_init();

  valor=bmp_read8(bmp,0xD0);
  //serial_tx_str("device = "); serial_tx_str(utoah((int)valor, itoabuff));serial_tx_str("\r\n");
  if (valor  != 0x55) return 0; 

  /* read calibration data */
  bmp->ac1 = bmp_read16(bmp, BMP085_CAL_AC1);
  bmp->ac2 = bmp_read16(bmp, BMP085_CAL_AC2);
  bmp->ac3 = bmp_read16(bmp, BMP085_CAL_AC3);
  bmp->ac4 = bmp_read16(bmp, BMP085_CAL_AC4);
  bmp->ac5 = bmp_read16(bmp, BMP085_CAL_AC5);
  bmp->ac6 = bmp_read16(bmp, BMP085_CAL_AC6);

  bmp->b1 = bmp_read16(bmp, BMP085_CAL_B1);
  bmp->b2 = bmp_read16(bmp, BMP085_CAL_B2);

  bmp->mb = bmp_read16(bmp, BMP085_CAL_MB);
  bmp->mc = bmp_read16(bmp, BMP085_CAL_MC);
  bmp->md = bmp_read16(bmp, BMP085_CAL_MD);
#if (BMP085_DEBUG == 1)
  serial_tx_str("ac1 = "); serial_tx_str(ltoa(bmp->ac1, itoabuff));serial_tx_str("\r\n");
  serial_tx_str("ac2 = "); serial_tx_str(ltoa(bmp->ac2, itoabuff));serial_tx_str("\r\n");
  serial_tx_str("ac3 = "); serial_tx_str(ltoa(bmp->ac3, itoabuff));serial_tx_str("\r\n");
  serial_tx_str("ac4 = "); serial_tx_str(ltoa(bmp->ac4, itoabuff));serial_tx_str("\r\n");
  serial_tx_str("ac5 = "); serial_tx_str(ltoa(bmp->ac5, itoabuff));serial_tx_str("\r\n");
  serial_tx_str("ac6 = "); serial_tx_str(ltoa(bmp->ac6, itoabuff));serial_tx_str("\r\n");

  serial_tx_str("b1 = "); serial_tx_str(ltoa(bmp->b1, itoabuff));serial_tx_str("\r\n");
  serial_tx_str("b2 = "); serial_tx_str(ltoa(bmp->b2, itoabuff));serial_tx_str("\r\n");

  serial_tx_str("mb = "); serial_tx_str(ltoa(bmp->mb, itoabuff));serial_tx_str("\r\n");
  serial_tx_str("mc = "); serial_tx_str(ltoa(bmp->mc, itoabuff));serial_tx_str("\r\n");
  serial_tx_str("md = "); serial_tx_str(ltoa(bmp->md, itoabuff));serial_tx_str("\r\n");
#endif

  return 1;
}

int32_t bmp_computeB5(_BMP085 *bmp, int32_t UT) {
  int32_t X1 = (UT - (int32_t)bmp->ac6) * ((int32_t)bmp->ac5) >> 15;
  int32_t X2 = ((int32_t)bmp->mc << 11) / (X1+(int32_t)bmp->md);
  return X1 + X2;
}

uint16_t bmp_readRawTemperature(_BMP085 *bmp) {
  bmp_write8(bmp, BMP085_CONTROL, BMP085_READTEMPCMD);
  __delay_ms(5);
#if BMP085_DEBUG == 1
  serial_tx_str("Raw temp: "); serial_tx_str(ltoa(bmp_read16(bmp,BMP085_TEMPDATA),itoabuff));serial_tx_str("\r\n");
#endif
  return bmp_read16(bmp, BMP085_TEMPDATA);
}

uint32_t bmp_readRawPressure(_BMP085 *bmp) {
  uint32_t raw;

  bmp_write8(bmp, BMP085_CONTROL, (unsigned char)(BMP085_READPRESSURECMD + (bmp->oversampling << 6)));

  if (bmp->oversampling == BMP085_ULTRALOWPOWER) 
  {
    __delay_ms(5);
  }
  else if (bmp->oversampling == BMP085_STANDARD) 
  {
    __delay_ms(8);
  }
  else if (bmp->oversampling == BMP085_HIGHRES) 
  {
    __delay_ms(14);
  }
  else 
  {
    __delay_ms(26);
  }

  raw = bmp_read16(bmp, BMP085_PRESSUREDATA);

  raw <<= 8;
  raw |= bmp_read8(bmp, BMP085_PRESSUREDATA+2);
  raw >>= (8 - bmp->oversampling);

 /* this pull broke stuff, look at it later?
  if (oversampling==0) {
    raw <<= 8;
    raw |= read8(BMP085_PRESSUREDATA+2);
    raw >>= (8 - oversampling);
  }
 */

#if BMP085_DEBUG == 1
  serial_tx_str("Raw pressure: "); serial_tx_str(ltoa(raw,itoabuff));serial_tx_str("\r\n");
#endif
  return raw;
}


int32_t bmp_readPressure(_BMP085 *bmp) {
  int32_t UT, UP, B3, B5, B6, X1=0, X2=0, X3, p;
  uint32_t B4, B7;

  UT =(int32_t) bmp_readRawTemperature(bmp);
  UP =(int32_t) bmp_readRawPressure(bmp);

#if BMP085_DEBUG == 1
  // use datasheet numbers!
  UT = 27898;
  UP = 23843;
  bmp->ac6 = 23153;
  bmp->ac5 = 32757;
  bmp->mc = -8711;
  bmp->md = 2868;
  bmp->b1 = 6190;
  bmp->b2 = 4;
  bmp->ac3 = -14383;
  bmp->ac2 = -72;
  bmp->ac1 = 408;
  bmp->ac4 = 32741;
  bmp->oversampling = 0;
#endif

  B5 = bmp_computeB5(bmp, UT);

#if BMP085_DEBUG == 1
  serial_tx_str("X1 = "); serial_tx_str(ltoa(X1,itoabuff));serial_tx_str("\r\n");
  serial_tx_str("X2 = "); serial_tx_str(ltoa(X2,itoabuff));serial_tx_str("\r\n");
  serial_tx_str("B5 = "); serial_tx_str(ltoa(B5,itoabuff));serial_tx_str("\r\n");
#endif

  // do pressure calcs
  B6 = B5 - 4000;
  X1 = ((int32_t)bmp->b2 * ( (B6 * B6)>>12 )) >> 11;
  X2 = ((int32_t)bmp->ac2 * B6) >> 11;
  X3 = X1 + X2;
  B3 = ((((int32_t)bmp->ac1*4 + X3) << bmp->oversampling) + 2) / 4;

#if BMP085_DEBUG == 1
  serial_tx_str("B6 = "); serial_tx_str(ltoa(B6,itoabuff));serial_tx_str("\r\n");
  serial_tx_str("X1 = "); serial_tx_str(ltoa(X1,itoabuff));serial_tx_str("\r\n");
  serial_tx_str("X2 = "); serial_tx_str(ltoa(X2,itoabuff));serial_tx_str("\r\n");
  serial_tx_str("B3 = "); serial_tx_str(ltoa(B3,itoabuff));serial_tx_str("\r\n");
#endif

  X1 = ((int32_t)bmp->ac3 * B6) >> 13;
  X2 = ((int32_t)bmp->b1 * ((B6 * B6) >> 12)) >> 16;
  X3 = ((X1 + X2) + 2) >> 2;
  B4 = ((uint32_t)bmp->ac4 * (uint32_t)(X3 + 32768)) >> 15;
  B7 = (((uint32_t)UP - (uint32_t)B3) * (uint32_t)( 50000UL >> bmp->oversampling ));

#if BMP085_DEBUG == 1
  serial_tx_str("X1 = "); serial_tx_str(ltoa(X1,itoabuff));serial_tx_str("\r\n");
  serial_tx_str("X2 = "); serial_tx_str(ltoa(X2,itoabuff));serial_tx_str("\r\n");
  serial_tx_str("B4 = "); serial_tx_str(ltoa(B4,itoabuff));serial_tx_str("\r\n");
  serial_tx_str("B7 = "); serial_tx_str(ltoa(B7,itoabuff));serial_tx_str("\r\n");
#endif

  if (B7 < 0x80000000) {
    p = (long)((B7 * 2) / B4);
  } else {
    p = (long)((B7 / B4) * 2);
  }
  X1 = (p >> 8) * (p >> 8);
  X1 = (X1 * 3038) >> 16;
  X2 = (-7357 * p) >> 16;

#if BMP085_DEBUG == 1
  serial_tx_str("p = "); serial_tx_str(ltoa(p,itoabuff));serial_tx_str("\r\n");
  serial_tx_str("X1 = "); serial_tx_str(ltoa(X1,itoabuff));serial_tx_str("\r\n");
  serial_tx_str("X2 = "); serial_tx_str(ltoa(X2,itoabuff));serial_tx_str("\r\n");
#endif

  p = p + ((X1 + X2 + (int32_t)3791)>>4);
#if BMP085_DEBUG == 1
  serial_tx_str("p = "); serial_tx_str(ltoa(p,itoabuff));serial_tx_str("\r\n");
#endif
  return p;
}

int32_t bmp_readSealevelPressure(_BMP085 *bmp, float altitude_meters) {
  float pressure = bmp_readPressure(bmp);
  return (int32_t)(pressure / pow(1.0-altitude_meters/44330, 5.255));
}

float bmp_readTemperature(_BMP085 *bmp) {
  int32_t UT, B5;     // following ds convention
  float temp;

  UT = bmp_readRawTemperature(bmp);

#if BMP085_DEBUG == 1
  // use datasheet numbers!
  UT = 27898;
  bmp->ac6 = 23153;
  bmp->ac5 = 32757;
  bmp->mc = -8711;
  bmp->md = 2868;
#endif

  B5 = bmp_computeB5(bmp, UT);
  temp = (B5+8) >> 4;
  temp /= 10;
  
  return temp;
}

float bmp_readAltitude(_BMP085 *bmp, float sealevelPressure) {
  float altitude;

  float pressure = bmp_readPressure(bmp);

  altitude = (float)(44330L * (1.0 - pow(pressure /sealevelPressure,0.1903)));

  return altitude;
}


/*********************************************************************/

uint8_t bmp_read8(_BMP085 *bmp, uint8_t a) {
  uint8_t ret;
  

  //Wire.beginTransmission(BMP085_I2CADDR); // start transmission to device 
  i2c_start();
  i2c_wb(BMP085_I2CADDR & 0XFE);
  i2c_wb(a); // sends register address to read from
  i2c_stop(); // end transmission
  

  //Wire.beginTransmission(BMP085_I2CADDR); // start transmission to device 
  i2c_start();
  //Wire.requestFrom(BMP085_I2CADDR, 1);// send data n-bytes read
  i2c_wb(BMP085_I2CADDR);
  ret = i2c_rb(0); // receive DATA

  i2c_stop(); // end transmission

  return ret;
}

uint16_t bmp_read16(_BMP085 *bmp, uint8_t a) {
  uint16_t ret;

  //Wire.beginTransmission(BMP085_I2CADDR); // start transmission to device 
  i2c_start();
  i2c_wb(BMP085_I2CADDR & 0xFE);
  i2c_wb(a); // sends register address to read from
  i2c_stop(); // end transmission
  
  //Wire.beginTransmission(BMP085_I2CADDR); // start transmission to device 
  i2c_start();
  //Wire.requestFrom(BMP085_I2CADDR, 2);// send data n-bytes read
  i2c_wb(BMP085_I2CADDR);
 
  ret = i2c_rb(1); // receive DATA
  ret <<= 8;
  ret |= i2c_rb(0); // receive DATA

  i2c_stop(); // end transmission

  return ret;
}

void bmp_write8(_BMP085 *bmp, uint8_t a, uint8_t d) {
  //Wire.beginTransmission(BMP085_I2CADDR); // start transmission to device 
  i2c_start();
  i2c_wb(BMP085_I2CADDR & 0xFE);  
  i2c_wb(a); // sends register address to read from
  i2c_wb(d);  // write data
  i2c_stop(); // end transmission
}
