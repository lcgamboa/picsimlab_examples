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

#include <xc.h>
#include "adc.h"
#include "config.h"

void adc_init(void)
{
#if defined (_18F452) || defined(_16F877A)
  ADCON1=0x02;
  ADCON0=0x41;
#elif defined(_18F47K40)
  ADCON0=0x80;
#else
  ADCON0=0x01;
  ADCON1=0x0B;
  ADCON2=0x01;
#endif
  
 

}

unsigned int adc_amostra(unsigned char canal)
{

#ifdef    _18F47K40
      ADPCH=canal;
#else    
    ADCON0bits.CHS=canal;
#endif
    __delay_us(20);
    
    ADCON0bits.GO=1;
    while(ADCON0bits.GO == 1);

   return ((((unsigned int)ADRESH)<<2)|(ADRESL>>6));
}
