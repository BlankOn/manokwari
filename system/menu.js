var X = [
    { 
        icon: "/usr/share/icons/BlankOn/categories/scalable/gnome-system.svg",
        name: "Graphics",
        children: [
            {
                icon: "/usr/share/icons/hicolor/48x48/apps/gimp.png",
                name: "Gimp Image Editor"
            },
            {
                icon: "/usr/share/icons/hicolor/48x48/apps/inkscape.png",
                name: "Editor Grafis Inkscape"
            },
            {
                icon: "/usr/share/icons/hicolor/48x48/apps/libreoffice-draw.png",
                name: "Libre Office Draw"
            },
            {
                icon: "/usr/share/icons/BlankOn/apps/scalable/shotwell.svg",
                name: "Shotwell Photo Manager"
            },
            {
                icon: "/usr/share/icons/BlankOn/devices/scalable/scanner.svg",
                name: "Simple Scan"
            }
        ]
     }
];


var DataChanged = 1;


function inherit() {
    var superclasses = [];

    if (arguments.length < 2) {
        throw new Error("At least one object must be specified to be inherited from another");
    }

    var copyProto = function(subclass, superclass) {
        for (var f in superclass.prototype) {
            if (f != "constructor" ) {
                if (subclass.prototype[f] == undefined) {
                    subclass.prototype[f] = function() {
                        return superclass.prototype[f].apply(this, arguments);
                    }
                }
            }
        }
    }

    var subclass   = arguments[0];
    var superclass = arguments[1];
    var t = function() {};
    t.prototype = superclass.prototype;
    subclass.prototype = new t();
    subclass.prototype.constructor = subclass;
    subclass.superclass = superclass.prototype;

    /* Copy all super classes functions */
    for (var i = 2; i < arguments.length; i ++) {
        copyProto(subclass, arguments[i]);
    }
}

function EventClass() {
    this.connections = {};
}

EventClass.prototype.constructor = EventClass;
EventClass.prototype.connect = function(type, obj, callback) {
    if (typeof this.connections == "undefined") {
        this.connections = {};
    }

    if (typeof this.connections[type] == "undefined") {
        this.connections[type] = [];
    }
    var c = { obj: obj, callback: callback }
    this.connections[type].push(c);
}

EventClass.prototype.emit = function(event) {
    // Just return if the connections are note yet established
    if (typeof this.connections == "undefined") {
        return; 
    }

    if (typeof event == "number") {
        event = { type: event, target: this };
    }
    if (this.connections[event.type] instanceof Array) {
        for (var i = 0; i < this.connections[event.type].length; i ++) {
            var c = this.connections[event.type][i];
            c.callback.call(c.obj, event);
        }
    }
}


function MenuData() {
    this.data = {};
    this.update();
}
inherit(MenuData, EventClass);

MenuData.prototype.set = function(value) {
    this.update();
    this.emit(DataChanged);
}

MenuData.prototype.constructor = MenuData;

MenuData.prototype.update = function() {
    this.data = X;
    this.dataReady = true;
}

function XdgData(name) {
    this.name = name;
    this.backend = new XdgDataBackEnd(name);
    this.data = this.backend.update();
    this.dataReady = true;
}
inherit(XdgData, MenuData);
XdgData.prototype.constructor = XdgData;

XdgData.prototype.update = function() {
    this.dataReady = false;
    this.data = this.backend.update();
    this.emit(DataChanged);
    this.dataReady = true;
}


/* MenuList */
function MenuList(data) {
    if (!(data instanceof MenuData)) {
        throw new Error("MenuList requires an MenuData to be attached");
    }
    this.data = data;
}
MenuList.prototype.constructor = MenuList;

MenuList.prototype.dataChanged = function(event) {
    console.log("dataChanged: " + this.element);
    this.render();
}

MenuList.prototype.attach = function(id) {
    var e = $("#" + id); 
    if (e.length == 0) {
        throw new Error("MenuList can't be attached to non-existence element");
    }
    this.element = "#" + id;
    this.data.connect(DataChanged, this, this.dataChanged); 
    if (this.data.dataReady) {
        this.render();
    }
}

MenuList.prototype.render = function() {
    $(this.element).empty();

    if (this.data.data === undefined) {
        console.log("Data is not connected in the model");
    }

    for (var j = 0; j < this.data.data.length; j ++) {
        var entry = this.data.data[j];
        var $div = $("<div/>", {
                     "data-role": "collapsible",
                     "data-iconpos": "right"
                   });
        var $h3  = $("<h3/>", {
                     "text": entry.name
                   });
        var $img = $("<img/>", {
                     "width": 24,
                     "height": 24,
                     "src": entry.icon,
                   });

        $div.append($h3);
        $(this.element).append($div);

        if (typeof entry.children != "undefined") {
            $ul = $("<ul/>", {
                    "data-role": "listview"
                   });
            for (var i = 0; i < entry.children.length; i ++) {
                var desktop = entry.children[i].desktop;
                var $li  = $("<li/>", { "data-icon": "false" });
                var $a   = $("<a/>", {
                                "id" : "desktop_" + i,
                                "href": "",
                                "desktop": desktop,
                                "text": entry.children[i].name
                            }).bind("tap", function (event, ui) {
                                Utils.run_desktop($(this).attr("desktop"));
                            });
                var $img = $("<img/>", {
                                "width": 24,
                                "height": 24,
                                "src": entry.children[i].icon,
                                "class": "ui-li-icon ui-li-thumb"
                            });
                $li.append($a);
                $a.append($img);
                $ul.append($li);
            }
            $div.append($ul);
        } 
    }
}

var dataApplications = new XdgData("applications.menu");

$(document).ready(function() {
    var xdg = new MenuList(dataApplications);
    xdg.attach("listApplications");

    console.log($(".ui-mobile-viewport").css('width'));
});

function updateData(d) {
    d.update();
}
