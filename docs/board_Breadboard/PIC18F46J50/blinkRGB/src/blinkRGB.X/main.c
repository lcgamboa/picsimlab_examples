/*
 * File:   main.c
 * Author: gamboa
 *
 * Created on 2 de Janeiro de 2022, 18:40
 */

#define _XTAL_FREQ 8000000L

#include <xc.h>

#ifdef _16F18324
#include "config_16F18324.h"
#endif
#ifdef _16F18855
#include "config_16F18855.h"
#endif
#ifdef _18F47K40
#include "config_18F47K40.h"
#endif
#ifdef _16F1619
#include "config_16F1619.h"
#endif
#ifdef _16F1788
#include "config_16F1788.h"
#endif
#ifdef _18F27K40
#include "config_18F27K40.h"
#endif
#ifdef _18F46J50
#include "config_18F46J50.h"
#endif
#ifdef _18F67J94
#include "config_18F67J94.h"
#endif

void 
main(void) {
    
#if !defined(_18F46J50) && !defined(_18F67J94)    
    ANSELA=0x00; //all digital
#endif
    
    TRISA=0xF8; //RA0, RA1 and RA2 output
    PORTA=0;
    while(1)
    {
      PORTA++;
      __delay_ms(500);
    }
}
