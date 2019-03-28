var dropdownElement = document.querySelector('#versionDropdown');
var innerContent = document.querySelector('#allVersions');
var body = document.querySelector('body');
var hamburger = document.querySelector('#menuIcon');
var subMenu = document.querySelector('#subMenu');
var sidebar = document.querySelector('#sidebar');
var versionsOpen;
var sidebarOpen;
var expandedHeight;
var dropdownTimer;




if (dropdownElement) {
    dropdownElement.addEventListener('click', function () {
        toggleDropdown();
    });

    dropdownElement.addEventListener('keyup',function(e){
        if (e.keyCode === 13) {
            toggleDropdown();
      }  
    });

    dropdownElement.addEventListener("mouseleave", function (event) {
        // console.log("mouseout");
        if (versionsOpen) { // close dropdown after 2 seconds
            // console.log("mouseout and open");
            dropdownTimer = setTimeout(
                () => {
                    toggleDropdown('hide');
                },
                2000
            );
        }
    });
    dropdownElement.addEventListener("mouseenter", function (event) {
        // console.log("stopTimeout");
        clearTimeout(dropdownTimer);
    });
}


function toggleDropdown(override) {
    expandedHeight = document.querySelector('#allVersions').scrollHeight;

    if (override == "hide") {
        closeDropdown();
    } else if (override == "open") {
        openDropdown();
    } else {

        versionsOpen = dropdownElement.getAttribute('data-isopen');

        // sets strings to booleans
        if (versionsOpen == "true") {
            versionsOpen = true;
        } else {
            versionsOpen = false;
        }

        if (versionsOpen) { // close dropdown
            closeDropdown();
        } else { // open dropdown
            openDropdown();
        }

    }
}


function closeDropdown() {
    // console.log("close");
    dropdownElement.classList.remove("open");
    innerContent.style.height = '0px';
    dropdownElement.setAttribute('data-isopen', 'false');
    dropdownElement.setAttribute('aria-expanded', 'false');
    versionsOpen = false;

    var items = document.getElementById("allVersions").getElementsByTagName("li");
    for (i = 0; i < items.length; i++) {
        items[i].getElementsByClassName('versionPill')[0].tabIndex = -1;
    }
    // console.log( {isOpen} );
}

function openDropdown() {
    // console.log("open");
    dropdownElement.classList.add("open");
    innerContent.style.height = expandedHeight + 'px';
    dropdownElement.setAttribute('data-isopen', 'true');
    dropdownElement.setAttribute('aria-expanded', 'true');
    versionsOpen = true;

    
    var items = document.getElementById("allVersions").getElementsByTagName("li");
    for (i = 0; i < items.length; i++) {
        items[i].getElementsByClassName('versionPill')[0].tabIndex = 0;
    }

    setTimeout(function() {
        dropdownElement.focus();
    },200);
    // console.log( {isOpen} );
}

function openVersion(url, collection) {
    document.querySelector('#pageContainer').classList.add("hide");
    document.querySelector('#versionPillCurrent').innerHTML = collection;
    setTimeout(function () {
        window.open(url, '_self');
    }, 200)
}

let menuIcon = document.getElementById('menuIcon');

menuIcon.addEventListener('click', function () {
    toggleSidebarMenu();
});

menuIcon.addEventListener('keyup',function(e){
    if (e.keyCode === 13) {
        toggleSidebarMenu();
  }  
});

let mobileVersionShortcut = document.getElementById('mobileVersionShortcut');

mobileVersionShortcut.addEventListener('click', function () {
    toggleSidebarMenu();
    toggleDropdown();
});

mobileVersionShortcut.addEventListener('keyup',function(e){
    if (e.keyCode === 13) {
        toggleSidebarMenu();
        toggleDropdown();
  }  
});


function toggleSidebarMenu(override) {
    sidebarOpen = body.getAttribute('data-sidebarisopen');
    // sets strings to booleans
    if (sidebarOpen == "true") {
        closeSidebar();
    } else {
        openSidebar();
    }
}

function closeSidebar() {
    body.classList.remove("sidebarOpen");
    hamburger.classList.remove("open");
    body.setAttribute('data-sidebarisopen', 'false');
    var allNavItems = document.getElementById('sidebar').getElementsByTagName('a')
    for (i = 0; i < allNavItems.length; i++) {
        allNavItems[i].tabIndex = -1
    }
}

function openSidebar() {
    var navScrollPos = getPosition(document.querySelector('#site-nav'));
    var navHeight = document.querySelector('#site-nav').offsetHeight;
    if (navScrollPos * -1 < document.querySelector('.mastheadTitle').offsetHeight) {
        body.scrollIntoView({ behavior: "smooth", block: "start" })
        var menuStartHeight = navHeight;
    } else {
        var menuStartHeight = navHeight + navScrollPos;
    }
    sidebar.style.top = menuStartHeight + 'px';
    hamburger.classList.add("open");
    body.classList.add("sidebarOpen");
    body.setAttribute('data-sidebarisopen', 'true');

    var allNavItems = document.getElementById('sidebar').getElementsByTagName('a')
    for (i = 0; i < allNavItems.length; i++) {
        allNavItems[i].tabIndex = 0
    }
}

function getPosition(el) {
    var yPos = 0;

    while (el) {
        if (el.tagName == "BODY") {
            // deal with browser quirks with body/window/document and page scroll
            var yScroll = el.scrollTop || document.documentElement.scrollTop;
            yPos += (el.offsetTop - yScroll + el.clientTop);
        } else {
            // for all other non-BODY elements
            yPos += (el.offsetTop - el.scrollTop + el.clientTop);
        }
        el = el.offsetParent;
    }
    return yPos;
}


// deal with the page getting resized or scrolled
window.addEventListener("scroll", updatePosition, false);
window.addEventListener("resize", updatePosition, false);


function updatePosition() {
    // add your code to update the position when your browser
    // is resized or scrolled
}

function urlChecker() {
    var versionsContainer = document.getElementById('allVersions');
    var allVersions = versionsContainer.getElementsByClassName('version');
    for (var i = 0; i < allVersions.length; i++) {
        checkURL(allVersions[i]);
    }
}



function checkURL(theObject) {
    var request = new XMLHttpRequest();
    request.open('GET', theObject.dataset.url, true);
    request.onreadystatechange = function () {
        if (request.readyState === 4) {
            if (request.status === 404) {
                theObject.classList.add("disabled");
                theObject.removeAttribute("onclick");
                theObject.getElementsByTagName("a")[0].removeAttribute("href");
                // return false;
            }
        }
    };
    request.send();
}

function openCardWindow(e, url, dest) {
    e = e || window.event;
    var target = e.target || e.srcElement;
    if (!target.dataset.ignoreparent) {
        window.open(url, dest);
    }
}


var scriptTag = "<link rel='stylesheet' href='/assets/css/apiStyle.css'>";



function loadApiStyle(cssLocation,theFrame) {
    var iframe = theFrame
    iframeDoc = iframe.contentWindow.document;
    var frameHead = iframeDoc.getElementsByTagName("head")[0];
    
    var css = document.createElement("link");
    css.type = "text/css";
    css.rel = "stylesheet";
    css.href = cssLocation;

    var headBase = document.createElement("BASE");
    headBase.setAttribute("target", "_parent");
    frameHead.appendChild(headBase);

    
    
    // frameHead.appendChild(css);

    theFrame.style.opacity=1;
}


document.onkeydown = function(evt) {
    evt = evt || window.event;
    if (evt.keyCode == 27) {
        closeSidebar();
    }
};