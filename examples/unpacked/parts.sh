#!/bin/bash 
. partsname.sh

#echo "<hr><h1><a name=\"parts\"></a>Examples by parts</h1>"
echo "<span class='chapterToc'>Examples by parts</h1></span>"

for part in "${parts[@]}";do
  echo  "<span class='sectionToc'><a href=\"#${part// /_}\">${part}</a></span>"
done

echo "</nav><main class='main-content'>"

for part in "${parts[@]}";do
  echo  "<hr><br><h2><a name=\"${part// /_}\"></a>${part}</h2>"
  files=`grep -m1 "$part" */*/*/*.pcf | cut -f1 -d:`
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
