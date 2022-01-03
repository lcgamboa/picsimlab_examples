#include "ripes_system.h"

unsigned short *porta = (EXTERNAL_BUS_0_PORTA);
unsigned short *dira = (EXTERNAL_BUS_0_DIRA);
unsigned short *portb = (EXTERNAL_BUS_0_PORTB);
unsigned short *dirb = (EXTERNAL_BUS_0_DIRB);
unsigned short *t0cnt = (EXTERNAL_BUS_0_T0CNT);
unsigned short *t0sta = (EXTERNAL_BUS_0_T0STA);
unsigned short *t0con = (EXTERNAL_BUS_0_T0CON);
unsigned short *t0pr = (EXTERNAL_BUS_0_T0PR);
unsigned short *pfreq = (EXTERNAL_BUS_0_PFREQ);

#define PORTA (*porta)
#define DIRA (*dira)
#define PORTB (*portb)
#define DIRB (*dirb)
#define T0CNT (*t0cnt)
#define T0STA (*t0sta)
#define T0CON (*t0con)
#define T0PR (*t0pr)
#define PFREQ (*pfreq)

#define LENA 0x0100
#define LDAT 0x0200

#define LPORT PORTA
#define TPORT DIRA

#define L_ON 0x0F
#define L_OFF 0x08
#define L_CLR 0x01
#define L_L1 0x80
#define L_L2 0xC0
#define L_CR 0x0F
#define L_NCR 0x0C

#define L_L3 0x90
#define L_L4 0xD0

#define L_CFG 0x38

void lcd_init(void);
void lcd_cmd(unsigned char val);
void lcd_dat(unsigned char val);
void lcd_str(const char *str);

void delay(unsigned short d);

unsigned short v = 0;
unsigned short d;
void main() {

  DIRA = 0xFF00;
  DIRB = 0xFFFF;

  lcd_init();
  lcd_str("Ripes PICSimLab");
  lcd_cmd(L_NCR);
  while (1) {
    lcd_cmd(L_L2);
    v = PORTB;
    if (v & 0x80)
      lcd_dat('1');
    else
      lcd_dat('0');
    if (v & 0x40)
      lcd_dat('1');
    else
      lcd_dat('0');
    if (v & 0x20)
      lcd_dat('1');
    else
      lcd_dat('0');
    if (v & 0x10)
      lcd_dat('1');
    else
      lcd_dat('0');
    if (v & 0x08)
      lcd_dat('1');
    else
      lcd_dat('0');
    if (v & 0x04)
      lcd_dat('1');
    else
      lcd_dat('0');
    if (v & 0x02)
      lcd_dat('1');
    else
      lcd_dat('0');
    if (v & 0x01)
      lcd_dat('1');
    else
      lcd_dat('0');
    delay(500);

    lcd_cmd(L_L2 + 10);
    if (d) {
      d = 0;
      lcd_str("On ");
    } else {
      d = 1;
      lcd_str("Off");
    }
  }
}

void delay_us(unsigned int d) {
  T0CON = 0;
  T0CNT = 0;
  T0PR = d;
  T0STA = 0;
  T0CON = 0x8000 | PFREQ;
  while (!T0STA)
    ;
}

void delay(unsigned short d) {
  T0CON = 0;
  T0CNT = 0;
  T0PR = d;
  T0STA = 0;
  T0CON = 0x8000 | (PFREQ * 1000);
  while (!T0STA)
    ;
}

void set(unsigned short v) { LPORT |= v; }

void clr(unsigned short v) { LPORT &= ~v; }

void lcd_wr(unsigned char val) { LPORT = (LPORT & 0xFF00) | val; }

void lcd_cmd(unsigned char val) {
  set(LENA);
  lcd_wr(val);
  clr(LDAT);
  delay_us(100);
  clr(LENA);
  delay(2);
  set(LENA);
}

void lcd_dat(unsigned char val) {
  set(LENA);
  lcd_wr(val);
  set(LDAT);
  delay_us(100);
  clr(LENA);
  delay_us(100);
  set(LENA);
}

void lcd_init(void) {
  TPORT = 0x00;

  clr(LENA);
  clr(LDAT);
  delay(20);
  set(LENA);

  lcd_cmd(L_CFG);
  delay(5);
  lcd_cmd(L_CFG);
  delay(1);
  lcd_cmd(L_CFG); // configura
  lcd_cmd(L_OFF);
  lcd_cmd(L_ON);  // liga
  lcd_cmd(L_CLR); // limpa
  lcd_cmd(L_CFG); // configura
  lcd_cmd(L_L1);
}

void lcd_str(const char *str) {
  unsigned char i = 0;

  while (str[i] != 0) {
    lcd_dat(str[i]);
    i++;
  }
}