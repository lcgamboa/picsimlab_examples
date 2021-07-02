// -----------------------------------------------------------------------
//   Copyright (C) Rodrigo Almeida 2010
// -----------------------------------------------------------------------
//   Arquivo: adc.c
//            Biblioteca do conversor AD para o PIC18F4520
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

#include "adc.h"
#include <pic18f4520.h>
#include "io.h"
#include "bits.h"

void adcInit(void) {
    //AN0-A0, AN1-A1 e AN2-A2 são analógicos e entradas
    pinMode(PIN_A0, INPUT);
    pinMode(PIN_A1, INPUT);
    pinMode(PIN_A2, INPUT);

    bitSet(ADCON0, 0); //liga ADC
    //config an0-2 como analógico
    ADCON1 = 0b00001100; //AN0,AN1 e AN2 são analogicos, a referencia é baseada na fonte
    ADCON2 = 0b10101010; //FOSC /32, 12 TAD, Alinhamento à direita e tempo de conv = 12 TAD
    
}

int adcRead(unsigned int channel) {
    unsigned int ADvalor;
    ADCON0 &= 0b11000011; //zera os bits do canal
    if (channel < 3) {
        ADCON0 |= channel << 2;
    }
    
    ADCON0 |= 0b00000010; //inicia conversao

    while (bitTst(ADCON0, 1)); // espera terminar a conversão;

    ADvalor = ADRESH; // le o resultado
    ADvalor <<= 8;
    ADvalor += ADRESL;
    return ADvalor;
}