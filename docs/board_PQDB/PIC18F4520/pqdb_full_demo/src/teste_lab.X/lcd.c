#include "so.h"
#include "io.h"
#include "lcd.h"

void delayMicro(int a) {
	volatile int i;
    //comment on simulator
	//for (i = 0; i < (a * 2); i++);
}
void delayMili(int a) {
	volatile int i;
	for (i = 0; i < a; i++) {
        //comment on simulator
		//delayMicro(1000);
	}
}
//Gera um clock no enable
void pulseEnablePin() {
	digitalWrite(LCD_EN_PIN, HIGH);
	delayMicro(5);
	digitalWrite(LCD_EN_PIN, LOW);
	delayMicro(5);
}
//Envia 4 bits e gera um clock no enable
void pushNibble(char value, int rs) {
	soWrite(value);
	digitalWrite(LCD_RS_PIN, rs);
	pulseEnablePin();
}
//Envia 8 bits em dois pacotes de 4
void pushByte(char value, int rs) {
	soWrite(value >> 4);
	digitalWrite(LCD_RS_PIN, rs);
	pulseEnablePin();

	soWrite(value & 0x0F);
	digitalWrite(LCD_RS_PIN, rs);
	pulseEnablePin();
}
void lcdCommand(char value) {
	pushByte(value, LOW);
	delayMili(2);
}
void lcdPosition(int line, int col) {
	if (line == 0) {
		lcdCommand(0x80 + (col % 16));
	}
	if (line == 1) {
		lcdCommand(0xC0 + (col % 16));
	}
}
void lcdChar(char value) {
	pushByte(value, HIGH);
	delayMicro(80);
}
//Imprime um texto (vetor de char)
void lcdString(char msg[]) {
	int i = 0;
	while (msg[i] != 0) {
		lcdChar(msg[i]);
		i++;
	}
}
void lcdNumber(int value) {
	int i = 10000; //Máximo 99.999
	while (i > 0) {
		lcdChar((value / i) % 10 + 48);
		i /= 10;
	}
}
// Rotina de incialização
void lcdInit() {
	pinMode(LCD_EN_PIN, OUTPUT);
	pinMode(LCD_RS_PIN, OUTPUT);
	soInit();
	delayMili(15);
	// Comunicação começa em estado incerto
	pushNibble(0x03, LOW);
	delayMili(5);
	pushNibble(0x03, LOW);
	delayMicro(160);
	pushNibble(0x03, LOW);
	delayMicro(160);
	// Mudando comunicação para 4 bits
	pushNibble(0x02, LOW);
	delayMili(10);
	// Configura o display
	lcdCommand(0x28);         //8bits, 2 linhas, fonte: 5x8
	lcdCommand(0x08 + 0x04);  //display on
	lcdCommand(0x01);         //limpar display, voltar p/ posição 0
}
