var _test = "  \
<background> \
<starttime> \
<year>2011</year> \
<month>11</month> \
<day>24</day> \
<hour>09</hour> \
<minute>03</minute> \
<second>00</second> \
</starttime> \
 \
<!-- This animation will start at 7 AM. --> \
 \
<!-- We start with sunrise at 7 AM. It will remain up for 1 hour. --> \
<static> \
<duration>10.0</duration> \
<file>/usr/share/themes/Adwaita/backgrounds/morning.jpg</file> \
</static> \
 \
<!-- Sunrise starts to transition to day at 8 AM. The transition lasts for 5 hours, ending at 1 PM. --> \
<transition type='overlay'> \
<duration>20.0</duration> \
<from>/usr/share/themes/Adwaita/backgrounds/morning.jpg</from> \
<to>/usr/share/themes/Adwaita/backgrounds/bright-day.jpg</to> \
</transition> \
 \
<!-- It's 1 PM, we're showing the day image in full force now, for 5 hours ending at 6 PM. --> \
<static> \
<duration>10.0</duration> \
<file>/usr/share/themes/Adwaita/backgrounds/bright-day.jpg</file> \
</static> \
 \
<!-- It's 7 PM and it's going to start to get darker. This will transition for 6 hours up until midnight. --> \
<transition type='overlay'> \
<duration>20.0</duration> \
<from>/usr/share/themes/Adwaita/backgrounds/bright-day.jpg</from> \
<to>/usr/share/themes/Adwaita/backgrounds/good-night.jpg</to> \
</transition> \
 \
<!-- It's midnight. It'll stay dark for 5 hours up until 5 AM. --> \
<static> \
<duration>15.0</duration> \
<file>/usr/share/themes/Adwaita/backgrounds/good-night.jpg</file> \
</static> \
 \
<!-- It's 5 AM. We'll start transitioning to sunrise for 2 hours up until 7 AM. --> \
<transition type='overlay'> \
<duration>7.0</duration> \
<from>/usr/share/themes/Adwaita/backgrounds/good-night.jpg</from> \
<to>/usr/share/themes/Adwaita/backgrounds/morning.jpg</to> \
</transition> \
</background> \
"; 

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
    self.$data = $(data).children();
    self.run();
  });
};

XmlBackground.prototype.getItem = function() {
  var acc = 0;
  var i = this.$data.children().length - 1;
  var now = new Date();
  var delta = (now - this.startTime)/1000;
  console.log(this.startTime);
  var lastDelta = 0;
  var self = this;
  while (i > 0) {
    var item = this.$data.children()[i];
    if (item.nodeName != "starttime" && item.delta <= delta) {
      $("#cc").text(item.nodeName + " " + i);
      if (item.nodeName == "transition" && item.delta > 0) {
        if (self.percentageTimer) {
          clearInterval(self.percentageTimer);
        }
        item.count = item.duration;
        self.percentageTimer = setInterval(function() {
          item.count --;
          $("#cc").text(item.nodeName + delta + " " + i + " " + item.count);
          $("#overlay").css("opacity", (item.percentage/item.duration));
          if (item.count <= 0) {
            clearInterval(self.percentageTimer);
          }
        }, 1000);
      } else {
        if (self.percentageTimer) {
          clearInterval(self.percentageTimer);
        }
        item.count = item.duration;
        self.percentageTimer = setInterval(function() {
          item.count --;
          $("#cc").text(item.nodeName + delta + " " + i + " " + item.count);
          if (item.count <= 0) {
            clearInterval(self.percentageTimer);
          }
        }, 1000);

      }
      var when;
      if (lastDelta > 0) {
        when = (delta - item.delta) * 1000;
      } else {
        when = (delta - item.delta) * 1000;
      }
      if (this.timeout) {
        clearTimeout(this.timeout);
      }
      console.log("w:%d", when);
      this.timeout = setTimeout(function() {
        var s = XmlBackground.prototype.instance;
        s.getItem();
      }, when);
      this.handleItem(item);
      lastDelta = item.delta;
      break;
    }
    lastDelta = item.delta;
    i --;
  }
}

XmlBackground.prototype.handleItem = function(item) {
  var file;
  if (item.nodeName == "static") {
    file = item.querySelector("file").textContent;
    $("body").css("background-image", "url(" + file + ")");
  } else {
    overlay = item.querySelector("from").textContent;
    file = item.querySelector("to").textContent;
    $("#overlay").css("background-image", "url(" + file + ")");
    $("body").css("background-image", "url(" + overlay + ")");
  }
  console.log(item.i);
  console.log(file);
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
    if (item.nodeName != "starttime") {
      item.duration = parseInt(item.querySelector("duration").textContent); 
      item.delta += (acc + item.duration);
      acc = item.delta;
    }
  }

  var item = this.getItem();
  console.log(this.$data.children());
};

$(document).ready(function() {
  var x = new XmlBackground();
  var p = $($.parseXML(_test));
  console.log(p);
  x.$data = p.children();
  x.run();
});
