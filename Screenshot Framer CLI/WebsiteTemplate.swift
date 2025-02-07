//
//  WebsiteTemplate.swift
//  Screenshot-Framer-CLI
//
//  Created by Patrick Kladek on 25.11.21.
//  Copyright © 2021 Patrick Kladek. All rights reserved.
//

import Foundation

final class WebsiteTemplate {

    static let style: String = """

    * {
      font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif;
      font-weight: 300;
    }
    #sortMenu {
      overflow: hidden;
      border: 1px solid #ccc;
      background-color: #f1f1f1;
      display: none;
    }
    #sortMenu button {
      background-color: inherit;
      float: left;
      border: none;
      outline: none;
      cursor: pointer;
      padding: 14px 16px;
      font-size: 17px;
    }
    #sortMenu button:hover {
      background-color: #ddd;
    }
    #sortMenu button.active {
      background-color: #ccc;
    }
    .deviceName {
      display: block;
      font-size: 30px;
      padding-bottom: 24px;
      padding-top: 45px;
    }
    .screenshot {
      cursor: pointer;
      border: 1px #EEE solid;
      z-index: 0;
    }
    .caption {
      font-size: 24px;
      padding-bottom: 24px;
      padding-top: 30px;
    }
    h1, h2 {
      font-weight: bold;
    }
    th {
      text-align: left;
    }
    td {
      text-align: center;
      min-width: 200px;
    }
    #overlay {
      position:fixed;
      top:0;
      left:0;
      background:rgba(0,0,0,0.8);
      z-index:5;
      width:100%;
      height:100%;
      display:none;
      cursor: zoom-out;
      text-align: center;
    }
    #imageDisplay {
      height: auto;
      width: auto;
      z-index: 10;
      cursor: pointer;
    }
    #imageInfo {
      background: none repeat scroll 0 0 rgba(0, 0, 0, 0.2);
      border-radius: 5px;
      color: white;
      margin: 20px;
      padding: 10px;
      position: absolute;
      right: 0;
      top: 0;
      width: 350px;
      z-index: -1;
    }
    #imageInfo:hover {
      z-index: 20;
    }
    """

    static let script: String = """

    var overlay        = document.getElementById('overlay');
    var imageDisplay   = document.getElementById('imageDisplay');
    var imageInfo      = document.getElementById('imageInfo');
    var screenshotLink = document.getElementsByClassName('screenshotLink');

    window.onload = setup();

    function setup() {
      var i, menu, tabTitles;

      // Since JS is enabled, show sort menu and hide tab titles
      menu = document.getElementById("sortMenu");
      menu.style.display = "block";

      tabTitles = document.getElementsByClassName("tabTitle");
      for (i = 0; i < tabTitles.length; i++) {
        tabTitles[i].style.display = "none";
      }

      doClick(document.getElementById("defaultTab"));
    }

    function getCurrentTab() {
      var i, tabs;
      tabs = document.getElementsByClassName("tabContent");
      for (i = 0; i < tabs.length; i++) {
        if (tabs[i].style.display != "none") {
          return i + 1;
        }
      }
      return 1; // fallback
    }

    function openTab(evt, tabName) {
      var i, tabContent, tabLinks;
      tabs = document.getElementsByClassName("tabContent");
      for (i = 0; i < tabs.length; i++) {
        tabs[i].style.display = "none";
      }
      tabLinks = document.getElementsByClassName("tabLink");
      for (i = 0; i < tabLinks.length; i++) {
        tabLinks[i].className = tabLinks[i].className.replace(" active", "");
      }
      document.getElementById(tabName).style.display = "block";
      evt.currentTarget.className += " active";
    }

    function doClick(el) {
      if (document.createEvent) {
        var evObj = document.createEvent('MouseEvents', true);
        evObj.initMouseEvent("click", false, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
        el.dispatchEvent(evObj);
      } else if (document.createEventObject) { //IE
        var evObj = document.createEventObject();
        el.fireEvent('onclick', evObj);
      }
    }

    for (index = 0; index < screenshotLink.length; ++index) {
      screenshotLink[index].addEventListener('click', function(e) {
        e.preventDefault();

        var img = e.target;
        if (e.target.tagName == 'A') {
          img = e.target.children[0];
        }

        // beautify
        var tmpImg = new Image();
        tmpImg.src = img.src;
        imageDisplay.style.height     = 'auto';
        imageDisplay.style.width     = 'auto';
        imageDisplay.style.paddingTop = 0;
        if (window.innerHeight < tmpImg.height) {
          imageDisplay.style.height = document.documentElement.clientHeight+'px';
        } else if (window.innerWidth < tmpImg.width) {
          imageDisplay.style.width = document.documentElement.clientWidth;+'px';
        } else {
          imageDisplay.style.paddingTop = parseInt((window.innerHeight - tmpImg.height) / 2)+'px';
        }

        imageDisplay.src             = img.src;
        imageDisplay.alt             = img.alt;
        imageDisplay.dataset.counter = img.dataset.counter;

        var path = img.src.split("/")
        imageInfo.innerHTML          = '<h3>'+decodeURI(path[path.length - 2])+'</h3>';
        imageInfo.innerHTML         += '<h3>'+decodeURI(path[path.length - 1])+'</h3>';
        imageInfo.innerHTML         += '<h4>'+tmpImg.height+'&times;'+tmpImg.width+'px</h4>';

        overlay.style.display        = "block";
      });
    }

    imageDisplay.addEventListener('click', function(e) {
      e.stopPropagation(); // !

      overlay.style.display = "none";

      img_tab = parseInt(getCurrentTab());
      img_counter = parseInt(e.target.dataset.counter) + 1;
      try {
        link = document.body.querySelector('img[data-tab="'+img_tab+'"][data-counter="'+img_counter+'"]').parentNode;
      } catch (e) {
        try {
          link = document.body.querySelector('img[data-tab="'+img_tab+'"][data-counter="0"]').parentNode;
        } catch (e) {
          return false;
        }
      }
      doClick(link);
    });

    overlay.addEventListener('click', function(e) {
      overlay.style.display = "none";
    })

    function keyPressed(e) {
      e = e || window.event;
      var charCode = e.keyCode || e.which;
      switch(charCode) {
        case 27: // Esc
        overlay.style.display = "none";
        break;
        case 34: // Page Down
        case 39: // Right arrow
        case 54: // Keypad right
        case 76: // l
        case 102: // Keypad right
        e.preventDefault();
        doClick(imageDisplay);
        break;
        case 33: // Page up
        case 37: // Left arrow
        case 52: // Keypad left
        case 72: // h
        case 100: // Keypad left
        e.preventDefault();
        document.getElementById('imageDisplay').dataset.counter -= 2; // hacky
        doClick(imageDisplay);
        break;
      }
    };
    document.body.addEventListener('keydown', keyPressed);
    """
}
