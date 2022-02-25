#!/bin/bash 

readarray -d '' boardlist < <(find * -maxdepth 0 -type d -print0 2> /dev/null)

for board in "${boardlist[@]}"
do
  file=../../help/$board.html 
  bname=$(echo $board| cut -d'_' -f 2-) 
  cd $board	
  echo "board: $board"	
  mkdir -p "../../help/$board/"
  echo "<!DOCTYPE html>" >> $file 
  echo "<html><head>" >> $file   
  echo "<title>PICSimLab Examples Board $bname</title>" >> $file 
  echo "<meta charset='utf-8' />" >> $file  
  echo "<meta content='width=device-width,initial-scale=1' name='viewport' />" >> $file
  echo "<link href='picsimlab.css' rel='stylesheet' type='text/css' />" >> $file 
  echo "<link href='style.css' rel='stylesheet' type='text/css' />" >> $file  
  echo "</head>" >> $file 
  echo "<body>" >> $file 
  echo "<nav class='TOC'>" >> $file
  echo "<span class='chapterToc'><a href=\"examples_index.html\">Examples Index</a></span>" >> $file 


for chboard in "${boardlist[@]}"
do
  chbname=$(echo $chboard| cut -d'_' -f 2-) 
  echo "<span class='chapterToc'><a href=\"${chboard}.html\">$chbname</a></span>" >> $file   

  if [ "$chboard" == "$board" ]; then 
  for proc in `find * -maxdepth 0 -type d,l 2> /dev/null`
  do
    cd $proc	
    echo "<span class='sectionToc'><a href=\"#${board}_${proc}\">$proc</a></span>" >> ../$file
    for name in `find * -maxdepth 0 -type d 2> /dev/null`
    do
      echo "<span class='subsectionToc'><a href=\"#${board}_${proc}_${name}\">$name</a></span>" >> ../$file
    done
    #echo "<br>" >> ../$file    
    cd ..
  done	
  fi
done

  echo "</nav><main class='main-content'>" >> $file  
  for proc in `find * -maxdepth 0 -type d,l 2> /dev/null`
  do
    cd $proc	
    echo "board: $board  proc: $proc"	
    echo -n "<a name=\"$board" >> ../$file 
    echo -n "_" >> ../$file 
    echo "$proc\"></a>" >>  ../$file 
    for name in `find * -maxdepth 0 -type d 2> /dev/null`
    do
      echo "board: $board  proc: $proc  directory: $name"	
      mkdir -p "../../../help/$board/$proc/$name/"
      html=`sed -n '/<body/,/<\/body>/{//!p}' $name/Readme.html`
      cp -R "$name/Readme.html" "../../../help/$board/$proc/$name/" 
      cp -R "$name/src/" "../../../help/$board/$proc/$name/"
      IMG="$name.png"
      if [ -f "$name/$IMG" ]; then
        echo "$IMG exists."
      else 
        IMG="$name.gif"
        if [ -f "$name/$IMG" ]; then
          echo "$IMG exists."
        else 
          echo "Error !!!!!! $IMG does not exist.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	  exit 1
        fi
      fi
      cp -R "$name/$IMG" "../../../help/$board/$proc/$name/"
      echo "<hr><table style=\"width:100%\" border=\"0\" bgcolor='#efefef'>" >>  ../$file
      echo "<tr><td colspan=2 width=\"100%\"><a name=\"${board}_${proc}_${name}\"></a><small>[<a href='#${board}_${proc}'>$proc</a>/$name]</small>${html}<br><br></td></tr><tr><td width=\"80%\" align=center><a target=\"blank_\" href=\"$board/$proc/$name/$IMG\"><img src='$board/$proc/$name/$IMG' width=60%></a></td>" >> ../$file 
      echo "<td width=\"20%\" align=left ><a href=\"pzw/$board/$proc/$name.pzw\" target=\"_blank\" >Download (pzw)</a>" >> ../$file 
      if [ ! -f "${name}/no_online" ]; then
      echo "<br><br><a href=\"../js/picsimlab.html?../picsimlab_examples/pzw/$board/$proc/$name.pzw\" target=\"_blank\" >View Online</a><br><br>" >> ../$file 
      fi 
      echo "</td></tr></table>" >> ../$file 
    done
    cd ..
  done
  echo "</main>" >> $file
  echo "<script src='picsimlab.js' type='text/javascript'></script>" >> $file
  echo "<script data-goatcounter='https://4017.goatcounter.com/count' src='https://gc.zgo.at/count.js'></script>" >> $file
  echo "<div class='footer'>Copyright © 2022 lcgamboa. Built with make4ht.</div></body></html>" >> $file
  cd ..
done
