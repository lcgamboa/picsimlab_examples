#!/bin/bash 
. partsname.sh



echo "<!DOCTYPE html>" >> ../help/Parts.html 
echo "<html><head>" >> ../help/Parts.html 
echo "<meta charset="utf-8" />" >> ../help/Parts.html 
echo "<title>PICSimLab Examples List</title>" >> ../help/Parts.html 
echo "<meta charset='utf-8' />" >> ../help/Parts.html 
echo "<meta content='width=device-width,initial-scale=1' name='viewport' />" >> ../help/Parts.html 
echo "<link href='picsimlab.css' rel='stylesheet' type='text/css' />" >> ../help/Parts.html 
echo "<link href='style.css' rel='stylesheet' type='text/css' />" >> ../help/Parts.html  
echo "</head>" >> ../help/Parts.html 
echo "<body>" >> ../help/Parts.html 
echo "<script src='picsimlab.js' type='text/javascript'></script><nav class='TOC'>" >> ../help/Parts.html
echo "<script data-goatcounter='https://4017.goatcounter.com/count' src='https://gc.zgo.at/count.js'></script>" >> ../help/Parts.html
echo "<span class='chapterToc'><a href=\"examples_index.html\">Examples Index</a></span>" >>  ../help/Parts.html

echo "<span class='chapterToc'>Examples by parts</h1></span>" >> ../help/Parts.html

for part in "${parts[@]}";do
  echo  "<span class='sectionToc'><a href=\"#${part// /_}\">${part}</a></span>" >> ../help/Parts.html
done

echo "</nav><main class='main-content'>" >> ../help/Parts.html

for part in "${parts[@]}";do
  echo  "<hr><br><h2><a name=\"${part// /_}\"></a><a href=\"parts_${part// /_}.html\">${part}</a></h2>" >> ../help/Parts.html
  files=`grep -m1 "$part" */*/*/*.pcf | cut -f1 -d:`
  for file in $files; do
    board=`echo $file | awk -F/ '{print $1}'` 
    proc=`echo $file | awk -F/ '{print $2}'`
    name=`echo $file | awk -F/ '{print $3}'`
    if ! test -z "$name" 
    then
     bname=$(echo $board| cut -d'_' -f 2-)
     echo  "<a href=\"${board}.html#${board}_${proc}_${name}\">$bname | $proc | $name </a><br>" >> ../help/Parts.html
    fi
  done
done 

echo "</main><div class='footer'>Copyright © 2021 lcgamboa. Built with make4ht.</div></body></html>" >> ../help/Parts.html
