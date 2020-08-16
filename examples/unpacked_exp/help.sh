#!/bin/bash 
rm -Rf ../help/ ../examples/
rm -Rf exp.html
echo "<br><hr><br><a name=experimental ></a><h1>PICSimLab Examples (Experimental)</h1>" >> exp.html 
echo "<br><h2>Boards:</h2>" >> exp.html 
for board in `find * -maxdepth 0 -type d 2> /dev/null`
do
echo "<br><a href="#$board">$board (Experimental)</a>" >> exp.html 
done
echo "<br><a href="#parts_">Examples by parts (Experimental)</a><br>" >> exp.html 
for board in `find * -maxdepth 0 -type d 2> /dev/null`
do
  cd $board	
  echo "board: $board"	
  mkdir -p "../../help/$board/"
  echo "<hr><br><h1><a name="$board"></a>$board (Experimental)</h1>" >> ../exp.html 
  echo "<table style=\"width:98%\" border=\"1\">" >> ../exp.html 
  echo "<tr><th width=\"20%\">Processor</th><th>Description</th></tr>" >> ../exp.html 
  for proc in `find * -maxdepth 0 -type d,l 2> /dev/null`
  do
    cd $proc	
    echo "board: $board  proc: $proc"	
    echo -n "<tr><td><b>$proc <a name=\"$board" >> ../../exp.html 
    echo -n "_" >> ../../exp.html 
    echo "$proc\"></a></b></td><td><table style=\"width:100%\" border=\"1\">" >>  ../../exp.html 
    for name in `find * -maxdepth 0 -type d 2> /dev/null`
    do
      echo "board: $board  proc: $proc  directory: $name"	
      mkdir -p "../../../help/$board/$proc/$name/"
      cp -R "$name/Readme.html" "../../../help/$board/$proc/$name/" 
      cp -R "$name/src/" "../../../help/$board/$proc/$name/"
      cp -R "$name/$name.png" "../../../help/$board/$proc/$name/"
      echo "<tr><td><a name=\"${board}_${proc}_${name}\"></a>$name</td><td width=\"15%\"><a target=\"blank_\" href=\"$board/$proc/$name/$name.png\"><img src='$board/$proc/$name/$name.png' width=200></a></td><td width=\"20%\"><a href=$board/$proc/$name/Readme.html>Help / Source Code</a>" >> ../../exp.html 
      echo "<td width=\"20%\"><a href=\"../pzw_exp/$board/$proc/$name.pzw\" target=\"_blank\" >Download (pzw)</a></td>" >> ../../exp.html 
      echo "<td width=\"20%\"><a href=\"../../js_exp/picsimlab.html?../picsimlab_examples/pzw_exp/$board/$proc/$name.pzw\" target=\"_blank\" >Online (wasm)</a><br>" >> ../../exp.html 
      echo "<a href=\"../../js_exp/picsimlab_mt.html?../picsimlab_examples/pzw_exp/$board/$proc/$name.pzw\" target=\"_blank\" >Online (wasm mt)</a><br>" >> ../../exp.html 
      echo "<a href=\"../../js_exp/picsimlab_asmjs.html?../picsimlab_examples/pzw_exp/$board/$proc/$name.pzw\" target=\"_blank\" >Online (asm.js)</a></td></tr>" >> ../../exp.html 
    done
    echo "</table></td></tr>" >> ../../exp.html
    cd ..
  done
  echo "</table>" >> ../exp.html
  cd ..
done
./parts.sh >> exp.html
