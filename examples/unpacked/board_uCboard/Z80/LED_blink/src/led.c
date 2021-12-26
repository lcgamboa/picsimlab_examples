

//Example of use of uCboard 8255
//compile with:  sdcc -mz80 led.c -o led.hex

__sfr __at 0x00 GPIO0;
__sfr __at 0x01 GPIO1;
__sfr __at 0x02 GPIO2;
__sfr __at 0x03 CTRL1;

__sfr __at 0x04 GPIO3;
__sfr __at 0x05 GPIO4;//not have pinout
__sfr __at 0x06 GPIO5;//not have pinout
__sfr __at 0x07 CTRL2;

void delay(int j)
{
  int i;
  for(i=0; i<j; i++)
    continue;
}

main()
{
  int n=0;
  CTRL1=0x80;//all output
  CTRL2=0x80;//all output	
  while(1) 
  {
   GPIO0=n++;
   GPIO1=n++;
   GPIO2=n++;
   GPIO3=n++;
   GPIO4=n++;
   GPIO5=n++;
   delay(5000);
  }
}
