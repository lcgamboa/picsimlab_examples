
#include <Arduino.h>

#define LED_PIN 13

#define dvar (*(volatile uint8_t *)200)

void setup()
{
  
}

void loop()
{
  dvar = dvar << 1;
  if(dvar == 0) dvar=1;
  delay(500);
}

