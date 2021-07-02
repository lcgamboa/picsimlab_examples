
// This is a guard condition so that contents of this file are not included
// more than once.  
#ifndef IO_H
#define	IO_H

#define OUTPUT 0
#define INPUT  1
#define LOW 0
#define HIGH 1

enum pin_label{
    PIN_A0,PIN_A1,PIN_A2,PIN_A3,PIN_A4,PIN_A5,PIN_A6,PIN_A7,            
    PIN_B0,PIN_B1,PIN_B2,PIN_B3,PIN_B4,PIN_B5,PIN_B6,PIN_B7,
    PIN_C0,PIN_C1,PIN_C2,PIN_C3,PIN_C4,PIN_C5,PIN_C6,PIN_C7,
    PIN_D0,PIN_D1,PIN_D2,PIN_D3,PIN_D4,PIN_D5,PIN_D6,PIN_D7,
    PIN_E0,PIN_E1,PIN_E2,PIN_E3,PIN_E4,PIN_E5,PIN_E6,PIN_E7
};


/*15*/#define SDA_PIN       PIN_B4
/*14*/#define SCL_PIN       PIN_B3
/*13*/#define KEYPAD_1_PIN  PIN_B2
/*12*/#define KEYPAD_2_PIN  PIN_B1
/*11*/#define SO_CLK_PIN    PIN_B0
/*10*/#define SO_EN_PIN     PIN_D7
/*9*/#define PWM_PIN       PIN_C1
/*8*/#define SO_DATA_PIN   PIN_D6

/*7*/#define LCD_RS_PIN    PIN_D5
/*6*/#define LCD_EN_PIN    PIN_D4
/*5*/#define DISP_4_PIN    PIN_D3
/*4*/#define DISP_3_PIN    PIN_D2
/*3*/#define DISP_2_PIN    PIN_D1
/*2*/#define DISP_1_PIN    PIN_D0 



#define LED_BLUE_PIN  DISP_3_PIN
#define LED_GREEN_PIN DISP_2_PIN
#define LED_RED_PIN   DISP_1_PIN

void digitalWrite(int pin, int value);
int digitalRead(int pin);
void pinMode(int pin, int type);
//void systemInit(void);
#endif	/* XC_HEADER_TEMPLATE_H */

