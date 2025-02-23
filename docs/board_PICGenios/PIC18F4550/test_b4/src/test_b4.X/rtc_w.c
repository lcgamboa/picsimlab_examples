/* ########################################################################

   PICsim - PIC simulator http://sourceforge.net/projects/picsim/

   ########################################################################

   Copyright (c) : 2015  Luis Claudio Gambôa Lopes

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
#include"i2c.h"

void rtc_w(void)
{
   i2c_start();          // issue start signal
   i2c_wb(0xD0);         // address ds1307
   i2c_wb(0);            // start from word at address 0 (configuration word)
   i2c_wb(0x34);         // write seconds word
   i2c_wb(0x46);         // write minutes word
   i2c_wb(0x15 | 0x40);  // write hours word + 24
   i2c_wb(0x06);         // write weekday
   i2c_wb(0x21);         // write day word
   i2c_wb(0x02);         // write month
   i2c_wb(0x25);         // write year
   i2c_wb(0x00);         // write ctrl
   i2c_stop();           // issue stop signa
}

