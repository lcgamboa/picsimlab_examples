#!/bin/bash 
rm -Rf ../help/ ../examples/
mkdir -p "../help/"
cd ../unpacked_exp/
./compress.sh
cd ../unpacked/
echo "<!DOCTYPE html>" >> ../help/examples_index.html 
echo "<html><head>" >> ../help/examples_index.html 
echo "<meta charset="utf-8" />" >> ../help/examples_index.html 
echo "<title>PICSimLab Examples List</title>" >> ../help/examples_index.html 
echo "</head>" >> ../help/examples_index.html 
echo "<body>" >> ../help/examples_index.html 
echo "<br><h1>PICSimLab Examples</h1>" >> ../help/examples_index.html 
echo "<br><h2>Boards:</h2>" >> ../help/examples_index.html 
for board in `find * -maxdepth 0 -type d 2> /dev/null`
do
echo "<br><a href=\"#$board\">$board</a>" >> ../help/examples_index.html 
done
echo "<br><a href=\"#parts\">Examples by parts</a>" >> ../help/examples_index.html 
echo "<br><a href=\"#experimental\">Experimental boards examples</a><br><br>" >> ../help/examples_index.html 
for board in `find * -maxdepth 0 -type d 2> /dev/null`
do
  cd $board	
  echo "board: $board"	
  mkdir -p "../../help/$board/"
  echo "<hr><br><h1><a name="$board"></a>$board</h1>" >> ../../help/examples_index.html 
  echo "<table style=\"width:98%\" border=\"1\">" >> ../../help/examples_index.html 
  echo "<tr><th width=\"20%\">Processor</th><th>Description</th></tr>" >> ../../help/examples_index.html 
  for proc in `find * -maxdepth 0 -type d,l 2> /dev/null`
  do
    cd $proc	
    echo "board: $board  proc: $proc"	
    echo -n "<tr><td><b>$proc <a name=\"$board" >> ../../../help/examples_index.html 
    echo -n "_" >> ../../../help/examples_index.html 
    echo "$proc\"></a></b></td><td><table style=\"width:100%\" border=\"1\">" >>  ../../../help/examples_index.html 
    for name in `find * -maxdepth 0 -type d 2> /dev/null`
    do
      echo "board: $board  proc: $proc  directory: $name"	
      mkdir -p "../../../help/$board/$proc/$name/"
      cp -R "$name/Readme.html" "../../../help/$board/$proc/$name/" 
      cp -R "$name/src/" "../../../help/$board/$proc/$name/"
      cp -R "$name/$name.png" "../../../help/$board/$proc/$name/"
      echo "<tr><td><a name=\"${board}_${proc}_${name}\"></a>$name</td><td width=\"15%\"><a target=\"blank_\" href=\"$board/$proc/$name/$name.png\"><img src='$board/$proc/$name/$name.png' width=200></a></td><td width=\"20%\"><a href=$board/$proc/$name/Readme.html>Help / Source Code</a>" >> ../../../help/examples_index.html 
      echo "<td width=\"20%\"><a href=\"../pzw/$board/$proc/$name.pzw\" target=\"_blank\" >Download (pzw)</a></td>" >> ../../../help/examples_index.html 
      echo "<td width=\"20%\">" >> ../../../help/examples_index.html
      if [ ! -f "${name}/no_online" ]; then
      echo "<a href=\"../../js/picsimlab.html?../picsimlab_examples/pzw/$board/$proc/$name.pzw\" target=\"_blank\" >Online (wasm)</a><br>" >> ../../../help/examples_index.html 
      echo "<a href=\"../../js/picsimlab_mt.html?../picsimlab_examples/pzw/$board/$proc/$name.pzw\" target=\"_blank\" >Online (wasm mt)</a><br>" >> ../../../help/examples_index.html 
      echo "<a href=\"../../js/picsimlab_asmjs.html?../picsimlab_examples/pzw/$board/$proc/$name.pzw\" target=\"_blank\" >Online (asm.js)</a>" >> ../../../help/examples_index.html
      fi 
      echo "</td></tr>" >> ../../../help/examples_index.html 
    done
    echo "</table></td></tr>" >> ../../../help/examples_index.html
    cd ..
  done
  echo "</table>" >> ../../help/examples_index.html
  cd ..
done
./parts.sh >> ../help/examples_index.html
cat ../unpacked_exp/exp.html >> ../help/examples_index.html
echo "</body></html>" >> ../help/examples_index.html 
cd ..
mv help examples
rsync -cr examples/ ../docs/examples/
