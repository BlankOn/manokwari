// lastBg is defined initially in the backend

function updateBackground(bg) {
    $("body").css("background-image", "url(" + bg + ")");
    lastBg = bg;
}
$(document).ready(function() {
    updateBackground(lastBg);
});
