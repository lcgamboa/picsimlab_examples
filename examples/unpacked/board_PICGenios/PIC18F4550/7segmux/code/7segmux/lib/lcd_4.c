/* ########################################################################

   PICsim - PIC simulator http://sourceforge.net/projects/picsim/

   ########################################################################

   Copyright (c) : 2011  Luis Claudio Gambôa Lopes

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

#include "xc.h"
#include "lcd_4.h"
#include "config.h"

void lcd4_wr(unsigned char val) {
    LPORT = (unsigned char)((0xF0 & val) | (0x0F & LPORT));
    LENA = 0;
    __delay_us(100);
    LENA = 1;
    LPORT = (unsigned char)(((0x0F & val) << 4) | (0x0F & LPORT));
}

void lcd4_cmd(unsigned char val) {
    LENA = 1;
    LDAT = 0;
    lcd4_wr(val);
    __delay_us(100);
    LENA = 0;
    __delay_ms(2);
    LENA = 1;
}

void lcd4_dat(unsigned char val) {
    LENA = 1;
    LDAT = 1;
    lcd4_wr(val);
    __delay_us(100);
    LENA = 0;
    __delay_us(100);
    LENA = 1;
}

void lcd4_init(void) {
    TPORT &= 0x0F;
    TLENA = 0;
    TLDAT = 0;

    LENA = 0;
    LDAT = 0;
    delay(20);
    LENA = 1;

    lcd4_cmd(0x33);
    delay(5);
    lcd4_cmd(0x33);
    delay(1);
    lcd4_cmd(0x32); //configura
    lcd4_cmd(0x28); //configura
    lcd4_cmd(L_OFF);
    lcd4_cmd(L_ON); //liga
    lcd4_cmd(L_CLR); //limpa
    lcd4_cmd(L_L1);
}

void lcd4_str(const char* str) {
    unsigned char i = 0;

    while (str[i] != 0) {
        lcd4_dat(str[i]);
        i++;
    }
}

void lcd4_custom(char num, const char d1, const char d2, const char d3, const char d4, const char d5, const char d6, const char d7, const char d8) {
    unsigned char i;

    if (num < 8) {
        lcd4_cmd((unsigned char)(0x40 + num * 8));
        lcd4_dat(d1);
        lcd4_dat(d2);
        lcd4_dat(d3);
        lcd4_dat(d4);
        lcd4_dat(d5);
        lcd4_dat(d6);
        lcd4_dat(d7);
        lcd4_dat(d8);
        lcd4_cmd(L_L1);
    }
}











