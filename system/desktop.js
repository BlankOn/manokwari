// lastBg is defined initially in the backend

var desktop = (function() {
    var updateBackground = function(bg) {
        $("body").css("background-image", "url(" + bg + ")");
        lastBg = bg;
    }
    return {
        updateBackground: updateBackground
    }
})();

$(document).ready(function() {
    desktop.updateBackground(lastBg);
});
