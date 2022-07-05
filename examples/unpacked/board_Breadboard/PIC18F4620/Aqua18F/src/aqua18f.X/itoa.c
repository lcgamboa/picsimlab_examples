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

const char * utoa(unsigned int val, char* str )
{
  str[0]=(val/10000)+0x30;  
  str[1]=((val%10000)/1000)+0x30;  
  str[2]=((val%1000)/100)+0x30;  
  str[3]=((val%100)/10)+0x30;
  str[4]=(val%10)+0x30;
  str[5]=0;
  
  return str;
}

const char * itoa(int val, char* str )
{
  if(val < 0)
  {
      str[0]='-';
      val=-val;
  }
  else
  {
      str[0]=' ';
  }
  
  str[1]=(char)((val/10000)+0x30);  
  str[2]=(char)(((val%10000)/1000)+0x30);  
  str[3]=(char)(((val%1000)/100)+0x30);  
  str[4]=(char)(((val%100)/10)+0x30);
  str[5]=(char)((val%10)+0x30);
  str[6]=0;
  
  return str;
}

const char * ltoa(long val, char* str )
{
  if(val < 0)
  {
      str[0]='-';
      val=-val;
  }
  else
  {
      str[0]=' ';
  }
  
  str[1]=((val%100000000000l)/10000000000l)+0x30; 
  str[2]=((val%10000000000l) /1000000000l)+0x30; 
  str[3]=((val%1000000000l)  /100000000l)+0x30; 
  str[4]=((val%100000000l)   /10000000l)+0x30; 
  str[5]=((val%10000000l)    /1000000l)+0x30; 
  str[6]=((val%1000000l)     /100000l)+0x30; 
  str[7]=((val%100000l)      /10000)+0x30;  
  str[8]=((val%10000)        /1000)+0x30;  
  str[9]=((val%1000)         /100)+0x30;  
  str[10]=((val%100)         /10)+0x30;
  str[11]=((val%10)          )+0x30;
  str[12]=0;
  
  return str;
}

const char * utoah(unsigned int val, char* str )
{
  int i;
  
  str[0]='0';  
  str[1]='x';  
  str[2]=(val & 0xF000)>>12;  
  str[3]=(val & 0x0F00)>>8;
  str[4]=(val & 0x00F0)>>4;
  str[5]=(val & 0x000F);
  str[6]=0;
  
  for(i=2;i<6;i++)
  {
      if(str[i] > 9)
          str[i]+='A'-10;
      else
          str[i]+='0';
  }
  
  return str;
}

const char * ftoa(float val, char* str )
{
    ltoa((long)(val*100),str);
    
    str[13]=0;
    str[12]=str[11];
    str[11]=str[10];
    str[10]='.';
    return str;
}