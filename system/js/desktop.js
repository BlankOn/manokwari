var DesktopData = DesktopData || (function () {
    return {
        updateCallback: function() {
        },
        update: function() {
        return ([
            {   desktop: "",
                icon: "icon",
                name: "Files"
            },
            {   desktop: "",
                icon: "icon",
                name: "LibreOffice Writer"
            },
            {   desktop: "",
                icon: "icon",
                name: "Geany"
            },
            {   desktop: "",
                icon: "icon",
                name: "LibreOffice Calc"
            }
        ]);

        }
    }
});

var Utils = Utils || (function () {
    return {
        getIconPath: function() {}
    }
})();


var desktop = (function() {
    var desktopData = null;
    var hideLauncher = function() {
        $("#launcher").css("display", "none");
    }

    var addEvent = function () {
        if (document.addEventListener) {
            return function (el, type, fn) {
                if (el && el.nodeName || el === window) {
                    el.addEventListener(type, fn, false);
                } else if (el && el.length) {
                    for (var i = 0; i < el.length; i++) {
                        addEvent(el[i], type, fn);
                    }
                }
            };
        } else {
            return function (el, type, fn) {
                if (el && el.nodeName || el === window) {
                    el.attachEvent('on' + type, function () { return fn.call(el, window.event); });
                } else if (el && el.length) {
                    for (var i = 0; i < el.length; i++) {
                        addEvent(el[i], type, fn);
                    }
                }
            };
        }
    }

    var dragStart = function(e) {
        $("#bin").css("opacity", "0.5");
        this.style.opacity = "0.4";
        e.dataTransfer.dropEffect = "move";
        e.dataTransfer.setData("text/plain", $(this).attr("data-desktop"));
        var icon = $(e.target).find("img");
        if (icon.length > 0) {
            e.dataTransfer.setDragImage(icon.get(0), 0, 0);
        }
    }
    
    var dragEnter = function(e) {
        $("#bin").css("opacity", "1.0");
        e.preventDefault();
        this.classList.add("enter"); 
        $(this).children("img").addClass("ui-bin-img-enter");
        console.log("enter");
    }

    var dragLeave = function(e) {
        this.classList.remove("enter"); 
        $(this).children("img").removeClass("ui-bin-img-enter");
        console.log("leave");
    }


    var dragEnd = function(e) {
        $("#bin").css("opacity", "0");
        this.style.opacity = "1.0";

    }

    var dragOver = function(e) {
        e.preventDefault();
        
        console.log("over");
    }

    var dragDrop = function(e) {
        e.preventDefault();
        var data = e.dataTransfer.getData('text/plain');
        desktopData.removeFromDesktop(data);
    }


    var populateLauncher = function(data) {

        var l = $("#launcher");
        l.empty ();
        setupTrashDnD();
        for (var i = 0; i < data.length; i ++) {
            var entry_wrapper = $("<div>").
                            attr("class", "ui-launcher-entry-wrapper");

            var entry = $("<div>").
                            attr("class", "ui-launcher-entry").
                            attr("draggable", "true").
                            attr("data-desktop", data[i].desktop);
            entry_wrapper.append(entry);
            entry.get(0).addEventListener("dragstart", dragStart);
            entry.get(0).addEventListener("dragend", dragEnd);
            entry.click(function() {
                Utils.run_desktop($(this).attr("data-desktop"), true);
            });

            var img_div = $("<div>").
                            attr("class", "ui-launcher-entry-img-holder").
                            attr("draggable", "true");

            var img = $("<img>").
                            attr("draggable", "true").
                            attr("src", data[i].icon);
            img_div.append(img);
            var text = $("<span>").
                            attr("translate", "no").
                            attr("title", data[i].name).
                            text(data[i].name);

            entry.append(img_div);
            entry.append(text);
            l.append(entry_wrapper);
        }
        // -------
        // accending sort
			function asc_sort(a, b){
				return ($(b).text()) < ($(a).text()) ? 1 : -1;    
			}
        $(".ui-launcher-entry-wrapper").sort(asc_sort).appendTo("#launcher");
			$(".ui-launcher-entry-img-holder").first().addClass("ui-launcher-entry-img-holder-first");
			$(".ui-launcher-entry-img-holder").last().addClass("ui-launcher-entry-img-holder-last");
                
    }

    var setupLauncher = function() {
        var data = desktopData.update ();         
        populateLauncher (data);
    }

    var init = function() {
        desktopData = new DesktopData(); // Defined in the backend
        desktopData.updateCallback("desktop.refresh()");
        var l = $("#base");
        var bin = $("<div>").
                    attr("id", "bin").
                    attr("class", "ui-bin");
        var trash = $("<img>").
                    attr("class", "ui-bin-img").
                    attr("src", Utils.getIconPath("user-trash", 48));
        bin.append(trash);
        l.prepend(bin);
        setupLauncher();
    }

    var setupTrashDnD = function() {
        var dropZone = $("#bin").get(0);
        dropZone.addEventListener("dragenter", dragEnter);
        dropZone.addEventListener("dragleave", dragLeave);
        dropZone.addEventListener("dragover", dragOver);
        dropZone.addEventListener("drop", dragDrop);
    }

    var refresh = function() {
        setupLauncher();
    }

    var setBackground = function(file) { 
      if (file) {
        // reset 
        xmlBg.reset();

        // ends with
        if (file.split(".").pop() == "xml") {

          // set xml file
          xmlBg.load(file);

        } else {

          // set background url
          $("#bg").css("background-image", "url(" + file + ")");

        }
        return true;

      } else {

        //
        return false;
      }
    }
    
    return { 
        init: init, 
        refresh: refresh, 
        setBackground: setBackground 
    }
})();



$(document).ready(function() {
    desktop.init();
		
    // to do testing using local file, we can do following test:
    //
    //
    desktop.setBackground("file:///Users/diorahman/Experiments/projects/blankon/dir/temp/themes/Adwaita/backgrounds/adwaita-timed.xml");

    // setTimeout(function(){
    //    desktop.setBackground("file:///Users/diorahman/Experiments/projects/blankon/dir/temp/themes/Adwaita/backgrounds/good-night.jpg");
    // }, 1000);

});
