#!/bin/bash 

for board in `find * -maxdepth 0 -type d 2> /dev/null`
do
  cd $board	
  #echo "board: $board"	
  for proc in `find * -maxdepth 0 -type d,l 2> /dev/null`
  do
    cd $proc	
    #echo "|-board: $board  proc: $proc"	
    for name in `find * -maxdepth 0 -type d 2> /dev/null`
    do
      cd $name
      #echo "  |-board: $board  proc: $proc  directory: $name"	

      link="https://lcgamboa.github.io/picsimlab_examples/${board}.html#${board}_${proc}_${name}"
      line="Text Box,237,80,0:12,5,4,$link%Examplesource info"
      
      pattern="*.pcf"
      files=( $pattern )
      
      if [ ${#files[0]} -gt 5 ]; then 
          grep -qF 'https://lcgamboa.github.io/picsimlab_examples/' ${files[0]} || echo "==============> Updated board: $board  proc: $proc  directory: $name"
          grep -qF 'https://lcgamboa.github.io/picsimlab_examples/' ${files[0]} || echo "$line" >> ${files[0]}
      else 
          fname="$board.pcf"
          fname=$(sed "s/board/parts/" <<< "${fname}")
          
          echo "version,0,0,0:0.9.1" > ${fname} 
          echo "scale,0,0,0:1.000000" >> ${fname}
          echo "useAlias,0,0,0:0" >> ${fname}
          echo "$line" >> ${fname}
          echo "==============> Created board: $board  proc: $proc  directory: $name"
      fi
      
      cd ..
    done
    cd ..
  done
  cd ..
done

