#!/bin/bash 
declare -a parts=("7 Segments Display" "Buzzer" "D. Transfer function" "ETH w5500" "Gamepad" "Gamepad (Analogic)" \
	"IO 74xx595" "IO MCP23S17" \
        "IO PCF8574" "IO UART" "IO Virtual term" "Jumper Wires" "Keypad" "LCD hd44780" "LCD ili9341 " "LCD pcf8833" \
      	"LCD pcd8544"  \
	"LCD ssd1306" "LED Matrix"  "LEDs"  "MEM 24CXXX" "Potentiometers" \
        "Push buttons"  "Push buttons (Analogic)"  "RGB LED"  "RTC ds1307"  "RTC pfc8563" "SD Card" "Servo motor"\
	"Signal Generator" "Step motor" "Switchs" "Temperature System" "VCD Dump" "VCD Dump (Analogic)" "VCD Play")

echo "<hr><br><hr><h1><a name=\"parts\"></a>Examples by parts</h1>"

for part in "${parts[@]}";do
  echo  "<br><a href=\"#${part// /_}\">${part} </a>"
done

for part in "${parts[@]}";do
  echo  "<hr><br><h2><a name=\"${part// /_}\"></a>${part}</h2>"
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
