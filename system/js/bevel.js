function Run1() {
	Utils.run_command("xdg-open http://blankonlinux.or.id");
}
function Run2() {
	Utils.run_command("xdg-open http://panduan.blankonlinux.or.id");
}
function Run3() {
	Utils.run_command("xdg-open https://facebook.com/groups/blankonlinux");
}
function Run4() {
	Utils.run_command("xdg-open https://twitter.com/BlankOnLinux/");
}

function Play(){Utils.run_command("audacious -p");}
function Stop(){Utils.run_command("audtool shutdown");}
function Prev(){Utils.run_command("audacious -r");}
function Next(){Utils.run_command("audacious -f");}
function Pause(){Utils.run_command("audacious -u");}
function Repeat(){Utils.run_command("audtool --playlist-repeat-toggle");}
//function Shuffle(){Utils.run_command("audtool --playlist-shuffle-toggle");}

$(document).ready(function() {
	$('#repeat').click(function(){
		if($('#repeat').hasClass("selected")){ $('#repeat').removeClass("selected");}
		else{$('#repeat').addClass("selected");}
	});

});

function RunWallpaper() {
	Utils.run_command("gnome-control-center background");
}
function RunAccount() {
	Utils.run_command("gnome-control-center user-accounts");
}
function RunSound() {
	Utils.run_command("gnome-control-center sound");
}
function RunInfo() {
	Utils.run_command("gnome-control-center info");
}
function RunBluetooth() {
	Utils.run_command("gnome-control-center bluetooth");
}
function RunRegional() {
	Utils.run_command("gnome-control-center region");
}
function RunKeyboard() {
	Utils.run_command("gnome-control-center keyboard");
}
function RunPower() {
	Utils.run_command("gnome-control-center power");
}
function RunDate() {
	Utils.run_command("gnome-control-center datetime");
}
function RunDisplay() {
	Utils.run_command("gnome-control-center display");
}
function RunMouse() {
	Utils.run_command("gnome-control-center mouse");
}
function RunNetwork() {
	Utils.run_command("gnome-control-center network");
}
function RunOnline() {
	Utils.run_command("gnome-control-center online-accounts");
}
function RunPrinter() {
	Utils.run_command("gnome-control-center printers");
}
function RunShare() {
	Utils.run_command("gnome-control-center sharing");
}

//  slide  //

var extra = (function() {
    var activePage = null;
    var prepareShow = function() {
        $("#bevel").css("right", "0px");
    }

    var prepareHide = function() {
        changePage($("#bevel"), {
            transition: "none"
        });
        $("#bevel").addClass("ui-animation-slide");
        $("#bevel").css("right", "-" + window.outerWidth + "px");
    }

    var changePage = function(page) {
        if (typeof page === "undefined" || page.length == 0) {
            console.log("The specified page is invalid");
            return;
        }

        var withAnimation = true;

        if (arguments.length == 2) {
            withAnimation = (arguments[1].transition != "none");
        }
        var width = window.outerWidth;

        if (activePage == null) {
            activePage = $("#bevel");
            activePage.addClass("ui-animation-slide");
        }

        if (activePage == page) {
            console.log("Trying to change to same page, exiting.");
            return;
        }

        page.show();
        if (withAnimation == false) {
            activePage.removeClass("ui-animation-slide");
        }
        page.removeClass("ui-animation-slide");

        if (page.attr("id") == "bevel") {
            console.log("going to bevel");

            if (withAnimation) {
                page.css("right", "-" + width + "px");
            }
            activePage.css("right", width + "px");
        } else {
            console.log("going away from bevel");

            if (withAnimation) {
                page.css("right", width + "px");
            }
            page.css("right");
            activePage.css("right", "-" + width + "px");
        }

        if (withAnimation) {
            page.addClass("ui-animation-slide");
        }
        page.css("right", "0px");
        activePage = page;
    }

    var handleEsc = function(e) {
        if (activePage != null) {
            if (activePage.attr("id") != "bevel") {
                changePage($("#bevel"));
                return true;
            }
        }
        return false; // Not handled
    }

    return {
        handleEsc: handleEsc,
        prepareHide: prepareHide,
        prepareShow: prepareShow,
    }
})();

//$(document).ready(function() {
//    extra.init ();
//});
