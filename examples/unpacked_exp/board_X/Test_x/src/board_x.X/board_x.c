#include <xc.h>;

#include "config_4550.h"
#include "adc.h"
#include "serial.h"
#include "itoa.h"

void main()
{
  unsigned int  val;
  char buffer[10];
  
  ADCON1=0x02;
  TRISA=0xFF;
  TRISB=0xFC;
  TRISC=0xBF;
  TRISD=0xFF;
  TRISE=0x0F;
  
  adc_init(); 
  serial_init();

 
  while(1)
  {
      val=adc_amostra(0);
      
      if(PORTDbits.RD1)
      {
        if(val > 340)
           PORTBbits.RB0=1;
        else
          PORTBbits.RB0=0;
      
        if(val > 680)
          PORTBbits.RB1=1;
        else
          PORTBbits.RB1=0;
      }
      else
      {
          if(PORTDbits.RD0)
          {
              PORTBbits.RB0=1;
              PORTBbits.RB1=0;
          }
          else
          {
              PORTBbits.RB0=0;
              PORTBbits.RB1=1;
          }
      
      }
      
      serial_tx_str(itoa(val,buffer));
      serial_tx_str("\r\n");
  }

}
