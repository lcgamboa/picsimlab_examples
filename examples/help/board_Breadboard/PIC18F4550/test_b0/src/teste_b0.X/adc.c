/* ########################################################################

   PICsim - PIC simulator http://sourceforge.net/projects/picsim/

   ########################################################################

   Copyright (c) : 2015  Luis Claudio Gamb�a Lopes

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


void adc_init(void)
{
#if defined (_16F1939) 
    // cofuguration de base � �crire
    // GO_nDONE stop; ADON enabled; CHS AN0; 
    ADCON0 = 0x01;
    // ADFM left; ADNREF VSS; ADPREF VDD; ADCS FOSC/4; 
    ADCON1 = 0x10;   
/*    // ADRESL 0; 
    ADRESL = 0x00;
    // ADRESH 0; 
    ADRESH = 0x00;*/
#elif  defined (_18F452) || defined(_16F877A)
  ADCON1=0x02;
  ADCON0=0x41; 
#else
  ADCON0=0x01;
  ADCON1=0x0B;
  ADCON2=0x01;
#endif


}

unsigned int adc_amostra(unsigned char canal)
{

#if defined(_18F4620) || defined(_18F4550) || defined(_16F1939))
    switch(canal)
    {
      case 0: 
        ADCON0=0x01;
        break;
      case 1: 
        ADCON0=0x05;
        break;
      case 2: 
        ADCON0=0x09;
        break;
    }
#else   
     switch(canal)
    {
      case 0:
        ADCON0=0x01;
        break;
      case 1:
        ADCON0=0x09;
        break;
      case 2:
        ADCON0=0x11;
        break;
    }   
#endif
   
#ifdef _16F1939
     ADCON0bits.GO_nDONE = 1;
     while (ADCON0bits.GO_nDONE == 1);
#else  
    ADCON0bits.GO=1;
    while(ADCON0bits.GO == 1);
#endif
   return ((((unsigned int)ADRESH)<<2)|(ADRESL>>6));
}
