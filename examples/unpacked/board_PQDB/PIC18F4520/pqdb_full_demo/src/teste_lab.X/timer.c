// -----------------------------------------------------------------------
//   Copyright (C) Rodrigo Almeida 2010
// -----------------------------------------------------------------------
//   Arquivo: timer.c
//            Biblioteca de operação do timer1 do PIC18F4520
//   Autor:   Rodrigo Maximiano Antunes de Almeida
//            rodrigomax at unifei.edu.br
//   Licença: GNU GPL 2
// -----------------------------------------------------------------------
//   This program is free software; you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation; version 2 of the License.
//
//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
// -----------------------------------------------------------------------

#include <pic18f4520.h>
#include "timer.h"
#include "bits.h"
#include "io.h"


char timerEnded(void)
{
	return bitTst(INTCON,2);
}

void timerWait(void)
{
	while(!bitTst(INTCON,2));
}

//tempo em micro segundos
void timerReset(unsigned int tempo)
{
    unsigned int ciclos;
	
    //para placa com 8MHz 1 ms = 2 ciclos
    ciclos = tempo * 2;
	//overflow acontece com 2^15-1 = 65535 (max unsigned int)
	ciclos = 65535 - ciclos;
	
    //remover tempo de overhead
    ciclos -=50;

	TMR0H = (ciclos >> 8);   //salva a parte alta
	TMR0L = (ciclos & 0x00FF); // salva a parte baixa

	bitClr(INTCON,2); //limpa a flag de overflow
}

void timerInit(void)
{
	T0CON = 0b00001000; //configura timer 0 sem prescaler
	bitSet(T0CON,7); //liga o timer 0
}