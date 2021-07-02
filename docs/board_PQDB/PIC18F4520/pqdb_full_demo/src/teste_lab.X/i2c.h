
#ifndef I2C_H
#define I2C_H

	void i2cInit(void);
	unsigned char i2cWriteByte(unsigned char send_start, unsigned char send_stop, unsigned char byte);
	unsigned char i2cReadByte(unsigned char nack, unsigned char send_stop);

#endif

