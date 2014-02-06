
// handlers
window.handle = {
  transition : null,
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
  this.file = file;
  this.load();
};

XmlBackground.prototype.load = function() {
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

  while (i > 0) {

    var item = this.$data.children()[i];

    if (item.nodeName.toLowerCase() != "starttime" && delta >= item.delta ) {

      console.log(item.nodeName.toLowerCase());
      self.handleItem (item);

      var hasNext = i < (this.$data.children().length - 1);
      var nextItem;
      var when = 0;

      if (hasNext) {
        // get next item
        nextItem = this.$data.children()[ i + 1];
        when = Math.ceil(nextItem.delta - delta);
      } 

      if (nextItem && when) {

        if (window.handle.timeout) {
          clearTimeout(window.handle.timeout);  
        }
        
        window.handle.timeout = setTimeout(function(){
          self.getItem();
        }, when * 1000);

        if (item.nodeName.toLowerCase() == "transition") {

          self.transitionDuration = when;
          self.transitionCounter = when;

          if (window.handle.transition) {
            clearInterval(window.handle.transition);
          }

          window.handle.transition = setInterval (function (){
            var percentage = (self.transitionCounter + 0.0) / self.transitionDuration;

            // set opacity
            $("#bg").css("opacity", 1 - percentage);
            $("#overlay").css("opacity", percentage);

            self.transitionCounter--;

          }, 1000);

        }
      }
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

    $("#bg").css("opacity", 0.0);
    $("#bg").css("background-image", "url(" + file + ")");

    $("#overlay").css("opacity", 1.0);
    $("#overlay").css("background-image", "url(" + overlay + ")");

  }
}

XmlBackground.prototype.reset = function() {

  if (window.handle.timeout) {
    clearTimeout(window.handle.timeout);
  }
  
  if (window.handle.transition) {
    clearInterval(window.handle.transition);
  }

  $("#overlay").css("opacity", 0.0);
  $("#bg").css("opacity", 1.0);

}

XmlBackground.prototype.run = function() {
  var $startTime = this.$data.find("starttime");
  this.startTime = new Date();
  this.startTime.setHours($startTime.find("hour").text());
  this.startTime.setMinutes($startTime.find("minute").text());
  this.startTime.setSeconds($startTime.find("second").text());


  var acc = 0;
  /* Populate deltas of each item */
  for (var i = 0; i < this.$data.children().length; i ++) {
    var item = this.$data.children()[i];
    item.delta = item.delta || 0;
    item.i = i;

    if (item.nodeName.toLowerCase() != "starttime") {
      item.duration = parseInt(item.querySelector("duration").textContent); 
      item.delta += (acc + item.duration);
      acc = item.delta;
    }
  }

  this.getItem();
};