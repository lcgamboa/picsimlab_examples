#!/bin/bash 
rm -Rf exp.html
echo "<a name=experimental ></a><h1>PICSimLab Examples (Experimental)</h1>" >> exp.html 
echo "<br><h2>Boards:</h2>" >> exp.html 
for board in `find * -maxdepth 0 -type d 2> /dev/null`
do
echo "<br><a href="${board}.html">${board}</a>" >> exp.html 
done
echo "<br><a href=\"Parts_exp.html\">Examples by parts</a><br>" >> exp.html 
echo "<br><a href=\"examples_index.html\">Stable boards examples</a><br><br>" >> exp.html 
for board in `find * -maxdepth 0 -type d 2> /dev/null`
do
  file=../../help/$board.html 
  cd $board	
  echo "board: $board"	
  mkdir -p "../../help/$board/"
  echo "<!DOCTYPE html>" >> $file 
  echo "<html><head>" >> $file   
  echo "<meta charset="utf-8" />" >> $file 
  echo "<title>PICSimLab Examples Board $board</title>" >> $file 
  echo "</head>" >> $file 
  echo "<body>" >> $file 
  echo "<a href=\"examples_index_exp.html\">Experimental Boards Examples Index</a><br>" >> $file 
  echo "<hr><a name="$board"></a> <h1><br>Examples: $board</h1>" >> $file 
  for proc in `find * -maxdepth 0 -type d,l 2> /dev/null`
  do
    cd $proc	
    for name in `find * -maxdepth 0 -type d 2> /dev/null`
    do
      echo "<br><a href=\"#${board}_${proc}_${name}\">$proc/$name</a>" >> ../$file
    done
    echo "<br>" >> ../$file	    
    cd ..
  done	  
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
      echo "<tr><td colspan=4><a name=\"${board}_${proc}_${name}\"></a><small>[<a href='#$board'>$board</a>/<a href='#${board}_${proc}'>$proc</a>/$name]</small>${html}<br><br></td></tr><tr><td width=\"50%\" align=right><a target=\"blank_\" href=\"$board/$proc/$name/$name.png\"><img src='$board/$proc/$name/$name.png' width=50%></a></td>" >> ../$file 
      echo "<td width=\"20%\" align=center><a href=\"pzw_exp/$board/$proc/$name.pzw\" target=\"_blank\" >Download (pzw)</a></td>" >> ../$file 
      echo "<td width=\"20%\" align=center>" >> ../$file
      if [ ! -f "${name}/no_online" ]; then
         echo "<a href=\"../js_exp/picsimlab.html?../picsimlab_examples/pzw_exp/$board/$proc/$name.pzw\" target=\"_blank\" >Online (wasm)</a><br><br>" >> ../$file
         echo "<a href=\"../js_exp/picsimlab_mt.html?../picsimlab_examples/pzw_exp/$board/$proc/$name.pzw\" target=\"_blank\" >Online (wasm mt)</a><br><br>" >> ../$file
         echo "<a href=\"../js_exp/picsimlab_asmjs.html?../picsimlab_examples/pzw_exp/$board/$proc/$name.pzw\" target=\"_blank\" >Online (asm.js)</a>" >> ../$file
      fi
      echo "</td></tr></table>" >> ../$file
    done
    cd ..
    echo "<br><br></body></html>" >> $file
  done
  cd ..
done

echo "<!DOCTYPE html>" >> ../help/Parts_exp.html 
echo "<html><head>" >> ../help/Parts_exp.html 
echo "<meta charset="utf-8" />" >> ../help/Parts_exp.html 
echo "<title>PICSimLab Examples List</title>" >> ../help/Parts_exp.html 
echo "</head>" >> ../help/Parts_exp.html 
echo "<body>" >> ../help/Parts_exp.html 
echo "<a href=\"examples_index.html\">Boards Examples Index</a><br>" >>  ../help/Parts_exp.html
./parts.sh >> ../help/Parts_exp.html
echo "<br><br></body></html>" >> ../help/Parts_exp.html 

