// starttime | state1 | transition | state2 | transition | state3 | transition
// 07.00     | 1      | 2          | 1      | 2          | 1      | 2
//           | 0      | 1          | 3      | 4          | 6      | 7

var handle = {
  timeout : null
}

var XmlBg = function(){};
XmlBg.prototype.load = function(file){
  var self = this;

  $.ajax({
    url: file,
    cache: false,
    dataType : "text",
    processData : false,
  })
  .done( function (data) {
    self.parse (data);
  });
}

XmlBg.prototype.parse = function (data) {
  var seq = $.xml2json(data);

  if (seq.hasOwnProperty("background")) {
    var bg = seq.background;

    var startTime = bg.starttime;

    this.startTick = new Date();
    this.startTick.setHours(startTime.hour);
    this.startTick.setMinutes(startTime.minute);
    this.startTick.setSeconds(startTime.second);

    var timeline = [];

    for (var i = 0; i < bg.static.length; i++) {
      bg.static[i].type = "static";
      bg.transition[i].type = "transition";
      timeline.push(bg.static[i]);
      timeline.push(bg.transition[i]);
    }

    for (var i = 0; i < timeline.length; i++) {
      if (i == 0) {
        timeline[i].span = 0;
      }
      else {
        timeline[i].span = timeline[i - 1].span + parseInt(timeline[i - 1].duration);  
      }
      
    }

    this.timeline = timeline;
    this.where();
  }
}

//"00.00 - 23"
//"07.00 - 06.00"
//
// where are we? (search for a time-frame inside the timeline)
// 
XmlBg.prototype.where = function(){

  var now = new Date();
  var delta = (now - this.startTick).valueOf()/1000;
  var frame;

  if (delta < 0) {
    delta = 24 + (delta / 3600);
    delta *= 3600;
  }

  var timeline = this.timeline;
  var i = timeline.length;

  while (i--) {
    var frame = timeline[i];
    if (frame.span <= delta) {
      // we got the frame here;
      this.handle(frame, parseInt(frame.duration) - (delta - frame.span));
      break;
    }
  }
}

XmlBg.prototype.handle = function (frame, next){

  var self = this;

  if (frame.type == "static") {

    // do render image    
    $("#overlay").css("opacity", 0.0);
    $("#bg").css("background-image", "url(" + frame.file + ")");

  } else {

    // do css animation
    $("#overlay").css("background-image", "url(" + frame.from + ")");
    $("#bg").css("background-image", "url(" + frame.to + ")");

    var initialOpacity = next/frame.duration;

    $("#overlay").css("opacity", initialOpacity);
    $("#bg").css("opacity", 1 - initialOpacity);

    self.next = next;

    // next tick to set webkit transition
    setTimeout(function(){
      
      $("#overlay").css("-webkit-transition-property", "opacity");
      $("#overlay").css("-webkit-transition-duration", self.next + "s");
      $("#overlay").css("-webkit-transition-timing-function", "linear");
      $("#overlay").css("opacity", 0.0);

      $("#bg").css("-webkit-transition-property", "opacity");
      $("#bg").css("-webkit-transition-duration", self.next + "s");
      $("#bg").css("-webkit-transition-timing-function", "linear");
      $("#bg").css("opacity", 1.0);

    }, 1);
  }

  clearTimeout(window.handle.timeout);

  window.handle.timeout = setTimeout(function(){
    self.where();
  }, next * 1000);
}

XmlBg.prototype.reset = function (){

  clearTimeout(window.handle.timeout);

  $("#overlay").css("-webkit-transition-property", "none");
  $("#overlay").css("-webkit-transition-duration",  "none");

  $("#bg").css("-webkit-transition-property", "none");
  $("#bg").css("-webkit-transition-duration",  "none");
  
  setTimeout(function(){
    $("#bg").css("opacity", 1.0);
    $("#overlay").css("opacity", 0.0);
  }, 1);
}

$(function(){
  var xmlBg = new XmlBg();
  window.xmlBg = xmlBg;
});