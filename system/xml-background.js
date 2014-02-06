
// handlers
window.handle = {
  timeout : null
}

var XmlBackground = function() {
  /*
   * Use singleton pattern to maintain a single background sequence items handler object
   */
  if (XmlBackground.prototype.instance) {
    return XmlBackground.prototype.instance;
  }
  XmlBackground.prototype.instance = this;
};

XmlBackground.prototype.setFile = function(file) {

  // set file and load it
  this.file = file;
  this.load();

};

XmlBackground.prototype.load = function() {

  // loading file from local disk
  if (!this.file) {
    return;
  }
  var self = this;

  $.ajax({
    url: self.file
  }).done(function(data) {
    self.$data = $(data);
    self.run();
  });
};

XmlBackground.prototype.getItem = function() {

  // get current date
  var now = new Date();
  var acc = 0;
  var i = this.$data.children().length - 1;
  var delta = (now - this.startTime) / 1000;

  var self = this;

  while (i > 1) {

    var item = this.$data.children()[i];

    if (item.nodeName.toLowerCase() != "starttime" && delta >= (item.delta) ) {
      
      var hasNext = i < (this.$data.children().length - 1);
      var nextItem;
      var when = 0;
      var initialOpacity = 1.0;

      if (hasNext) {

        nextItem = this.$data.children()[ i + 1 ];

        // when is in seconds
        when = nextItem.delta - delta;
        initialOpacity = 1 - (when/nextItem.duration);

        if (nextItem.nodeName.toLowerCase() == "transition") {

          // handle next item
          self.transitionDuration = when;

          // background - to
          self.handleItem(nextItem);

          // need hacks on this. The initial opacity should reflect current setup
          $("#bg").css("opacity", initialOpacity);
          $("#overlay").css("opacity", 1 - initialOpacity);

          $("#bg").css("-webkit-transition-property", "opacity");
          $("#bg").css("-webkit-transition-duration", self.transitionDuration + "s");
          $("#bg").css("-webkit-transition-timing-function", "linear");
          $("#bg").css("opacity", 1.0);

          // overlay - from
          $("#overlay").css("-webkit-transition-property", "opacity");

          // especially this line
          $("#overlay").css("-webkit-transition-duration", self.transitionDuration + "s");
          $("#overlay").css("-webkit-transition-timing-function", "linear");
          $("#overlay").css("opacity", 0.0);
        }
        else {

          // handle item
          self.handleItem(item);  
        }
        
      } else {
        // handle current item
        self.handleItem(item);
      }

      if (nextItem && when) {

        if (window.handle.timeout) {
          clearTimeout(window.handle.timeout);  
        }
        
        window.handle.timeout = setTimeout(function(){
          self.getItem();
        }, when * 1000);

      }

      // break the loop
      break;
    }

    i--;
  }
}

XmlBackground.prototype.handleItem = function(item) {
  
  var file;

  if (item.nodeName.toLowerCase() == "static") {

    file = item.querySelector("file").textContent;
    $("#bg").css("background-image", "url(" + file + ")");

  } else {
    
    overlay = item.querySelector("from").textContent;
    file = item.querySelector("to").textContent;

    $("#overlay").css("background-image", "url(" + overlay + ")");
    $("#bg").css("background-image", "url(" + file + ")");

  }
}

XmlBackground.prototype.reset = function() {

  // reset timeout
  if (window.handle.timeout) {
    clearTimeout(window.handle.timeout);
  }

  // reset transition
  $("#overlay").css("transition", "none");
  $("#bg").css("transition", "none");
}

XmlBackground.prototype.run = function() {

  // start time
  var $startTime = this.$data.find("starttime");
  
  // new Date();
  this.startTime = new Date();
  this.startTime.setHours($startTime.find("hour").text());
  this.startTime.setMinutes($startTime.find("minute").text());
  this.startTime.setSeconds($startTime.find("second").text());

  // accumulation
  var acc = 0;

  // Populate deltas of each item 
  for (var i = 0; i < this.$data.children().length; i ++) {
    
    // item children
    var item = this.$data.children()[i];

    // if not starttime element
    if (item.nodeName.toLowerCase() != "starttime") {

      // set delta
      item.delta = item.delta || 0;
      item.i = i;
      item.duration = parseInt(item.querySelector("duration").textContent); 
      
      item.delta += (acc + item.duration);
      acc = item.delta;
    }
  }

  //
  this.getItem();
};