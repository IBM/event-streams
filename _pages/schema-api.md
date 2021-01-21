---
title: "Schema API"
permalink: /schema-api/
layout: apiFrame
mastheadNavItem: APIs
---

<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
h2.ex1 {
  margin-left: 32px;
}

.dropbtn {
  background-color: #0f62fe;
  color: white;
  padding: 16px;
  font-size: 16px;
  border: none;
  cursor: pointer;
}

.dropbtn:hover, .dropbtn:focus {
  background-color: #2980B9;
}

.dropdown {
  position: relative;
  display: inline-block;
  margin-left: 32px;
}

.dropdown-content {
  display: none;
  position: absolute;
  background-color: #f1f1f1;
  min-width: 160px;
  overflow: auto;
  box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
  z-index: 1;
}

.dropdown-content a {
  color: black;
  padding: 12px 16px;
  text-decoration: none;
  display: block;
}

.dropdown a:hover {background-color: #ddd;}

.show {display: block;}
</style>
</head>

<body>

<h2 class="ex1">Select your Event Streams version to view the compatible schema registry API documentation:</h2>

<div class="dropdown">
  <button onclick="myFunction()" class="dropbtn">Select Event Streams version</button>
  <div id="myDropdown" class="dropdown-content">
    <a href="../schema-api-10/">Version 10.0 or later</a>
    <a href="../schema-api-2019/">Version 2019.4.x or earlier</a>
  </div>
</div>

<script>
/* When the user clicks on the button,
toggle between hiding and showing the dropdown content */
function myFunction() {
  document.getElementById("myDropdown").classList.toggle("show");
}

// Close the dropdown if the user clicks outside of it
window.onclick = function(event) {
  if (!event.target.matches('.dropbtn')) {
    var dropdowns = document.getElementsByClassName("dropdown-content");
    var i;
    for (i = 0; i < dropdowns.length; i++) {
      var openDropdown = dropdowns[i];
      if (openDropdown.classList.contains('show')) {
        openDropdown.classList.remove('show');
      }
    }
  }
}
</script>

</body>
</html>
