//https://how2electronics.com/arduino-ultrasonic-range-finder-hc-sr04-oled-display/
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
 
#define trigPin 9
#define echoPin 8

#define OLED_RESET 4

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels 
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
 
void setup() {
Serial.begin (9600);
pinMode(trigPin, OUTPUT);
pinMode(echoPin, INPUT);
display.begin(SSD1306_SWITCHCAPVCC, 0x3C); //initialize with the I2C addr 0x3C (128x64)
display.clearDisplay();
}
 
void loop() {
float duration;
float distance_cm;
float distance_in;
 
digitalWrite(trigPin, LOW); 
delayMicroseconds(2);
digitalWrite(trigPin, HIGH);
delayMicroseconds(10);
digitalWrite(trigPin, LOW);
 
duration = pulseIn(echoPin, HIGH);
 
distance_cm = duration * 0.01723;
distance_in = distance_cm / 2.54;
 
display.setCursor(30,0); //oled display
display.setTextSize(1);
display.setTextColor(WHITE);
display.println("Range Finder");
 
display.setCursor(10,20); //oled display
display.setTextSize(2);
display.setTextColor(WHITE);
display.println(distance_cm);
display.setCursor(90,20);
display.setTextSize(2);
display.println("cm");
 
display.setCursor(10,45); //oled display
display.setTextSize(2);
display.setTextColor(WHITE);
display.println(distance_in);
display.setCursor(90,45);
display.setTextSize(2);
display.println("in");
display.display();
 
delay(500);
display.clearDisplay();
 
Serial.println(distance_cm);
Serial.println(distance_in);
}
