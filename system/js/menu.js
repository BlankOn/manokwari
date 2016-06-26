
var userAccountIsSetup = false;
var UserAccount = UserAccount || (function() {
    return {
        getIconFile: function() { return "user-icon.png" },
        getRealName: function() { return "Atias Wanggai" },
        getHostName: function() { return "manokwari" }
    }
});

var XdgDataBackEnd = XdgDataBackEnd || (function() {
    return {
        update: function() {
            return {

            }
        },
        updateCallback: function() {}
    }
});

var Places = Places || (function() {
    return {
        update: function() {
            return {

            }
        },
        updateCallback: function() {}
    }
});

var Utils = Utils || (function () {
    return {
        getIconPath: function() {},
        translate: function(e) { return e }
    }
})();


var SessionManager = SessionManager || (function() {
    return {
        canShutdown: function() { return false },
        logout: function() { return false },
        reboot: function() { return false },
        shutdown: function() { return false },
    }
});

var inherit = function() {
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

var EventClass = function() {
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


var menu = (function() {
    var DataChanged = 1;
    var activePage = null;
    var activePopup = null;
    var userAccount = new UserAccount();


    var MenuData = function() {
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


    var XdgData = function(name) {
        this.name = name;
        this.backend = new XdgDataBackEnd(name);
        this.data = this.backend.update();
        this.dataReady = true;
    }
    inherit(XdgData, MenuData);
    XdgData.prototype.constructor = XdgData;

    XdgData.prototype.update = function() {
        this.data = null;
        this.dataReady = false;
        this.data = this.backend.update();
        this.emit(DataChanged);
        this.dataReady = true;
    }

    var PlacesData = function() {
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
    var MenuList = function(data) {
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

    MenuList.prototype.handle_tap = function(event) {
        var desktop = event.data.desktop;
        var uri = event.data.uri;
        var command = event.data.command;

        if (typeof uri !== "undefined") {
            Utils.open_uri(uri);
        } else if (typeof desktop !== "undefined"){
            Utils.run_desktop(desktop);
        } else if (typeof command !== "undefined") {
            Utils.run_command(command);
        }
    }

    MenuList.prototype.handle_tap_hold = function(event) {
        var text = event.data.text;
        var desktop = event.data.desktop;
        var uri = event.data.uri;
        var command = event.data.command;

        // HACK
        var in_favorites = (typeof uri === "undefined") && (typeof command === "undefined");
        if (in_favorites) {
            $("#remove_from_favorites_button").attr("desktop", desktop);
            $("#remove_from_fav_caption").text(text);

            var popup = $("#remove_from_favorites");
            popup.appendTo($(this).parent());
            showPopup(popup);
        }
    }

    MenuList.prototype.handle_tap_hold_applications = function(event) {
        var text = event.data.text;
        var desktop = event.data.desktop;
        var uri = event.data.uri;
        var command = event.data.command;

        $("#add_to_favorites").attr("desktop", desktop);
        $("#add_to_desktop").attr("desktop", desktop);
        $("#add_to_fav_or_desktop_caption").text(text);

        var popup = $("#add_to_fav_or_desktop");
        popup.appendTo($(this).parent());
        showPopup(popup);

    }

    MenuList.prototype.render_plain = function() {
        $(this.element).empty();

        if (this.data.data === undefined) {
            console.log("Data is not connected in the model");
        }


        for (var i = 0; i < this.data.data.length; i ++) {
            var entry = this.data.data[i];
            if (entry.isHeader == true) {
                var li  = $("<div>", { 
                            "data-icon": "false",
                            "data-role": "header",
                            "text": entry.name
                        }
                    );
                $(this.element).append(li);
            } else {
                var desktop = entry.desktop;
                var name = entry.name;
                var uri = entry.uri;
                var command = entry.command;
                var a   = $("<a/>", {
                                "id" : "desktop_" + this.element.replace("#", "") + "_"+ i,
                                "href": "#",
                                "desktop": desktop,
                                "uri": uri,
                                "command": command
                            });
                a.on("taphold", { "text": a.text(), "uri": uri, "desktop": desktop, "command": command }, MenuList.prototype.handle_tap_hold);
                a.on("tap", { "uri": uri, "desktop": desktop, "command": command }, MenuList.prototype.handle_tap);
                var img = $("<img/>", {
                                "width": 22,
                                "height": 22,
                                "src": entry.icon,
                                "class": "ui-listview-item-icon"
                            });

                var span = $("<span/>", {
                                "translate": "no",
                                "text": name,
                                "title": name,
                                "class": "ui-listview-item-text"
                            });

                $(this.element).append(a);
                a.append(img);
                a.append(span);
            }
        }

        refreshStyle($(this.element));
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
            var h3  = $("<div/>", {
                         "data-role": "collapsible-header", 
                         "text": entry.name
                       });
            var img = $("<img/>", {
                         "width": 22,
                         "height": 22,
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
                    var uri = entry.children[i].uri;
                    var command = entry.children[i].command;
                    var a   = $("<a/>", {
                                    "id" : "desktop_" + this.element.replace("#", "") + "_"+ i,
                                    "href": "#",
                                    "desktop": desktop
                                });

                    a.on("taphold", { "text": a.text(), "uri": uri, "desktop": desktop, "command": command }, MenuList.prototype.handle_tap_hold_applications);
                    a.on("right-click", { "text": a.text(), "uri": uri, "desktop": desktop, "command": command }, MenuList.prototype.handle_tap_hold_applications);
                    a.on("tap", { "uri": uri, "desktop": desktop, "command": command }, MenuList.prototype.handle_tap);

                    var img = $("<img/>", {
                                    "width": 22,
                                    "height": 22,
                                    "class": "ui-listview-item-icon",
                                    "src": entry.children[i].icon
                                });
                    var span = $("<span/>", {
                                    "translate": "no",
                                    "text": name,
                                    "title": name
                                });
                    a.append(img);
                    a.append(span);
                    group.append(a);
                }
            } 
        }
        refreshStyle($(this.element));
    }





    var dataApplications = new XdgData("manokwari-applications.menu");
    dataApplications.backend.updateCallback("menu.update()");

    var dataPlaces = new PlacesData();
    dataPlaces.backend.updateCallback("dataPlaces.update()");

    var sessionManager = new SessionManager();

    var init = function() {
        var xdg = new MenuList(dataApplications);
        xdg.type = "collapsible";
        xdg.attach("listApplications");
        xdg.attach("listSearch");
        


        var places = new MenuList(dataPlaces);
        places.attach("listPlaces");

        setup();
    }

    // Shows the specified popup
    var showPopup = function(id) {
        var recalc = false;
        recalc = (id.css('display') != "none");

        id.css("height", "inherit");
        id.show();
        activePopup = id;
        if (recalc) {
            var g = $(".ui-collapsible-control-group:visible");
            var h = g.height();
            $(".ui-collapsible-control-group:visible").height(h + id.height());
        }
    }

    // Hides the specified popup
    var hidePopup = function(id) {
        if (typeof id === "undefined") {
            id = $("div[data-role='popup']");
        }
        var id_height = id.height();
        id.height(0); 
        // move the popup to the popup-pool
        $("#popup-pool").append(id.detach());
        activePopup = null;
        var g = $(".ui-collapsible-control-group:visible");
        var h = g.height();
        $(".ui-collapsible-control-group:visible").height(h - id_height);
    }

    var prepareShow = function() {
        setupUserAccount();
        $("#first").css("left", "0px");
    }

    var prepareHide = function() {
        changePage($("#first"), {
            transition: "none"
        });
        hidePopup();
        $("#first").addClass("ui-animation-slide");
        var e = $("#userAccount");
        e.css("bottom", -e.height());
        $("#first").css("left", "-" + window.outerWidth + "px");
    }


    // Setup visibility of an object depending
    // on the result of the function defined
    // in the data-visibility attribute of the
    // object.
    // Not visible means that the object is removed
    // completely from the DOM as this is expected
    // that the objects are static.
    var setupObjectVisibility = function() {
        var f = $(this).attr("data-visibility");
        if (typeof window[f] === "function") {
            var r = window[f]();
            // remove if the function return false
            if (r != true) {
                $(this).remove();
            }
        }
    }

    var setupPages = function() {
        $('div[data-role="page"]').hide();
        $('div[data-role="page"]').first().show();

        // Setup visibility of the objects in the pages
        $('[data-visibility]').each(setupObjectVisibility);

        refreshStyle("#listGeneral");

    }

    var setupUserAccount = function() {

        var e = $("#userAccount");
        e.css("bottom", "0px");
        e.find("img").attr("src", userAccount.getIconFile());
        e.find("h1").text(userAccount.getRealName());
        e.find("span").text(userAccount.getHostName());

        if (userAccountIsSetup) 
            return;

        e.on("click", function() {
            Utils.run_desktop("/usr/share/applications/gnome-user-accounts-panel.desktop");
        });
        userAccountIsSetup = true;
    }

    var linkHandleTapHold = function(e, target) {
        // if the button is still pressed
        // until 1100 ms later then this is
        // truely a tap and hold gesture
        if (target.attr("mouse-is-down") == "true") {
            target.trigger("taphold");
        }
        // reset all values
        target.attr("mouse-is-down", "false");
        target.attr("mouse-down-time", -1);
    }

    var linkHandleClick = function(e) {
        // just ignore clicks
        e.preventDefault();
        e.stopPropagation();

        var f = $(this).attr("data-tap-handler");
        if (typeof f === "undefined") {
            var f = $(this).children().attr("data-tap-handler");

            // only call the function if it is a _public_ function
            if (typeof window.menu[f] === "function") {
                window.menu[f]();
            }
        }

    }

    var linkHandleMouseDown = function(e) {
        e.stopPropagation();
        e.preventDefault();

        var target = $(this);
        if (!$(this).is("A")) {
            target = $(e.target).find("a").first();
            if (target.length == 0) { // nothing in the children
                // Let's go upwards
                target = $(e.target).parents("a").first();
            }
        }
        if (target.length == 0) {
            console.log("No <A> element found");
            return;
        }

        var currentTime = new Date().getTime();

        // ignore if the button is already pressed
        if (target.attr("mouse-is-down") ==  true) {
            return;
        }

        // take note that this button is now pressed
        target.attr("mouse-is-down", "true");
        // also put the timestamp so we can distinguish
        // later whether this is a long tap or not
        target.attr("mouse-down-time", currentTime);
        // kick the tap hold detector
        setTimeout(linkHandleTapHold, 1100, e, target);
    }

    var linkHandleMouseUp = function(e) {
        e.stopPropagation();
        e.preventDefault();

        var target = $(this);
        if (!$(this).is("A")) {
            target = $(e.target).find("a").first();
            if (target.length == 0) { // nothing in the children
                // Let's go upwards
                target = $(e.target).parents("a").first();
            }
        }
        if (target.length == 0) {
            console.log("No <A> element found");
            return;
        }


        // only consider the button which was pressed 
        if (target.attr("mouse-is-down") == "true") {
            var currentTime = new Date().getTime();
            var lastTime = target.attr("mouse-down-time");
            if (typeof lastTime != "undefined" && (currentTime - lastTime < 1000)) {

                var cancel = false;
                if (activePopup != null) {
                    // Cancel if the button is not inside the activePopup
                    if (activePopup.find("#" + target.attr("id")).length == 0) {
                        cancel = true;
                    }
                    // hide the popup in all cases
                    hidePopup(activePopup);
                } 

                // only eat the event when it's not canceled
                if (cancel == false) {
                    // Just change if the href contains a page name
                    if (target.attr("href") != "#") {
                        changePage($(target.attr("href")));
                    } else {
                    // or emit the "tap" or "right-click" signal
                    // depending on the click button source
                        if (e.which == 3) {
                            target.trigger("right-click");
                        } else {
                            target.trigger("tap");
                        }
                    }
                }

            }
            // reset the "down" state after finishing
            // meaning that the button's job is "done"
            target.attr("mouse-is-down", false);
        }
    }

    var setup = function() {
        setupPages();
        setupBasicStyle();
        setupAdditionalStyle();
        setupPopupButtons();
        translate();
        $("body").keydown(handleKeyDown);
        setupUserAccount();
    }

    var setupPopupButtons = function() {
        $("#add_to_desktop").on("tap", function(event, ui) {
            XdgDataBackEnd.put_to_desktop($(this).attr("desktop"));
        });
    }

    // Handles Settings button. The function is defined
    // in data-handler attribute of the button
    var handleSettings = function() {
        Utils.run_command("gnome-control-center");
    }

// Handles Lock Screen button. The function is defined
    // in data-handler attribute of the button
    var handleLockScreen = function() {
        Utils.run_command("gnome-screensaver-command -l");
    }

    // Handles LogOut button. The function is defined
    // in data-handler attribute of the button
    var handleLogOut = function() {
         sessionManager.logout(); 					//Utils.run_command("gnome-session-quit --logout");
    }

	// Handles Reboot button. The function is defined
    // in data-handler attribute of the button
    var handleReboot = function() {
         sessionManager.reboot();					//Utils.run_command("gnome-session-quit --reboot");
    }

    // Handles ShutDown button. The function is defined
    // in data-handler attribute of the button
    var handleShutDown = function() {
         sessionManager.shutdown(); 				//Utils.run_command("gnome-session-quit --power-off");  
    }

    // Determine whether shutdown is enabled or not.
    // This controls the visibility of element which
    // specify the function name 
    // in data-visibility attribute of the button
    // Returns bool
    var shutdownEnabled = function() {
        return sessionManager.canShutdown();
    }

    // Changes the page to the specifed page
    // when back button is pressed
    var handleBackButton = function(e) {
        changePage($("#" + e.data.destination));
    }

    // Changes to page to the specified page
    var changePage = function(page) {
        if (typeof page === "undefined" || page.length == 0) {
            console.log("The specified page is invalid");
            return;
        }

        var cg = $(".ui-collapsible-control-group");
        cg.hide();
        cg.parent().find(".ui-expandable-icon").removeClass("ui-expandable-icon-expanded")

        var withAnimation = true;

        if (arguments.length == 2) {
            withAnimation = (arguments[1].transition != "none");
        }
        var width = window.outerWidth;

        if (activePage == null) {
            activePage = $("#first");
            activePage.addClass("ui-animation-slide");
        }

        if (activePage == page) {
            console.log("Trying to change to same page, exiting.");
            return;
        }

        var h = page.find("div[data-role='header']").first();
        if (h.attr("data-add-back-btn") == "true" &&
            h.attr("back-btn-added") != "true") {
            // Create the back button when requested
            var b = $("<div>", {
                "class": "ui-back-button"
            });
            // handle the click
            b.click({ destination: activePage.attr("id") }, handleBackButton);
            // insert the button in the header
            h.prepend(b);
            // take a note to avoid duplicates
            h.attr("back-btn-added", "true");
        }

        page.show();
        if (withAnimation == false) {
            activePage.removeClass("ui-animation-slide");
        }
        page.removeClass("ui-animation-slide");

        if (page.attr("id") == "first") {
            console.log("going to first");
            // we're coming to first page
            // so the incoming must come from -width 
            if (withAnimation) {
                page.css("left", "-" + width + "px");
            }
            // and outgoing should come from +width
            activePage.css("left", width + "px");
        } else {
            console.log("going away from first");
            // we're moving away from first page
            // so the incoming must come from +width
            if (withAnimation) {
                page.css("left", width + "px");
            }
            page.css("left"); // XXX without this
                              // animation fails in the first time
            // and outgoing (#first) must go to -width
            activePage.css("left", "-" + width + "px");
        }

        if (withAnimation) {
            page.addClass("ui-animation-slide");
        }
        page.css("left", "0px");
        activePage = page;
    }


    var setupBasicStyle = function() {
        $('body').addClass("ui-mobile-viewport");
        $('a').addClass("ui-link");
    }

    var setupAdditionalStyle = function() {
        $('a[data-role="button"]').addClass("ui-button");
        $('div[data-role="page"]').addClass("ui-page");
        $('div[data-role="header"]').addClass("ui-header");
        $('div[data-role="content"]').addClass("ui-content");

        $("[data-role='popup']").addClass("ui-popup");
    }

    var toggleCollapsible = function(e) {
        var g = $(this).parent().find(".ui-collapsible-control-group");
        if (g.css('display') == "none") {
            var shown = $(this).parent().parent().find(".ui-collapsible-control-group:visible").hide();
            shown.parent().find(".ui-expandable-icon").removeClass("ui-expandable-icon-expanded")
            g.show();
            var h = g.height();
            if (h == 0) {
                g.css("height", "auto");
                h = g.height();
            }
            g.height(h);
            g.parent().find(".ui-expandable-icon").addClass("ui-expandable-icon-expanded")
        } else {
            g.height(0);
            g.hide();
            g.parent().find(".ui-expandable-icon").removeClass("ui-expandable-icon-expanded")
        }
    }

    // Refresh styles of the specified jQuery object 
    var refreshStyle = function(e) {
        if (typeof e.attr === "undefined") {
            e = $(e);
        }

        switch (e.attr("data-role")) {
            case "listview":    {
                // Specify the style for listview
                e.addClass("ui-listview");
                // Wrap the button with a listview item
                e.find("a").wrap("<div class=ui-listview-item/>");
                e.children().first().addClass("ui-listview-first-child");
                e.children().last().addClass("ui-listview-last-child");
                e.find("span").addClass("ui-listview-item-text");
                e.find("div[data-role='header']").addClass("ui-listview-header").removeClass("ui-header");

                for (var i = 0; i < e.length; i ++) {
                    console.log(e[i].outerHTML);
                }
                break;
            }

            case "collapsible-set": {
                // Specify the style for the control group and
                // the inner collapsibles
                e.find("div[data-role='controlgroup']").addClass("ui-collapsible-control-group");
                e.find("div[data-role='collapsible']").addClass("ui-collapsible");
                // Hide all control group initially
                e.find(".ui-collapsible-control-group").hide();

                var c = e.find(".ui-collapsible");
                // Wrap the button inside collapsible with
                // a listview item
                c.find("a").wrap("<div class=ui-listview-item/>");
                var l = c.find(".ui-listview-item:first-child");
                l.addClass("ui-listview-first-child");
                l = c.find(".ui-listview-item:last-child");
                l.addClass("ui-listview-last-child");

                // Find the header inside inner collapsible
                var h = c.find("div[data-role='collapsible-header']");
                // specify the header style to it
                h.addClass("ui-collapsible-header");
                // handle the click event
                h.click(toggleCollapsible);
                // Give different styles for top and bottom items
                h.first().addClass("ui-collapsible-header-top");
                h.last().addClass("ui-collapsible-header-bottom");
                h.append("<div class='ui-expandable-icon'></div>");
                //more icons left collapsible
                h.append("<div class='ui-collapsible-icon'></div>");
                break;
                
                
            }
				
				case "listview-search":    {
                  // Specify the style for listview
                e.addClass("ui-listview");
                // Wrap the button with a listview item
                e.find("a").wrap("<div class=ui-listview-item/>");
                e.find("div").removeClass("ui-listview-first-child").removeClass("ui-listview-last-child");
                e.find("div[data-role='header']").removeClass("ui-header");
                e.find(".ui-listview-item").slideUp().hide();
                e.find("div[data-role='controlgroup']").unwrap("div[data-role='collapsible']");
                e.find(".ui-listview-item").unwrap("div[data-role='controlgroup']");
                e.find("div[data-role='collapsible-header']").remove();

                for (var i = 0; i < e.length; i ++) {
                    console.log(e[i].outerHTML);
                }
                break;
            }
        }

        e.on("mousedown", ".ui-listview-item", linkHandleMouseDown);
        e.on("mouseup", ".ui-listview-item", linkHandleMouseUp);
        e.on("click", ".ui-listview-item", linkHandleClick);

        setupBasicStyle();
    }

    // Calls the gettext function defined in backend
    var gettext = function(text) {
        return Utils.translate(text);
    }

    // Translates all <span> element which has
    // translate attribute set to "yes" (if not given
    // then considered as "yes")
    var translate = function() {
        $("span[translate!='no']").text(function(index, text) {
            $(this).text(gettext(text));
        });
    }

    // Handles keydown
    var handleKeyDown = function(e) {
        switch (e.keyCode) {
        }
    }

    // Handles esc key
    // This is called by the backend
    var handleEsc = function(e) {
        // First try to hide active popup
        if (activePopup != null) {
            hidePopup(activePopup);
            return true;
        }

        // then collapsible
        var activeCollapsible = $(".ui-collapsible-control-group:visible");
        if (activeCollapsible.length > 0) {
            activeCollapsible.hide();
            return true;
        }

        // then return page to first
        if (activePage != null) {
            if (activePage.attr("id") != "first") {
                changePage($("#first"));
                return true;
            }
        }
        return false; // Not handled
    }

    var update = function() {
        dataApplications.update();
    }

    return {
        init: init,
        handleEsc: handleEsc,
        handleSettings: handleSettings,
        handleLockScreen: handleLockScreen,
        handleLogOut: handleLogOut,
        handleReboot: handleReboot,
        handleShutDown: handleShutDown,
        prepareHide: prepareHide,
        prepareShow: prepareShow,
        update: update
    }
})();

$(document).ready(function() {
    menu.init ();
});
