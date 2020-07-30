#!/bin/bash 

rm -Rf ../pzw/
for board in `find * -maxdepth 0 -type d 2> /dev/null`
do
  cd $board	
  echo "board: $board"	
  mkdir -p "../../pzw/$board/"
  for proc in `find * -maxdepth 0 -type d,l 2> /dev/null`
  do
    cd $proc	
    echo "board: $board  proc: $proc"	
    rm -Rf *.pzw
    for name in `find * -maxdepth 0 -type d 2> /dev/null`
    do
      echo "board: $board  proc: $proc  directory: $name"	
      cp -R $name picsimlab_workspace/
      rm -Rf picsimlab_workspace/src
      zip -r $name.pzw picsimlab_workspace -x \*.png
      rm -Rf picsimlab_workspace
    done
    mkdir -p "../../../pzw/$board/$proc/"
    mv -f *.pzw "../../../pzw/$board/$proc/"
    cd ..
  done
  cd ..
done
./help.sh
cd ..
rm -Rf ../docs/pzw
mv pzw/ ../docs/
