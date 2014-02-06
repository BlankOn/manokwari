var _test = "  \
<background> \
<starttime> \
<year>2011</year> \
<month>11</month> \
<day>24</day> \
<hour>12</hour> \
<minute>54</minute> \
<second>00</second> \
</starttime> \
 \
<!-- This animation will start at 7 AM. --> \
 \
<!-- We start with sunrise at 7 AM. It will remain up for 1 hour. --> \
<static> \
<duration>10.0</duration> \
<file>/Users/diorahman/Experiments/projects/blankon/virtual/temp/themes/Adwaita/backgrounds/morning.jpg</file> \
</static> \
 \
<!-- Sunrise starts to transition to day at 8 AM. The transition lasts for 5 hours, ending at 1 PM. --> \
<transition type='overlay'> \
<duration>20.0</duration> \
<from>/Users/diorahman/Experiments/projects/blankon/virtual/temp/themes/Adwaita/backgrounds/morning.jpg</from> \
<to>/Users/diorahman/Experiments/projects/blankon/virtual/temp/themes/Adwaita/backgrounds/bright-day.jpg</to> \
</transition> \
 \
<!-- It's 1 PM, we're showing the day image in full force now, for 5 hours ending at 6 PM. --> \
<static> \
<duration>10.0</duration> \
<file>/Users/diorahman/Experiments/projects/blankon/virtual/temp/themes/Adwaita/backgrounds/bright-day.jpg</file> \
</static> \
 \
<!-- It's 7 PM and it's going to start to get darker. This will transition for 6 hours up until midnight. --> \
<transition type='overlay'> \
<duration>20.0</duration> \
<from>/Users/diorahman/Experiments/projects/blankon/virtual/temp/themes/Adwaita/backgrounds/bright-day.jpg</from> \
<to>/Users/diorahman/Experiments/projects/blankon/virtual/temp/themes/Adwaita/backgrounds/good-night.jpg</to> \
</transition> \
 \
<!-- It's midnight. It'll stay dark for 5 hours up until 5 AM. --> \
<static> \
<duration>15.0</duration> \
<file>/Users/diorahman/Experiments/projects/blankon/virtual/temp/themes/Adwaita/backgrounds/good-night.jpg</file> \
</static> \
 \
<!-- It's 5 AM. We'll start transitioning to sunrise for 2 hours up until 7 AM. --> \
<transition type='overlay'> \
<duration>7.0</duration> \
<from>/Users/diorahman/Experiments/projects/blankon/virtual/temp/themes/Adwaita/backgrounds/good-night.jpg</from> \
<to>/Users/diorahman/Experiments/projects/blankon/virtual/temp/themes/Adwaita/backgrounds/morning.jpg</to> \
</transition> \
</background> \
"; 

XmlBackground = function() {
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
      
      // handle item
      self.handleItem (item);

      var hasNext = i < (this.$data.children().length - 1);
      var nextItem;
      var when = 0;

      if (hasNext) {
        // get next item
        nextItem = this.$data.children()[ i + 1];
        when = Math.ceil(nextItem.delta - delta);
      } 

      // set handler
      if (nextItem && when) {

        self.debugCount = when;

        if (self.timeout) {
          clearTimeout(self.timeout);  
        }
        
        // get next state, self.timeout is handler for getting next item
        self.timeout = setTimeout(function(){
console.log("abc");
          self.getItem();
        }, when * 1000);

        if (item.nodeName.toLowerCase() == "transition") {
          
          // when
          self.transitionDuration = when;
          self.transitionCounter = when;

          if (self.transition) {
            clearInterval(self.transition);
          }

          self.transition = setInterval (function (){
            
            // percentage 
            var percentage = (self.transitionCounter + 0.0) / self.transitionDuration;

            // set opacity
            $("#bg").css("opacity", 1 - percentage);
            $("#overlay").css("opacity", percentage);

            self.transitionCounter--;

          }, 1000);
        }
      } else {
        self.debugCount = 0;
      }

      if (self.counter) {
        clearInterval(self.counter);  
      }
      
      // Open following lines to debug
      // start counter for debugging
      /* 
      if (self.debugCount) {
        self.counter = setInterval(
        function(){
          self.debugCount--;
          $("#debug").text(item.nodeName + " - " + i + " count:" + self.debugCount + " seconds");
        }, 1000);
      } else {

        $("#debug").text("");
        clearInterval(self.counter);  

      }*/
      

      break;
    } 
    i--;
  }
}

XmlBackground.prototype.handleItem = function(item) {
  var file;
  $("#overlay").css("display", "block");
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
  if (self.timeout) {
    clearTimeout(self.timeout);
  }
  if (self.transition) {
    clearInterval(self.transition);
  }
  $("#overlay").css("opacity", "0");
  $("#overlay").css("display", "none");
  $("#bg").css("opacity", "1");
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


