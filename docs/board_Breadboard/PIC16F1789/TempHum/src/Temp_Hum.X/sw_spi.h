

#include <xc.h> 

 #define spi_clk   RC3   // pino de clock
 #define spi_dta   RC5   // pino de dados
 //#define spi_cs    RC2   // pino de seleção
 #define spi_reset RC1   // pino de reset

 #define CLK0 spi_clk=0;
 #define CLK1 spi_clk=1;
 #define SDA0 spi_dta=0;
 #define SDA1 spi_dta=1;

void spiBegin(Spi_Mode sMode, Spi_Data_Sample sDataSample, Spi_Clock_Edge sClockEdge, Spi_Clock_Pol sClockPol)
{
  TRISC5 = 0; //MOSI
  TRISC3 = 0; //CLK
}

void spiWrite(char b){

  CLK0
  if ((b&128)!=0) SDA1 else SDA0
  CLK1

  CLK0
  if ((b&64)!=0) SDA1 else SDA0
  CLK1

  CLK0
  if ((b&32)!=0) SDA1 else SDA0
  CLK1

  CLK0
  if ((b&16)!=0) SDA1 else SDA0
  CLK1

  CLK0
  if ((b&8)!=0) SDA1 else SDA0
  CLK1

  CLK0
  if ((b&4)!=0) SDA1 else SDA0
  CLK1

  CLK0
  if ((b&2)!=0) SDA1 else SDA0
  CLK1

  CLK0
  if ((b&1)!=0) SDA1 else SDA0
  CLK1

}


#endif	/* XC_HEADER_TEMPLATE_H */
