var idle = (function() {
    var idleClockHandle = 0;
    var idleScreenVisibilityChange = false;
    var hidingIdleScreen = false;

    var idleClock = function() {
        var clock = $("#idleClock");
        clock.find("h1").text(Utils.getTime());
        clock.find("h2").text(Utils.getDate());
    }

    var showIdleScreen = function() {
        hidingIdleScreen = false;
        idleClockHandle = setInterval(idleClock, 60000);  
        idleClock();
        $("#idleScreen").css("display", "inherit");
        $("#idleScreen").css("opacity", "1.0");
    }

    var hideIdleScreen = function() {
        if (hidingIdleScreen == false) {
            hidingIdleScreen = true;
            $("#idleScreen").css("opacity", "0.0");
            if (idleClockHandle != 0) {
                clearTimeout(idleClockHandle);
                idleClockHandle = 0;
            }
        }
    }

    var setBackground = function(bg) {
        $("#idleScreen").css("background-image", "url(" + bg + ")");
    }

    return {
        showIdleScreen: showIdleScreen,
        hideIdleScreen: hideIdleScreen,
        setBackground: setBackground,
    }

})();


$(document).ready(function() {
    idle.showIdleScreen();
});
