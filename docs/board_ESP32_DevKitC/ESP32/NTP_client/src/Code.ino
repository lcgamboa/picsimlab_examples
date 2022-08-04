/*
   PCD8544 Library Modified for Esp32 Nokia 5110 LCD Interfacing.
   Sample code for Displaying time and Date from NTP servers.

  https://github.com/Anirudhvl/Esp32-Nokia-5110-Interfacing-and-NTP-Sync-IST-Digital-Clock
*/

#include <WiFi.h>
#include "PCD8544.h"
#include "driver/gpio.h"
#include <TimeLib.h>
#include <WiFiUdp.h>
const char* ssid     = "PICSimLabWifi";
const char* password = "";
static PCD8544 lcd = PCD8544(14, 13, 27, 26, 15); //sclk, sdin, dc, reset, sce
static const char ntpServerName[] = "time.nist.gov";
const int timeZone = 0;// 0 is UTC, use -3 for Brasil
WiFiUDP Udp;
unsigned int localPort = 8888;
time_t getNtpTime();

void setup() {
  gpio_set_direction( GPIO_NUM_23, GPIO_MODE_OUTPUT);
  gpio_set_level( GPIO_NUM_23, 1);
  lcd.begin(84, 48);
  lcd.clear();
  lcd.setCursor(1, 0);
  lcd.print("WiFi Begin... ");

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    lcd.clear();
    lcd.setCursor(1, 0);
    lcd.print("Connecting... ");
    delay(200);
  }
  lcd.clear();
  lcd.setCursor(1, 0);
  lcd.print("Connected to WiFi ");
  delay(200);
  Udp.begin(localPort);
  setSyncProvider(getNtpTime);
  setSyncInterval(300);
  lcd.clear();
  lcd.setCursor(1, 0);
  lcd.print("Waiting for Time Sync.. ");
  delay(500);
  Udp.begin(localPort);
}
time_t prevDisplay = 0;
void loop() {
  if (timeStatus() != timeNotSet)  {
    if (now() != prevDisplay) { //update the display only if time has changed
      prevDisplay = now();
      digitalClockDisplay();
    }
  }
}
void digitalClockDisplay()
{
  lcd.clear();
  lcd.setCursor(18, 0);
  lcd.print("ESP32 NTP");
  
  // digital clock display of the time
  lcd.setCursor(20, 2);
  lcd.print(hour());
  printDigits(minute());
  printDigits(second());
  lcd.setCursor(20, 4);
  lcd.print(day());
  lcd.print("/");
  lcd.print(month());
  lcd.print("/");
  lcd.print(year());
}

void printDigits(int digits)
{
  // utility for digital clock display: prints preceding colon and leading 0
  lcd.print(":");
  if (digits < 10)
    lcd.print('0');
  lcd.print(digits);
}

/*-------- NTP code ----------*/

const int NTP_PACKET_SIZE = 48; // NTP time is in the first 48 bytes of message
byte packetBuffer[NTP_PACKET_SIZE]; //buffer to hold incoming & outgoing packets

time_t getNtpTime()
{
  IPAddress ntpServerIP; // NTP server's ip address

  while (Udp.parsePacket() > 0) ; // discard any previously received packets
  // get a random server from the pool
  WiFi.hostByName(ntpServerName, ntpServerIP);
  Serial.print(ntpServerName);
  Serial.print(": ");
  Serial.println(ntpServerIP);
  sendNTPpacket(ntpServerIP);
  uint32_t beginWait = millis();
  while (millis() - beginWait < 1500) {
    int size = Udp.parsePacket();
    if (size >= NTP_PACKET_SIZE) {
      Serial.println("Receive NTP Response");
      Udp.read(packetBuffer, NTP_PACKET_SIZE);  // read packet into the buffer
      unsigned long secsSince1900;
      // convert four bytes starting at location 40 to a long integer
      secsSince1900 =  (unsigned long)packetBuffer[40] << 24;
      secsSince1900 |= (unsigned long)packetBuffer[41] << 16;
      secsSince1900 |= (unsigned long)packetBuffer[42] << 8;
      secsSince1900 |= (unsigned long)packetBuffer[43];
      return secsSince1900 - 2208988800UL + timeZone * SECS_PER_HOUR;
    }
  }
  return 0; // return 0 if unable to get the time
}

// send an NTP request to the time server at the given address
void sendNTPpacket(IPAddress &address)
{
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, NTP_PACKET_SIZE);
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12] = 49;
  packetBuffer[13] = 0x4E;
  packetBuffer[14] = 49;
  packetBuffer[15] = 52;
  // all NTP fields have been given values, now
  // you can send a packet requesting a timestamp:
  Udp.beginPacket(address, 123); //NTP requests are to port 123
  Udp.write(packetBuffer, NTP_PACKET_SIZE);
  Udp.endPacket();
}
