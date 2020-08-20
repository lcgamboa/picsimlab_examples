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
      mv $name picsimlab_workspace/
      zip -rX $name.pzw picsimlab_workspace -x \*no_online \*.png  \*src/\*
      mv picsimlab_workspace/ $name
    done
    mkdir -p "../../../pzw_exp/$board/$proc/"
    mv -f *.pzw "../../../pzw_exp/$board/$proc/"
    cd ..
  done
  cd ..
done
./help.sh
cd ..
rsync -rvc pzw_exp/ ../docs/pzw_exp/
