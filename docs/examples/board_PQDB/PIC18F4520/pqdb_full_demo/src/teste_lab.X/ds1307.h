#ifndef DS1307RTC_h
#define DS1307RTC_h

//definição dos endereços
#define SEC     0
#define MIN     1
#define HOUR    2
#define WEEKDAY 3
#define DAY     4
#define MONTH   5
#define YEAR    6

	//funções do DS1307
	void dsInit(void);
	void dsStartClock(void);
	void dsStopClock(void);
	int dec2bcd(int value);
	int bcd2dec(int value);
	void dsWriteData(unsigned char value, int address);
	int dsReadData(int address);

//funções de leitura/escrita simplificadas
#define getSeconds()  (bcd2dec(dsReadData(SEC)& 0x7f))
#define getMinutes()  (bcd2dec(dsReadData(MIN)& 0x7f))
#define getHours()    (bcd2dec(dsReadData(HOUR)& 0x5f))
#define getWeekDay()  (bcd2dec(dsReadData(WEEKDAY)& 0x07))
#define getDays()     (bcd2dec(dsReadData(DAY)& 0x5f))
#define getMonths()   (bcd2dec(dsReadData(MONTH)& 0x3f))
#define getYears()    (bcd2dec(dsReadData(YEAR)& 0xff))

#define setSeconds(v) (dsWriteData(dec2bcd(v),SEC))
#define setMinutes(v) (dsWriteData(dec2bcd(v),MIN))
#define setHours(v)   (dsWriteData(dec2bcd(v),HOUR))
#define setWeekDay(v) (dsWriteData(dec2bcd(v),WEEKDAY))
#define setDays(v)    (dsWriteData(dec2bcd(v),DAY))
#define setMonths(v)  (dsWriteData(dec2bcd(v),MONTH))
#define setYears(v)   (dsWriteData(dec2bcd(v),YEAR))

#endif
