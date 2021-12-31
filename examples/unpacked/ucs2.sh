#!/bin/bash
. ucsname.sh

for uc in "${ucs[@]}";do
  file="../help/ucs_${uc// /_}.html" 

  echo "uc: $uc => '$file'"	
  echo "<!DOCTYPE html>" > "$file" 
  echo "<html><head>" >> "$file"   
  echo "<title>PICSimLab Examples &#181controllers $uc</title>" >> "$file" 
  echo "<meta charset='utf-8' />" >> "$file"  
  echo "<meta content='width=device-width,initial-scale=1' name='viewport' />" >> "$file"
  echo "<link href='picsimlab.css' rel='stylesheet' type='text/css' />" >> "$file" 
  echo "<link href='style.css' rel='stylesheet' type='text/css' />" >> "$file"  
  echo "</head>" >> "$file" 
  echo "<body>" >> "$file" 
  echo "<nav class='TOC'>" >> "$file"
  echo "<span class='chapterToc'><a href=\"examples_index.html\">Examples Index</a></span>" >> "$file" 

for chuc in "${ucs[@]}";do
  echo "<span class='chapterToc'><a href=\"ucs_${chuc// /_}.html\">$chuc</a></span>" >> "$file" 

  if [ "$chuc" == "$uc" ]; then  
  bname_old="z"
  pfiles=`grep -m1 "$uc" */*/*/*.ini | cut -f1 -d:`
  for pfile in $pfiles; do
    board=`echo $pfile | awk -F/ '{print $1}'` 
    proc=`echo $pfile | awk -F/ '{print $2}'`
    name=`echo $pfile | awk -F/ '{print $3}'`
    bname=$(echo $board| cut -d'_' -f 2-)

    if [ "$bname_old" != "$bname" ]; then
      echo "<span class='sectionToc'><a href=\"#${bname}_${proc}\">$bname</a></span>" >> "$file"
      bname_old="${bname}" 
    fi

    if ! test -z "$name" 
    then
     echo "<span class='subsectionToc'><a href=\"#${bname}_${proc}_${name}\">$name</a></span>" >> "$file"
    fi
  done
  fi
done

  echo "</nav><main class='main-content'>" >> "$file"  
  board_old="z"
  pfiles=`grep -m1 "$uc" */*/*/*.ini | cut -f1 -d:`
  for pfile in $pfiles; do
    board=`echo $pfile | awk -F/ '{print $1}'` 
    proc=`echo $pfile | awk -F/ '{print $2}'`
    name=`echo $pfile | awk -F/ '{print $3}'`

    bname=$(echo $board| cut -d'_' -f 2-)

    echo "board: $bname  proc: $proc"	
    echo -n "<a name=\"$bname" >> "$file" 
    echo -n "_" >> "$file" 
    echo "$proc\"></a>" >> "$file" 

      echo "board: $bname  proc: $proc  directory: $name"	

      html=`sed -n '/<body/,/<\/body>/{//!p}' ${board}/${proc}/${name}/Readme.html`

      IMG="$name.png"
      if [ -f "${board}/${proc}/${name}/$IMG" ]; then
        echo "$IMG exists."
      else 
        IMG="$name.gif"
        if [ -f "${board}/${proc}/${name}/$IMG" ]; then
          echo "$IMG exists."
        else 
          echo "Error !!!!!! $IMG does not exist.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	  exit 1
        fi
      fi

      echo "<hr><table style=\"width:100%\" border=\"0\" bgcolor='#efefef'>" >> "$file"
      echo "<tr><td colspan=2 width=\"100%\"><a name=\"${bname}_${proc}_${name}\"></a><small>[${bname}/<a href='#${bname}_${proc}'>$proc</a>/$name]</small>${html}<br><br></td></tr><tr><td width=\"80%\" align=center><a target=\"blank_\" href=\"${board}/${proc}/${name}/$IMG\"><img src='${board}/${proc}/${name}/$IMG' width=60%></a></td>" >> "$file" 
      echo "<td width=\"20%\" align=left ><a href=\"pzw/${board}/${proc}/${name}.pzw\" target=\"_blank\" >Download (pzw)</a>" >> "$file" 
      if [ ! -f "${name}/no_online" ]; then
      echo "<br><br><a href=\"../js/picsimlab.html?../picsimlab_examples/pzw/${board}/${proc}/${name}.pzw\" target=\"_blank\" >View Online</a><br><br>" >> "$file" 
      fi 
      echo "</td></tr></table>" >> "$file" 
    

  done
  echo "</main>" >> "$file"
  echo "<script src='picsimlab.js' type='text/javascript'></script>" >> "$file"
  echo "<script data-goatcounter='https://4017.goatcounter.com/count' src='https://gc.zgo.at/count.js'></script>" >> "$file"
  echo "<div class='footer'>Copyright © 2021 lcgamboa. Built with make4ht.</div></body></html>" >> "$file"

done
