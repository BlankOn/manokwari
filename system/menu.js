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
}

function FavoritesData() {
    this.backend = new Favorites();
    this.data = this.backend.update();
    this.dataReady = true;
}
inherit(FavoritesData, MenuData);
FavoritesData.prototype.constructor = FavoritesData;

FavoritesData.prototype.update = function() {
    this.dataReady = false;
    this.data = this.backend.update();
    this.emit(DataChanged);
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

function PlacesData() {
    this.backend = new Places();
    this.data = this.backend.update();
    this.dataReady = true;
}
inherit(PlacesData, MenuData);
PlacesData.prototype.constructor = PlacesData;

PlacesData.prototype.update = function() {
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
    this.type = "plain";
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
    if (this.type == "plain") {
        this.render_plain();
    } else {
        this.render_collapsible();
    }
}

MenuList.prototype.render_plain = function() {
    $(this.element).empty();

    if (this.data.data === undefined) {
        console.log("Data is not connected in the model");
    }


    for (var i = 0; i < this.data.data.length; i ++) {
        var entry = this.data.data[i];
        if (entry.isHeader == true) {
            var $li  = $("<li>", { 
                        "data-icon": "false",
                        "text": entry.name
                    }
                );
            $(this.element).append($li);
        } else {
            var desktop = entry.desktop;
            var name = entry.name;
            var $li  = $("<li>", { "data-icon": "false" });
            var $a   = $("<a/>", {
                            "id" : "desktop_" + this.element.replace("#", "") + "_"+ i,
                            "href": "#",
                            "desktop": desktop,
                            "text": name
                        }).bind("tap", function (event, ui) {
                            Utils.run_desktop($(this).attr("desktop"));
                        }).bind("taphold", function (event, ui) {
                            $("#remove_from_favorites_button").attr("desktop", $(this).attr("desktop"));
                            $("#remove_from_fav_caption").text($(this).text());
                            $.mobile.changePage($("#remove_from_favorites"), {
                                role: "dialog",
                                transition: "fade"
                            });
                        });
            var $img = $("<img/>", {
                            "width": 24,
                            "height": 24,
                            "src": entry.icon,
                            "class": "ui-li-icon ui-li-thumb"
                        });
            $(this.element).append($li);
            $li.append($a);
            $a.append($img);
        }
    }
    $(this.element).listview("refresh");
}

MenuList.prototype.render_collapsible = function() {
    $(this.element).empty();

    if (this.data.data === undefined) {
        console.log("Data is not connected in the model");
    }

    for (var j = 0; j < this.data.data.length; j ++) {
        var entry = this.data.data[j];
        var div = $("<div/>", {
                     "data-role": "collapsible",
                     "data-iconpos": "right"
                   });
        var h3  = $("<h3/>", {
                     "text": entry.name
                   });
        var img = $("<img/>", {
                     "width": 24,
                     "height": 24,
                     "src": entry.icon,
                   });

        div.append(h3);
        $(this.element).append(div);

        if (typeof entry.children != "undefined") {
            var group = $('<div/>', {
                    "data-role": "controlgroup"
                   });
                   
            div.append(group);
            for (var i = 0; i < entry.children.length; i ++) {
                var desktop = entry.children[i].desktop;
                var name = entry.children[i].name;
                var a   = $("<a/>", {
                                "id" : "desktop_" + this.element.replace("#", "") + "_"+ i,
                                "href": "#",
                                "data-role": "button",
                                "desktop": desktop,
                                "class": "ui-btn-xdg-menu"
                            }).bind("tap", function (event, ui) {
                                Utils.run_desktop($(this).attr("desktop"));
                            }).bind("taphold", function (event, ui) {
                                $("#add_to_favorites").attr("desktop", $(this).attr("desktop"));
                                $("#add_to_desktop").attr("desktop", $(this).attr("desktop"));
                                $("#add_to_fav_or_desktop_caption").text($(this).text());
                                $.mobile.changePage($("#add_to_fav_or_desktop"), {
                                    role: "dialog",
                                    transition: "fade"
                                });
                            });
                var img = $("<img/>", {
                                "width": 24,
                                "height": 24,
                                "class": "ui-btn-xdg-menu-icon",
                                "src": entry.children[i].icon
                            });
                var span = $("<span/>", {
                                "text": name,
                                "title": name
                            });
                a.append(img);
                a.append(span);
                group.append(a);
            }
        } 
    }
    //+ ":" + document.getElementById("listApplications").outerHTML);
    $(this.element).trigger('create')
}

var dataApplications = new XdgData("applications.menu");
dataApplications.backend.updateCallback("dataApplications.update()");
var dataFavorites = new FavoritesData();
dataFavorites.backend.updateCallback("dataFavorites.update()");

var dataPlaces = new PlacesData();
dataPlaces.backend.updateCallback("dataPlaces.update()");

$(document).ready(function() {
    var xdg = new MenuList(dataApplications);
    xdg.type = "collapsible";
    xdg.attach("listApplications");

    var fav = new MenuList(dataFavorites);
    fav.attach("listFavorites");

    var places = new MenuList(dataPlaces);
    places.attach("listPlaces");

    $("#add_to_desktop").bind("tap", function (event, ui) {
        XdgDataBackEnd.put_to_desktop($(this).attr("desktop"));
    });

    $("#add_to_favorites").bind("tap", function (event, ui) {
        Favorites.add($(this).attr("desktop"));
    });

    $("#remove_from_favorites_button").bind("tap", function (event, ui) {
        Favorites.remove($(this).attr("desktop"));
    });


});

function updateData(d) {
    d.update();
}

function reset() {
    $.mobile.changePage($("#first"), {
        transition: "none"
    });
    $('div.ui-collapsible-content').addClass('ui-collapsible-content-collapsed');
}




