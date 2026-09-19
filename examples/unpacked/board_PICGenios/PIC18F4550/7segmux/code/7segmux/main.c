#include"config.h"
#include"display7s.h"

void setup() {
    pinMode(_RA2, OUTPUT);
    pinMode(_RA3, OUTPUT);
    pinMode(_RA4, OUTPUT);
    pinMode(_RA5, OUTPUT);

    digitalWrite(_RA2, LOW);
    digitalWrite(_RA3, LOW);
    digitalWrite(_RA4, LOW);
    digitalWrite(_RA5, LOW);
}

void loop() {

    PORTD = display7s(1);
    digitalWrite(_RA2, HIGH);
    delay(1);
    digitalWrite(_RA2, LOW);

    PORTD = display7s(2);
    digitalWrite(_RA3, HIGH);
    delay(1);
    digitalWrite(_RA3, LOW);

    PORTD = display7s(3);
    digitalWrite(_RA4, HIGH);
    delay(1);
    digitalWrite(_RA4, LOW);

    PORTD = display7s(4);
    digitalWrite(_RA5, HIGH);
    delay(1);
    digitalWrite(_RA5, LOW);
} 