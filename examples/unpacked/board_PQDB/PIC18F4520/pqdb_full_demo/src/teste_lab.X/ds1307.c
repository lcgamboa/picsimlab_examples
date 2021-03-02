#include "i2c.h"
#include "ds1307.h"

//endereço do dispositivo, deslocado por causa do bit de RW
#define DS1307_CTRL_ID (0x68<<1)
#define I2C_WRITE 0
#define I2C_READ  1

int dec2bcd(int value) {
	return ((value / 10 * 16) + (value % 10));
}
int bcd2dec(int value) {
	return ((value / 16 * 10) + (value % 16));
}
void dsInit(void) {
	i2cInit();
}
void dsStartClock(void) {
	int seconds;
	seconds = dsReadData(SEC);
	dsWriteData(0x7f & seconds,SEC);
	return;
}
void dsWriteData(unsigned char value, int address) {
	i2cWriteByte(1,0, DS1307_CTRL_ID|I2C_WRITE);
	i2cWriteByte(0,0,address);
	i2cWriteByte(0,1,value);
}
int dsReadData(int address) {
	int result;
	i2cWriteByte(1,0,DS1307_CTRL_ID | I2C_WRITE);
	i2cWriteByte(0,0,address);
	i2cWriteByte(1,0, DS1307_CTRL_ID | I2C_READ);
	result = i2cReadByte(1,1 );
	return result;
}
