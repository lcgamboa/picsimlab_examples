#include "io.h"

void soInit(void) {
	pinMode(SO_EN_PIN, OUTPUT);
	pinMode(SO_CLK_PIN, OUTPUT);
	pinMode(SO_DATA_PIN, OUTPUT);
}
//pulso de clock para habilitar os dados na sáida
void PulseEnClock(void){
	digitalWrite(SO_EN_PIN, HIGH);
	digitalWrite(SO_EN_PIN, LOW);
}
//pulso de clock para enviar um bit
void PulseClockData(void){
	digitalWrite(SO_CLK_PIN, HIGH);
	digitalWrite(SO_CLK_PIN, LOW);
}
void soWrite(int value) {
	char i;
	digitalWrite(SO_CLK_PIN, LOW);
	for (i = 0; i < 8; i++) {
		digitalWrite(SO_DATA_PIN, value & 0x80);
		PulseClockData();
		value <<= 1;
	}
	PulseEnClock();
}
