$(document).bind("mobileinit", function(){
    $.mobile.transitionFallbacks.slide = "slide";
    $.mobile.page.prototype.options.addBackBtn   = true;
});
