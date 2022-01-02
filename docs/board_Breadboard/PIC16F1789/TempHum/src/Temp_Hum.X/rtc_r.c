/* ########################################################################

   PICsim - PIC simulator http://sourceforge.net/projects/picsim/

   ########################################################################

   Copyright (c) : 2015-2017  Luis Claudio Gambôa Lopes

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

   For e-mail suggestions :  lcgamboa@yahoo.com
   ######################################################################## */

#include"rtc.h"
#include"sw_i2c.h"

volatile char date[10];
volatile char time[10];


unsigned char getd(unsigned char nn)
{
 return ((nn & 0xF0)>>4)+0x30;
}

unsigned char getu(unsigned char nn)
{
  return (nn  & 0x0F)+0x30;
}

//--------------------- Reads time and date information from RTC (DS1307)
void rtc_r(void) 
{
  unsigned char tmp;

  i2c_start();
  i2c_wb(0xD0);
  i2c_wb(0);

  i2c_start();
  i2c_wb(0xD1);
  tmp= 0x7F & i2c_rb(1); //segundos
  time[5]=':';
  time[6]=getd(tmp);
  time[7]=getu(tmp);
  time[8]=0;

  tmp= 0x7F & i2c_rb(1); //minutos
  time[2]=':';
  time[3]=getd(tmp);
  time[4]=getu(tmp);

  tmp= 0x3F & i2c_rb(1); //horas
  time[0]=getd(tmp);
  time[1]=getu(tmp);

  i2c_rb(1); //dia semana

  tmp= 0x3F & i2c_rb(1); //dia
  date[0]=getd(tmp);
  date[1]=getu(tmp);


  tmp= 0x1F & i2c_rb(1); //mes
  date[2]='/'; 
  date[3]=getd(tmp);
  date[4]=getu(tmp);

  tmp=  i2c_rb(0); //ano
  date[5]='/';
  date[6]=getd(tmp);
  date[7]=getu(tmp);
  date[8]=0;

  i2c_stop();

}

unsigned char bin2bcd(const unsigned char binary_value)
{
unsigned char temp;
unsigned char retval;

temp = binary_value;
retval = 0;

while(1)
{
// Get the tens digit by doing multiple subtraction
// of 10 from the binary value.
  if(temp >= 10)
  {
   temp -= 10;
   retval += 0x10;
  }
  else // Get the ones digit by adding the remainder.
  {
   retval += temp;
   break;
  }
}

return(retval);
}

void rtc_w(const unsigned char day,const unsigned char mth,const unsigned char year,const unsigned char dow,
           const unsigned char hr, const unsigned char min, const unsigned char sec)
{
unsigned char sec_ = sec & 0x7F;
unsigned char hr_ = hr & 0x3F;

i2c_start();
i2c_wb(0xD0); // I2C write address
i2c_wb(0x00); // Start at REG 0 - Seconds
i2c_wb(bin2bcd(sec_)); // REG 0
i2c_wb(bin2bcd(min)); // REG 1
i2c_wb(bin2bcd(hr_));  // REG 2
i2c_wb(bin2bcd(dow)); // REG 3
i2c_wb(bin2bcd(day)); // REG 4
i2c_wb(bin2bcd(mth)); // REG 5
i2c_wb(bin2bcd(year));// REG 6
i2c_wb(0x80); // REG 7 - Disable squarewave output pin
i2c_stop();
}

