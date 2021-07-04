
let sidebar = document.querySelector("nav.TOC");

let sstop = sessionStorage.getItem("sidebar-scroll");
if (sstop !== null) {
  sidebar.scrollTop = parseInt(sstop, 10);
}

window.addEventListener("beforeunload", () => {
  sessionStorage.setItem("sidebar-scroll", sidebar.scrollTop);
});

    function googleTranslateElementInit() {
        new google.translate.TranslateElement(
            {pageLanguage: 'en',autoDisplay: false},
            'google_translate_element'
        );
    }


