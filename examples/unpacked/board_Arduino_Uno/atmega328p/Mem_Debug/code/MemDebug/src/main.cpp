/*
  Simple example to blinking an LED using Platformio IDE.
   To upload to PICSimLab:
     1- Check if PICSimLab is running;
     2- Use Ctrl+Alt+U in VS code.
   To debug the code:
     1- Toggle the PICSimLab Debug button;
     2- Use Ctrl+Shift+D followed by F5 in VS code.
*/

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

