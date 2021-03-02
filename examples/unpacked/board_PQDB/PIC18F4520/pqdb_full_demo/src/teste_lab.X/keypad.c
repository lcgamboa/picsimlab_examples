#include "keypad.h"
#include "so.h"
#include "io.h"
#include "bits.h"

static unsigned int keys;

//vetor com o "nome" dos botões
//U -> up, L -> left, D -> down, R -> right
//S -> start, s -> select
//a ordem é referente a posição dos botões
static const char charKey[] = {'U','L','D','R','S','X','A','B','Y','s'};

unsigned int kpRead(void) {
    return keys;
}
char kpReadKey(void){
	int i;
	for(i=0;i<10;i++){
		if (bitTst(keys,i)){
			return charKey[i];
		}
	}
	//nenhuma tecla pressionada
	return 0;
}
void kpDebounce(void) {
    int i;
    static unsigned char tempo;
    static unsigned int newRead;
    static unsigned int oldRead;
    newRead = 0;
    for(i = 0; i<5; i++){
      //liga apenas coluna desejada D3 - > D7
      soWrite(1<<(i+3));
      if(digitalRead(KEYPAD_1_PIN)){
        bitSet(newRead,i);
      }
      if(digitalRead(KEYPAD_2_PIN)){
        bitSet(newRead,(i+5));
      }
    }
    if (oldRead == newRead) {
        tempo--;
    } else {
        tempo = 1;
        oldRead = newRead;
    }
    if (tempo == 0) {
        keys = oldRead;
    }
}
#include <pic18f4520.h>
void kpInit(void) {
  soInit();
  pinMode(KEYPAD_1_PIN, INPUT);
  pinMode(KEYPAD_2_PIN, INPUT);
  ADCON1 = 0b00001100; //apenas AN0 é analogico, a referencia é baseada na fonte
}
