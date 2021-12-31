#!/bin/bash 
. ucsname.sh

echo "<!DOCTYPE html>" >> ../help/UCs.html 
echo "<html><head>" >> ../help/UCs.html 
echo "<meta charset="utf-8" />" >> ../help/UCs.html 
echo "<title>PICSimLab Examples List</title>" >> ../help/UCs.html 
echo "<meta charset='utf-8' />" >> ../help/UCs.html 
echo "<meta content='width=device-width,initial-scale=1' name='viewport' />" >> ../help/UCs.html 
echo "<link href='picsimlab.css' rel='stylesheet' type='text/css' />" >> ../help/UCs.html 
echo "<link href='style.css' rel='stylesheet' type='text/css' />" >> ../help/UCs.html  
echo "</head>" >> ../help/UCs.html 
echo "<body>" >> ../help/UCs.html 
echo "<script src='picsimlab.js' type='text/javascript'></script><nav class='TOC'>" >> ../help/UCs.html
echo "<script data-goatcounter='https://4017.goatcounter.com/count' src='https://gc.zgo.at/count.js'></script>" >> ../help/UCs.html
echo "<span class='chapterToc'><a href=\"examples_index.html\">Examples Index</a></span>" >>  ../help/UCs.html

echo "<span class='chapterToc'>Examples by &#181controllers</h1></span>" >> ../help/UCs.html

for uc in "${ucs[@]}";do
  echo  "<span class='sectionToc'><a href=\"#${uc// /_}\">${uc}</a></span>" >> ../help/UCs.html
done

echo "</nav><main class='main-content'>" >> ../help/UCs.html

for uc in "${ucs[@]}";do
  echo  "<hr><br><h2><a name=\"${uc// /_}\"></a><a href=\"ucs_${uc// /_}.html\">${uc}</a></h2>" >> ../help/UCs.html
  files=`grep -m1 "$uc" */*/*/*.ini | cut -f1 -d:`
  for file in $files; do
    board=`echo $file | awk -F/ '{print $1}'`
    proc=`echo $file | awk -F/ '{print $2}'`
    name=`echo $file | awk -F/ '{print $3}'`
    if ! test -z "$name" 
    then
     bname=$(echo $board| cut -d'_' -f 2-)
     echo  "<a href=\"${board}.html#${board}_${proc}_${name}\">$bname | $proc | $name </a><br>" >> ../help/UCs.html
    fi
  done
done 

echo "</main><div class='footer'>Copyright © 2021 lcgamboa. Built with make4ht.</div></body></html>" >> ../help/UCs.html
