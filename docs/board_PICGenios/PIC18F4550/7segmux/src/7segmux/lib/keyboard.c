/* ########################################################################

   PICsim - PIC simulator http://sourceforge.net/projects/picsim/

   ########################################################################

   Copyright (c) : 2015-2024  Luis Claudio Gambôa Lopes

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
#include "keyboard.h"
#include "config.h"

const unsigned char column[3] = {TC1, TC2, TC3};

#if !defined(_PIC18)
#define LATB PORTB
#endif

unsigned char keyPress(unsigned int timeout) {
    unsigned int to = 0;
    char i;
    unsigned char ret = 0;
    unsigned char tmpPB = LATB;
    unsigned char tmpTB = TRISB;
    unsigned char tmpPD = PORTD;
    unsigned char tmpTD = TRISD;

    TRISB &= 0xF8;
    TRISD |= 0x0F;
    while (((to < timeout) || (!timeout))&&(!ret)) {
        for (i = 0; i < 3; i++) {
            LATB |= (unsigned char) (~column[i]);
            if (!TR1) {
                delay(20);
                if (!TR1) {
                    while (!TR1);
                    ret = (unsigned char) (1 + i);
                    break;
                }
            };
            if (!TR2) {
                delay(20);
                if (!TR2) {
                    while (!TR2);
                    ret = (unsigned char) (4 + i);
                    break;
                }
            };
            if (!TR3) {
                delay(20);
                if (!TR3) {
                    while (!TR3);
                    ret = (unsigned char) (7 + i);
                    break;
                }
            };
            if (!TR4) {
                delay(20);
                if (!TR4) {
                    while (!TR4);
                    ret = (unsigned char) (10 + i);
                    break;
                }
            };
            LATB &= column[i];
        };
        delay(5);
        to += 5;
    }

    if (!ret)ret = 255;
    if (ret == 11)ret = 0;
    TRISB = tmpTB;
    LATB = tmpPB;
    TRISD = tmpTD;
    PORTD = tmpPD;
    return ret;
}


