#!/bin/bash 

rm -Rf ../pzw_exp/
for board in `find * -maxdepth 0 -type d 2> /dev/null`
do
  cd $board	
  echo "board: $board"	
  mkdir -p "../../pzw_exp/$board/"
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
    mkdir -p "../../../pzw_exp/$board/$proc/"
    mv -f *.pzw "../../../pzw_exp/$board/$proc/"
    cd ..
  done
  cd ..
done
./help.sh
cd ..
rm -Rf ../docs/pzw_exp
mv pzw_exp/ ../docs/
