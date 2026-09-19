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

char * utoa(unsigned int val, char* str) {
    str[0] = (val / 10000) + 0x30;
    str[1] = ((val % 10000) / 1000) + 0x30;
    str[2] = ((val % 1000) / 100) + 0x30;
    str[3] = ((val % 100) / 10) + 0x30;
    str[4] = (val % 10) + 0x30;
    str[5] = 0;

    //remove right zeros
    if (str[0] == 0x30) {
        str[0] = ' ';
        if (str[1] == 0x30) {
            str[1] = ' ';
            if (str[2] == 0x30) {
                str[2] = ' ';
                if (str[3] == 0x30) {
                    str[3] = ' ';
                }
            }

        }
    }
    return str;
}

char * itoa( int val, char* str )
{
    if(val >= 0)
    {
       utoa((unsigned int)val,str+1);
       str[0]='+';
    }
    else
    {
       utoa(((unsigned int)(-val)),str+1);
       str[0]='-';
    }
    
    return str;
}
