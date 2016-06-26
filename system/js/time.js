// BaseObject
// It is the base object derived by other objects below it
BaseObject = function() {
  this.element = $("");
}

// AppletsArea object
// This is the clock object on the right bottom of the screen
AppletsArea = function() {
  this.element = $("#panel-applets");

  // Get the reference of panel-applets-invisible style from the css
  // Because we want to modify the transition3d according to the height of the area
  for (var i = 0; i < document.styleSheets.length; i++) {
    // Get the sheet 
    var sheet = document.styleSheets[i];
    if (sheet.rules) {
      // If there are rules in the sheet, find the .panel-applets-invisible rules
      for (var j = 0; j < sheet.rules.length; j ++) {
        if (sheet.rules[j].selectorText == ".panel-applets-invisible") {
          // Keep the reference in the this.rules
          this.rules = sheet.rules[j];
        }
      }
    }
  }
}

AppletsArea.prototype = new BaseObject();
AppletsArea.prototype.updateHeight = function() {
  // Adjust top coordinate according to the height of the panel
  var panelHeight = $("#panel").height();
  this.element.css("top", panelHeight + "px");

  // Adjust element's translate3d according to the element's height
  var myHeight = this.element.height();
  // Modify the style pointed by this.rules we got in the constructor above
  this.rules.style.webkitTransform = "translate3d(0, -" + myHeight + "px, 0)";
}

// Clock object
// This is the clock object on the right bottom of the screen
Clock = function() {
  this.element = $("#clock");
  this.update();
}

Clock.prototype = new BaseObject();

Clock.prototype.update = function() {
  var self = this;
  var now = new Date();

  // TODO: i18n
  $("#clock-time").text(moment(now).format("HH:mm"));
  $("#clock-date").text(moment(now).format("ddd, DD MMMM YYYY"));
  setTimeout(function() {
    self.update();
  }, 1000);
}

// The actual instances
var appletsArea,
    clock;

$(document).ready(function() {
  appletsArea = new AppletsArea();
  clock = new Clock();

  //setupEvents();
});
