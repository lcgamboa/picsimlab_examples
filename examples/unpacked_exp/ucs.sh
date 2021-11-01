#!/bin/bash 

#. ../unpacked/ucsname.sh

declare -a ucs=("C51" "PIC16F1619" "PIC16F18855" "PIC18F27K40" "PIC18F4550" "stm32f103c8t6" "stm32f103rbt6" "STM8S103" "Z80")

#echo "<hr><h1><a name=\"parts\"></a>Examples by parts</h1>"
echo "<span class='chapterToc'>Examples by &#181controllers</h1></span>"

for uc in "${ucs[@]}";do
  echo  "<span class='sectionToc'><a href=\"#${uc// /_}\">${uc}</a></span>"
done

echo "</nav><main class='main-content'>"

for uc in "${ucs[@]}";do
  echo  "<hr><br><h2><a name=\"${uc// /_}\"></a>${uc}</h2>"
  files=`grep -m1 "$uc" */*/*/*.ini | cut -f1 -d:`
  for file in $files; do
    board=`echo $file | awk -F/ '{print $1}'`
    proc=`echo $file | awk -F/ '{print $2}'`
    name=`echo $file | awk -F/ '{print $3}'`
    if ! test -z "$name" 
    then
     bname=$(echo $board| cut -d'_' -f 2-)
     echo  "<a href=\"${board}.html#${board}_${proc}_${name}\">$bname | $proc | $name </a><br>";
    fi
  done
done 
