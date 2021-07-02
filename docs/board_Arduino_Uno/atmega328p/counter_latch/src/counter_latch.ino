/*
Simple example of how to use the latched 7-segment display with decoder 
*/

//pins
#define A 2
#define B 3
#define C 4
#define D 5
#define D1 6
#define D2 7
#define D3 8
#define D4 9

void setup() {
  pinMode(A, OUTPUT);
  pinMode(B, OUTPUT);
  pinMode(C, OUTPUT);
  pinMode(D, OUTPUT);
  pinMode(D1, OUTPUT);
  pinMode(D2, OUTPUT);
  pinMode(D3, OUTPUT);
  pinMode(D4, OUTPUT);
  digitalWrite(D1, HIGH);
  digitalWrite(D2, HIGH);
  digitalWrite(D3, HIGH);
  digitalWrite(D4, HIGH);
}

int value;
unsigned char digit;

void loop() {
  value = analogRead(A0);

  //one thousands
  digit = (value / 1000) % 10;
  digitalWrite(A, digit & 0x01);
  digitalWrite(B, digit & 0x02);
  digitalWrite(C, digit & 0x04);
  digitalWrite(D, digit & 0x08);

  digitalWrite(D1, LOW);
  digitalWrite(D1, HIGH);

  //hundreds
  digit = (value / 100) % 10;
  digitalWrite(A, digit & 0x01);
  digitalWrite(B, digit & 0x02);
  digitalWrite(C, digit & 0x04);
  digitalWrite(D, digit & 0x08);

  digitalWrite(D2, LOW);
  digitalWrite(D2, HIGH);

  //tens
  digit = (value / 10) % 10;
  digitalWrite(A, digit & 0x01);
  digitalWrite(B, digit & 0x02);
  digitalWrite(C, digit & 0x04);
  digitalWrite(D, digit & 0x08);


  digitalWrite(D3, LOW);
  digitalWrite(D3, HIGH);

  //ones
  digit = value % 10;
  digitalWrite(A, digit & 0x01);
  digitalWrite(B, digit & 0x02);
  digitalWrite(C, digit & 0x04);
  digitalWrite(D, digit & 0x08);

  digitalWrite(D4, LOW);
  digitalWrite(D4, HIGH);

  delay(10);
}
