#!/bin/bash 
declare -a parts=("7 Segments Display" "7 Segments Display (Decoder)" "Buzzer" "D. Transfer Function" "DC Motor" \
	"ETH w5500" "Encoder" "FM50 (Temperature)" "Fixed Voltage" "Gamepad" \
	"Gamepad (Analogic)" "IO 74xx595" "IO MCP23S17" \
	"IO PCF8574" "IO UART" "IO Virtual Term" "Jumper Wires" "Keypad" "LM35 (Temperature)" "LCD hd44780"  \
	"LCD ili9341" "LCD pcf8833" "LCD pcd8544"  \
	"LCD ssd1306" "LED Matrix" "LEDs"  "MEM 24CXXX" "MPU6050" "Potentiometers" "Potentiometers (Rotary)" \
        "Push Buttons"  "Push Buttons (Analogic)"  "RGB LED"  "RTC ds1307"  "RTC pfc8563" "SD Card" "Servo Motor"\
	"Signal Generator" "Step Motor" "SHT3X (Temp. Hum.)" "Switchs" "Temperature System" "Ultrasonic HC-SR04" \
	"VCD Dump" "VCD Dump (Analogic)" "VCD Play" )

echo "<hr><br><hr><h1><a name=\"parts\"></a>Examples by parts</h1>"

for part in "${parts[@]}";do
  echo  "<br><a href=\"#${part// /_}\">$part</a>"
done

for part in "${parts[@]}";do
  echo  "<hr><br><h2><a name=\"${part// /_}\"></a>$part</h2>"
  files=`grep -m1 "$part" */*/*/*.pcf | cut -f1 -d:`
  for file in $files; do
    board=`echo $file | awk -F/ '{print $1}'`
    proc=`echo $file | awk -F/ '{print $2}'`
    name=`echo $file | awk -F/ '{print $3}'`
    if ! test -z "$name" 
    then
     echo  "<a href=\"#${board}_${proc}_${name}\">$board | $proc | $name </a><br>";
    fi
  done
done 
