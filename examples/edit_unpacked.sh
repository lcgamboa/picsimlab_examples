#!/bin/bash 
echo $1
dir=`pwd`
rm -rf /tmp/picsimlab_workspace/
cp -Rv "$1" /tmp/picsimlab_workspace/
cd /tmp
rm -f test.pzw
zip -rX test.pzw picsimlab_workspace -x \*no_online \*.png \*src/\*
picsimlab test.pzw
#user must save the workspace as /tmp/test.pzw after edition
rm -rf picsimlab_workspace/
unzip test.pzw
cd picsimlab_workspace/
cp -Rv * "$dir/$1"
