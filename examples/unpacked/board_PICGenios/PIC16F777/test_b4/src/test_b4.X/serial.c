/* ########################################################################

   PICsim - PIC simulator http://sourceforge.net/projects/picsim/

   ########################################################################

   Copyright (c) : 2014-2016  Luis Claudio Gamb�a Lopes

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
#include"serial.h"
#include"atraso.h"
#include"config.h"

#define B9600H ((_XTAL_FREQ/(16l*9600))-1)
#define B9600L ((_XTAL_FREQ/(64l*9600))-1)


void serial_init(void)
{
               //  brgh=1 baud=FOSC/16(X+1)
               //  brgh=0 baud=FOSC/64(X+1)
#if B9600H < 255   
    SPBRG=B9600H; 
    TXSTAbits.BRGH=1;  //high baud rate
#else
    SPBRG=B9600L; 
    TXSTAbits.BRGH=0;  //low baud rate   
#endif    
      
	//Configuracao da serial
    TXSTAbits.TX9=0;    //transmissao em 8 bits
    TXSTAbits.TXEN=1;  //habilita transmissao
    TXSTAbits.SYNC=0;  //modo assincrono
    RCSTAbits.SPEN=1;  //habilita porta serial - rx
    RCSTAbits.RX9=0;   //recepcao em 8 bits
    RCSTAbits.CREN=1;  //recepcao continua


}

void serial_end(void)
{
    RCSTAbits.SPEN=0;  //desabilita porta serial - rx
    TXSTAbits.TXEN=0;  //desabilita transmissao
    RCSTAbits.CREN=0;  //recepcao continua
}


void serial_tx(unsigned char val)
{
  TXREG=val;
  while(!TXSTAbits.TRMT);
}

void serial_tx_str(const char* val)
{
  unsigned int i=0;
  
  while(val[i])
  {
    serial_tx(val[i]);
    i++; 
  }
}

unsigned char serial_rx(unsigned int timeout)
{
  unsigned int to=0;

  if(RCSTAbits.FERR || RCSTAbits.OERR)//trata erro
  {
      RCSTAbits.CREN=0;
      RCSTAbits.CREN=1;
  }
#ifdef _18F47K40
    while(((to < timeout)||(!timeout))&&(!PIR3bits.RC1IF))
#else  
  while(((to < timeout)||(!timeout))&&(!PIR1bits.RCIF))
#endif      
  {
    atraso_ms(20);
    to+=20; 
  }
#ifdef _18F47K40
  if(PIR3bits.RC1IF)
#else  
  if(PIR1bits.RCIF)
#endif      
    return RCREG;
  else
    return 0xA5;
}
