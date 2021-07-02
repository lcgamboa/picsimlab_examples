#include "io.h"

void rgbColor(int led) {
	if (led & 1) {
		digitalWrite(LED_RED_PIN, HIGH);
	} else {
		digitalWrite(LED_RED_PIN, LOW);
	}
	if (led & 2) {
		digitalWrite(LED_GREEN_PIN, HIGH);
	} else {
		digitalWrite(LED_GREEN_PIN, LOW);
	}
	if (led & 4) {
		digitalWrite(LED_BLUE_PIN, HIGH);
	} else {
		digitalWrite(LED_BLUE_PIN, LOW);
	}
}

void turnOn(int led) {
	if (led & 1) {
		digitalWrite(LED_RED_PIN, HIGH);
	}
	if (led & 2) {
		digitalWrite(LED_GREEN_PIN, HIGH);
	}
	if (led & 4) {
		digitalWrite(LED_BLUE_PIN, HIGH);
	}
}

void turnOff(int led) {
	if (led & 1) {
		digitalWrite(LED_RED_PIN, LOW);
	}
	if (led & 2) {
		digitalWrite(LED_GREEN_PIN, LOW);
	}
	if (led & 4) {
		digitalWrite(LED_BLUE_PIN, LOW);
	}
}

void rgbInit(void) {
	pinMode(LED_RED_PIN, OUTPUT);
	pinMode(LED_GREEN_PIN, OUTPUT);
	pinMode(LED_BLUE_PIN, OUTPUT);
}
