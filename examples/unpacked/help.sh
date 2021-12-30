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
  height:50vmin;
  max-width: 70vmin;
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
echo "<span class='chapterToc'><a href='../'>Main</a></span>" >> ../help/examples_index.html 
echo "<span class='chapterToc'><a href=\"board_Arduino_Uno.html\">Examples by boards</a></span>" >> ../help/examples_index.html 
for board in `find * -maxdepth 0 -type d 2> /dev/null`
do
  bname=$(echo $board| cut -d'_' -f 2-)
  echo "<span class='sectionToc'><a href=\"${board}.html\">${bname}</a></span>" >> ../help/examples_index.html 
done
echo "<span class='chapterToc'><a href=\"parts_7 Segments Display.html\">Examples by parts</a></span>" >> ../help/examples_index.html 
echo "<span class='chapterToc'><a href=\"ucs_atmega328p.html\">Examples by &#181controllers</a></span>" >> ../help/examples_index.html 
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
    <img class='board' src='../picsimlab_docs/stable/img/board_Franzininho_DIY.png' >
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
      <img class='demo cursor' src='../picsimlab_docs/stable/img/board_Franzininho_DIY.png' style='width:100%' onclick='currentSlide(8)' alt='Franzininho DIY'>
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

./boards.sh

./parts.sh 
./parts2.sh 

./ucs.sh 
./ucs2.sh 
 
#experimental
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
