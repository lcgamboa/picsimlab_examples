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
echo "<style>


.board{
  padding: 10px ;
  border: 0;
  width: auto;
  height:45vh;
}

/* Hide the images by default */
.mySlides {
  display: none;
  text-align: center;
  background-color: #222;
}

/* Add a pointer when hovering over the thumbnail images */
.cursor {
  cursor: pointer;
}

/* On hover, add a black background color with a little bit see-through */
.prev:hover,
.next:hover {
  background-color: rgba(0, 0, 0, 0.8);
}

/* Container for image text */
.caption-container {
  text-align: center;
  background-color: #222;
  padding: 2px 10px;
  color: white;
}

.row:after {
  content: '';
  display: table;
  clear: both;
}

/* Six columns side by side */
.column {
  float: left;
  width: 12.5%;
}

/* Add a transparency effect for thumnbail images */
.demo {
  opacity: 0.6;
}

.active,
.demo:hover {
  opacity: 1;
}
</style>" >> ../help/examples_index.html
echo "</head>" >> ../help/examples_index.html 
echo "<body>" >> ../help/examples_index.html 
echo "<script src='picsimlab.js' type='text/javascript'></script><nav class='TOC'>" >> ../help/examples_index.html 
echo "<script data-goatcounter='https://4017.goatcounter.com/count' src='https://gc.zgo.at/count.js'></script>" >> ../help/examples_index.html
echo "<span class='chapterToc'>Boards</span>" >> ../help/examples_index.html 
for board in `find * -maxdepth 0 -type d 2> /dev/null`
do
  bname=$(echo $board| cut -d'_' -f 2-)
  echo "<span class='sectionToc'><a href=\"${board}.html\">${bname}</a></span>" >> ../help/examples_index.html 
done
echo "<span class='chapterToc'><a href=\"Parts.html\">Examples by parts</a></span>" >> ../help/examples_index.html 
echo "<span class='chapterToc'><a href=\"examples_index_exp.html\">Experimental boards</a></span>" >> ../help/examples_index.html 
echo "</nav><main class='main-content'>" >> ../help/examples_index.html 
echo "<h1>PICSimLab Examples</h1>
<div class='container'>
  <div class='mySlides'>
    <img class='board' src='../picsimlab_docs/stable/img/picsimlab0.png' >
  </div>
  <div class='mySlides'>
    <img class='board' src='../picsimlab_docs/stable/img/picsimlab1.png' >
  </div>
  <div class='mySlides'>
    <img class='board' src='../picsimlab_docs/stable/img/picsimlab2.png' >
  </div>
  <div class='mySlides'>
    <img class='board' src='../picsimlab_docs/stable/img/picsimlab3.png' >
  </div>
  <div class='mySlides'>
    <img class='board' src='../picsimlab_docs/stable/img/picsimlab4.png' >
  </div>
  <div class='mySlides'>
    <img class='board' src='../picsimlab_docs/stable/img/board_PQDB.png' >
  </div>
  <div class='mySlides'>
    <img class='board' src='../picsimlab_docs/stable/img/picsimlab5.png' >
  </div>
  <div class='mySlides'>
    <img class='board' src='../picsimlab_docs/stable/img/board_Franzininho.png' >
  </div>

  <div class='caption-container'>
    <p id='caption' ></p>
  </div>

  <div class='row' style='background-color: #222;'>
    <div class='column'>
      <img class='demo cursor' src='../picsimlab_docs/stable/img/picsimlab0.png' style='width:100%' onclick='currentSlide(1)' alt='Breadboard'>
    </div>
    <div class='column'>
      <img class='demo cursor' src='../picsimlab_docs/stable/img/picsimlab1.png' style='width:100%' onclick='currentSlide(2)' alt='McLab1'>
    </div>
    <div class='column'>
      <img class='demo cursor' src='../picsimlab_docs/stable/img/picsimlab2.png' style='width:100%' onclick='currentSlide(3)' alt='K16F'>
    </div>
    <div class='column'>
      <img class='demo cursor' src='../picsimlab_docs/stable/img/picsimlab3.png' style='width:100%' onclick='currentSlide(4)' alt='McLab2'>
    </div>
    <div class='column'>
      <img class='demo cursor' src='../picsimlab_docs/stable/img/picsimlab4.png' style='width:100%' onclick='currentSlide(5)' alt='PICGenios'>
    </div>    
    <div class='column'>
      <img class='demo cursor' src='../picsimlab_docs/stable/img/board_PQDB.png' style='width:100%' onclick='currentSlide(6)' alt='PQDB'>
    </div>
    <div class='column'>
      <img class='demo cursor' src='../picsimlab_docs/stable/img/picsimlab5.png' style='width:100%' onclick='currentSlide(7)' alt='Arduino Uno'>
    </div>
    <div class='column'>
      <img class='demo cursor' src='../picsimlab_docs/stable/img/board_Franzininho.png' style='width:100%' onclick='currentSlide(8)' alt='Franzininho'>
    </div>
  </div>
</div>

<script>
var slideIndex = 1;
showSlides(slideIndex);

function plusSlides(n) {
  showSlides(slideIndex += n);
}

function currentSlide(n) {
  showSlides(slideIndex = n);
}

function showSlides(n) {
  var i;
  var slides = document.getElementsByClassName('mySlides');
  var dots = document.getElementsByClassName('demo');
  var captionText = document.getElementById('caption');
  if (n > slides.length) {slideIndex = 1}
  if (n < 1) {slideIndex = slides.length}
  for (i = 0; i < slides.length; i++) {
      slides[i].style.display = 'none';
  }
  for (i = 0; i < dots.length; i++) {
      dots[i].className = dots[i].className.replace(' active', '');
  }
  slides[slideIndex-1].style.display = 'block';
  dots[slideIndex-1].className += ' active';
  captionText.innerHTML = dots[slideIndex-1].alt;
}

function anime() {
  plusSlides(1)
  setTimeout(anime, 2000);
}

anime();
</script>" >> ../help/examples_index.html
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
  echo "<script data-goatcounter='https://4017.goatcounter.com/count' src='https://gc.zgo.at/count.js'></script>" >> $file
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
      echo "<tr><td colspan=2 width=\"100%\"><a name=\"${board}_${proc}_${name}\"></a><small>[<a href='#${board}_${proc}'>$proc</a>/$name]</small>${html}<br><br></td></tr><tr><td width=\"80%\" align=center><a target=\"blank_\" href=\"$board/$proc/$name/$name.png\"><img src='$board/$proc/$name/$name.png' width=60%></a></td>" >> ../$file 
      echo "<td width=\"20%\" align=left ><a href=\"pzw/$board/$proc/$name.pzw\" target=\"_blank\" >Download (pzw)</a>" >> ../$file 
      if [ ! -f "${name}/no_online" ]; then
      echo "<br><br><a href=\"../js/picsimlab.html?../picsimlab_examples/pzw/$board/$proc/$name.pzw\" target=\"_blank\" >View Online</a><br><br>" >> ../$file 
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
echo "<script data-goatcounter='https://4017.goatcounter.com/count' src='https://gc.zgo.at/count.js'></script>" >> ../help/Parts.html
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
echo "<script data-goatcounter='https://4017.goatcounter.com/count' src='https://gc.zgo.at/count.js'></script>" >> ../help/examples_index_exp.html
cat ../unpacked_exp/exp.html >> ../help/examples_index_exp.html
echo "</main><div class='footer'>Copyright © 2021 lcgamboa. Built with make4ht.</div></body></html>" >> ../help/examples_index_exp.html 
cd ..
rsync -cr help/ ../docs/
