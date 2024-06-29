void setup() {
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);

  analogWrite(5, 128);
}

void loop() {
  digitalWrite(4, HIGH);
  delay(500);
  digitalWrite(4, LOW);
  delay(500);
}
