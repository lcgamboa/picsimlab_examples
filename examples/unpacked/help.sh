#!/bin/bash 
rm -Rf ../help/ ../examples/
mkdir -p "../help/"
cd ../unpacked_exp/
./compress.sh
cd ../unpacked/
echo "<!DOCTYPE html>" >> ../help/examples_index.html 
echo "<html><head>" >> ../help/examples_index.html 
echo "<title>PICSimLab Examples List</title>" >> ../help/examples_index.html 
echo "<meta charset='utf-8' />" >> ../help/examples_index.html  
echo "<meta content='width=device-width,initial-scale=1' name='viewport' />" >> ../help/examples_index.html
echo "<link href='picsimlab.css' rel='stylesheet' type='text/css' />" >> ../help/examples_index.html 
echo "<link href='style.css' rel='stylesheet' type='text/css' />" >> ../help/examples_index.html  
echo "</head>" >> ../help/examples_index.html 
echo "<body>" >> ../help/examples_index.html 
echo "<script src='picsimlab.js' type='text/javascript'></script><nav class='TOC'>" >> ../help/examples_index.html 
echo "<span class='chapterToc'>Boards</span>" >> ../help/examples_index.html 
for board in `find * -maxdepth 0 -type d 2> /dev/null`
do
  bname=$(echo $board| cut -d'_' -f 2-)
  echo "<span class='sectionToc'><a href=\"${board}.html\">${bname}</a></span>" >> ../help/examples_index.html 
done
echo "<span class='chapterToc'><a href=\"Parts.html\">Examples by parts</a></span>" >> ../help/examples_index.html 
echo "<span class='chapterToc'><a href=\"examples_index_exp.html\">Experimental boards</a></span>" >> ../help/examples_index.html 
echo "</nav><main class='main-content'>" >> ../help/examples_index.html 
echo "<br><h1>PICSimLab Examples</h1>" >> ../help/examples_index.html 
echo "<br><h2>Boards</h2>" >> ../help/examples_index.html 
echo "</main><div class='footer'>Copyright © 2021 lcgamboa. Built with make4ht.</div></body></html>" >> ../help/examples_index.html

for board in `find * -maxdepth 0 -type d 2> /dev/null`
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
  echo "<script src='picsimlab.js' type='text/javascript'></script><nav class='TOC'>" >> $file
  echo "<span class='chapterToc'><a href=\"examples_index.html\">Boards Examples Index</a></span>" >> $file 
  echo "<span class='chapterToc'>$bname</span>" >> $file   
#echo "<hr><a name="$board"></a> <h1><br>Examples: $board</h1>" >> $file 
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
      cp -R "$name/$name.png" "../../../help/$board/$proc/$name/"
      echo "<hr><table style=\"width:100%\" border=\"0\" bgcolor='#efefef'>" >>  ../$file
      echo "<tr><td colspan=4><a name=\"${board}_${proc}_${name}\"></a><small>[<a href='#${board}_${proc}'>$proc</a>/$name]</small>${html}<br><br></td></tr><tr><td width=\"50%\" align=right><a target=\"blank_\" href=\"$board/$proc/$name/$name.png\"><img src='$board/$proc/$name/$name.png' width=50%></a></td>" >> ../$file 
      echo "<td width=\"20%\" align=center ><a href=\"pzw/$board/$proc/$name.pzw\" target=\"_blank\" >Download (pzw)</a></td>" >> ../$file 
      echo "<td width=\"20%\" align=center >" >> ../$file
      if [ ! -f "${name}/no_online" ]; then
      echo "<a href=\"../js/picsimlab.html?../picsimlab_examples/pzw/$board/$proc/$name.pzw\" target=\"_blank\" >Online (wasm)</a><br><br>" >> ../$file 
      echo "<a href=\"../js/picsimlab_mt.html?../picsimlab_examples/pzw/$board/$proc/$name.pzw\" target=\"_blank\" >Online (wasm mt)</a><br><br>" >> ../$file 
      echo "<a href=\"../js/picsimlab_asmjs.html?../picsimlab_examples/pzw/$board/$proc/$name.pzw\" target=\"_blank\" >Online (asm.js)</a>" >> ../$file
      fi 
      echo "</td></tr></table>" >> ../$file 
    done
    cd ..
  done
  echo "</main><div class='footer'>Copyright © 2021 lcgamboa. Built with make4ht.</div></body></html>" >> $file
  cd ..
done

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
echo "<span class='chapterToc'><a href=\"examples_index.html\">Boards Examples Index</a></span>" >>  ../help/Parts.html
./parts.sh >> ../help/Parts.html
echo "</main><div class='footer'>Copyright © 2021 lcgamboa. Built with make4ht.</div></body></html>" >> ../help/Parts.html 

echo "<!DOCTYPE html>" >> ../help/examples_index_exp.html 
echo "<html><head>" >> ../help/examples_index_exp.html 
echo "<title>PICSimLab Examples List</title>" >> ../help/examples_index_exp.html 
echo "<meta charset='utf-8' />" >> ../help/examples_index_exp.html 
echo "<meta content='width=device-width,initial-scale=1' name='viewport' />" >> ../help/examples_index_exp.html
echo "<link href='picsimlab.css' rel='stylesheet' type='text/css' />" >> ../help/examples_index_exp.html 
echo "<link href='style.css' rel='stylesheet' type='text/css' />" >> ../help/examples_index_exp.html  
echo "</head>" >> ../help/examples_index_exp.html 
echo "<body>" >> ../help/examples_index_exp.html 
echo "<script src='picsimlab.js' type='text/javascript'></script><nav class='TOC'>" >> ../help/examples_index_exp.html
cat ../unpacked_exp/exp.html >> ../help/examples_index_exp.html
echo "</main><div class='footer'>Copyright © 2021 lcgamboa. Built with make4ht.</div></body></html>" >> ../help/examples_index_exp.html 
cd ..
rsync -cr help/ ../docs/
