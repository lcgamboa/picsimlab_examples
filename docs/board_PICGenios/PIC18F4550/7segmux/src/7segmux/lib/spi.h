
#include <xc.h> // include processor files - each processor file is guarded.  

typedef enum
{
  MASTER_OSC_DIV4  = 0x20,
  MASTER_OSC_DIV16 = 0x21,
  MASTER_OSC_DIV64 = 0x22,
  MASTER_TMR2_DIV2 = 0x23,
  SLAVE_SS_EN      = 0x24,
  SLAVE_SS_DIS     = 0x25
}Spi_Mode;

typedef enum
{
  SAMPLE_MIDDLE = 0x00,
  SAMPLE_END    = 0x80
}Spi_Data_Sample;

typedef enum
{
  IDLE_HIGH = 0x08,
  IDLE_LOW  = 0x00
}Spi_Clock_Pol;

typedef enum
{
  IDLE_TO_ACTIVE = 0x00,
  ACTIVE_TO_IDLE = 0x40
}Spi_Clock_Edge;

void spiBegin(Spi_Mode sMode, Spi_Data_Sample sDataSample, Spi_Clock_Edge sClockEdge, Spi_Clock_Pol sClockPol)
{
  TRISC5 = 0;
  if(sMode & 0b00000100) //If Slave Mode
  {
    SSPSTAT = sClockEdge;
    TRISC3 = 1;
  }
  else //If Master Mode
  {
    SSPSTAT = sDataSample | sClockEdge;
    TRISC3 = 0;
  }
  SSPCON = sMode | sClockPol;
}

void spiWrite(char dat){
    SSPBUF = dat;
}

char spiRead(){
    if(BF){
        return SSPBUF;
    }
}


