// -----------------------------------------------------------------------
//   Copyright (C) Rodrigo Almeida 2010
// -----------------------------------------------------------------------
//   Arquivo: ssd.c
//            Biblioteca de controle dos displays de 7 segmentos
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

#include <xc.h>
#include "ssd.h"
#include "io.h"
#include "so.h"

//#define DATA  PORTD

//vetor para armazenar a conversão do display
static const char valor[] = {0xD7, 0x11, 0xCD, 0x5D, 0x1B, 0x5E, 0xDE, 0x15, 0xDF, 0x5F, 0x9F, 0xDA, 0xC6, 0xD9, 0xCE, 0x8E};
//armazena qual é o display disponivel
static char display;
//armazena o valor a ser enviado ao display
static char v0, v1, v2, v3;

void ssdDigit(char val, char pos) {
    if (pos == 0) {
        v0 = val;
    }
    if (pos == 1) {
        v1 = val;
    }
    if (pos == 2) {
        v2 = val;
    }
    if (pos == 3) {
        v3 = val;
    }

}

void ssdUpdate(void) {


    //desliga todos os displays
    digitalWrite(DISP_1_PIN, LOW);
    digitalWrite(DISP_2_PIN, LOW);
    digitalWrite(DISP_3_PIN, LOW);
    digitalWrite(DISP_4_PIN, LOW);



    switch (display) //liga apenas o display da vez
    {
        case 0:
            soWrite(valor[v0]);
            digitalWrite(DISP_1_PIN, HIGH);
            display = 1;
            break;

        case 1:
            soWrite(valor[v1]);
            digitalWrite(DISP_2_PIN, HIGH);
            display = 2;
            break;

        case 2:
            soWrite(valor[v2]);
            digitalWrite(DISP_3_PIN, HIGH);
            display = 3;
            break;

        case 3:
            soWrite(valor[v3]);
            digitalWrite(DISP_4_PIN, HIGH);
            display = 0;
            break;

        default:
            //desliga todos os leds
            soWrite(0x00);
            display = 0;
            break;
    }
}

void ssdInit(void) {
    //configuração dos pinos de controle
    pinMode(DISP_1_PIN, OUTPUT);
    pinMode(DISP_2_PIN, OUTPUT);
    pinMode(DISP_3_PIN, OUTPUT);
    pinMode(DISP_4_PIN, OUTPUT);

    //Porta de dados como saida
    soInit();

}