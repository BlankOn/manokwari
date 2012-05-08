# Design of Manokwari

Manokwari is a desktop shell for GNOME 3. It features combined Gtk+ and HTML5 frontend (Gtk+ is legacy here and would be replaced totally with HTML5
in the future). It is an evolution from a shell called blankon-panel. 

## Administrativia
This document includes few marks for developers and readers use.
* [NOT YET IMPLEMENTED] marks the not yet implemented part of the system
* [TODO] marks changes planned in the future
* [FIXME] marks doubts arosed when writing this document.
* [JSCORE] marks interfaces exposed to JSCore
* [SIGNAL] marks signals 
* [PROPERTY] marks properties of an object

## Architecture

Manokwari uses front-end and back-end architecture. The front-end is done mainly with HTML5, JavaScript, and Gtk+ while the back-end is done with Vala.
Communication between front-end and back-end is achieved by exposing back-end as functions accessible through JavaScript via Webkit's JSCore library.

## Goals
Manokwari has a set of goals:
 * Implements a lightweight yet beautiful GNOME desktop shell
 * Provides an easy entry point for newbie developers to contribute 

## Non-goals
Manokwari at its currrent state considers as non-goals:
 * Window manager
 * Compositing manager


However this may change in the future

### Logical view

#### Front-end
##### PanelCalendar
PanelCalendar is a calendar widget displayed in a window. It contains:
 * A month view calendar (Gtk+ stock widget)
 * List of calendar activity [NOT YET IMPLEMENTED]
 * A button, which when pressed will invoke GNOME's date/time control panel applet


    PanelCalendar

##### PanelClock
PanelClock is a widget displaying a clock. It inherits GtkLabel and draws the text manually.

    PanelClock

##### PanelAbstractWindow
PanelAbstractWindow is a base class for all windows used in Manokwari.
It sets several window management hints including:
 * Non-decorated window
 * Non-resizable window
 * Focus on map window
 * Accept on focus
 * Sticky on all workspaces
 * Non-visible in task switcher



    PanelAbstractWindow

    [SIGNAL] screen_size_changed()
        // Emitted when either monitor or screen size is changed
    Protected:
    void set_struts()
        // Reserve part of the screen according to window size and position to be 
        // always visible and not overlapped by any windows.
        // [TODO] This would be moved to PanelWindowHost which is the only place that uses this function

##### PanelDesktop
PanelDesktop is a top level window which hosts the desktop area.  It has DESKTOP window manager hint.

The size is the whole size of the primary monitor resolution. This may not be expected in multi-head setup. [FIXME]

    PanelDesktop

    [SIGNAL] desktop_clicked()
        // Emitted when the desktop area (effectively the Web view) is clicked

##### PanelDesktopHTML
PanelDesktopHTML is a web view embedded in PanelDesktop object. More description about the view 
is described in the "Desktop front end" section.

    PanelDesktopHTML

##### PanelMenuBox
PanelMenuBox is a top level window which hosts the menu. It is hard placed to NORTH-WEST area of the screen.
It has name "_manokwari_menu_" for tracing purposes. The window is invisible (transparent). The visible area
will come from the web view it hosts.

PanelMenuBox listens to the following keys:
 * Escape to close menu
 * PrintScreen to take screen shot [FIXME/TODO] Not working?



    PanelMenuBox

    [SIGNAL] void dismissed()
        // Emitted when menu is dismissed
    [SIGNAL] void shown()
        // Emitted when menu is shown
    [SIGNAL] void about_to_show_content()
        // [TODO] To be removed, not used anymore
    void try_hide()
        // Asks menu to close

##### PanelMenuHTML
PanelMenuHTML is a web view embedded in the PanelMenuBox object. More description about the view
is described in the "Menu front end" section.

    PanelMenuHTML

    void start()
        // Starts menu population
    void triggerShowAnimation()
        // Starts show animation in JavaScript part
    void triggerHideAnimation()
        // Starts hide animation in JavaScript part
    bool handleEsc()
        // Asks JavaScript to handle Escape key
        // Returns false when JavaScript side doesn't handle (which in turns will make PanelMenuBox to close itself)

##### PanelSessionManager
PanelSessionManager is a singleton object to communicate with GNOME session manager. 
It registers manokwari to GNOME in order to established a full desktop shell, otherwise it will be killed by GNOME session manager.

    PanelSessionManager

    void logout()
        // Logouts from the session. [TODO] Will be put as private in the future.
    void shutdown()
        // Shutsdowns the desktop. [TODO] Will be put as private in the future.
    bool can_shutdown()
        // Returns whether the desktop can be shutted down. [TODO] Will be put as private in the future.
    [JSCORE] bool SessionManager.canShutdown()
        // Wrapper to can_shutdown() function above
    [JSCORE] void SessionManager.logout()
        // Wrapper to logout() function above
    [JSCORE] void SessionManager.shutown()
        // Wrapper to shutdown() function above

##### PanelTray
PanelTray is a Gtk+ widget, subclassed from GtkHBox, to display system tray items.
It performs X11 event filtering to implement Freedesktop system tray on it's window which _NET_WM_SYSTEM_TRAY_Sx is associated with it (x being the screen number). The current UI uses horizontal system tray orientation. Whenever a system tray item is added, a GtkSocket is created to host the item and packed to the widget. And when the item is destroyed or removed, the associated socket is also removed from the widget. The widget draws it's own background.

    PanelTray

    [SIGNAL] new_item_added()
        // Emitted when a system tray is added

##### PanelWindowPager
PanelWindowPager is a widget which displays the desktop pager and the "Show desktop" button.
Whenever any of the pager is chosen then the workspace is set to the associated pager.
Whenever the "Show desktop" button is pressed, all visible windows will be minimized showing the desktop uncluttered.
[TODO] This object could be refactored/renamed and moved to separate file.

    PanelWindowPager

    [SIGNAL] void hidden()
        // Emitted when pager is hidden
    void reset_show_desktop()
        // Resets the "show desktop" button, which basically returns the visibility of unchanged windows

##### PanelWindowPagerEntry
PanelWindowPagerEntry hosts PanelWindowPager. This widget handles a mouse press which will toggles the visibility of the pager.
[TODO] This object could be refactored/renamed and moved to separate file.

    PanelWindowPagerEntry
    
    void reset_show_desktop()
        // Ask the pager with the same function name

##### PanelWindowEntry
PanelWindowEntry is a widget showing the icon of the associated window. It acts as proxy to the window. It can maximize, minimize,
and other windowing functions with a menu, accessible with right click on the area. If left-click is given, it toggles between activate and minimize functions.
[TODO] This object could be refactored to separate file.

    PanelWindowEntry

    void show_popup()
        // Shows context menu of common active windowing functions, such as minimize, move, and maximize.

##### PanelWindowEntryDescription
PanelWindowEntryDescription is a window showing the currently hovered icon along with nearby icons of the windows in the window list provided by the window manager. This window shows sliding animation when the mouse is moving in the PanelWindowEntry area.
[TODO] This object could be refactored/renamed and moved to separate file.
[TODO] This object needs to be tested in RTL environment.

    PanelWindowEntryDescription

    void clear_entry()
        // Clears the list which should be drawn
    void activate()
        // Activates the window and showing the list
    void deactivate()
        // Hides the window
    void update_position()
        // Update the position of the window [FIXME] Should be removed?

##### PanelWindowHost
PanelWindowHost is a top level window which shows the horizontal panel on the top of the screen.
This window hosts following objects:
 * An icon showing distributor logo, which when clicked shows the PanelMenuBox
 * PanelWindowPagerEntry
 * PanelWindowEntryDescription
 * PanelTray
 * PanelClock
 * PanelCalendar



[TODO] This object could be refactored/renamed and moved to separate file.

    PanelWindowHost
    
    [SIGNAL] windows_gone(); 
        // Emitted when all windows have gone, either closed or minimized
    [SIGNAL] windows_visible()
        // Emitted when there is at least one window visible
    [SIGNAL] all_windows_visible() 
        // Emitted when all normal windows visible
    [SIGNAL] dialog_opened()
        // Emitted when a dialog is opened
    [SIGNAL] menu_clicked() 
        // Emitted when the menu is clicked
    void no_windows_around()
        // Returns whether no visible windows is visible
    void update()
        // Update the state of the objects associated with window list provided by window manager
    void reposition()
        // Update the position of the window when screen size is changed

##### Menu front-end (menu.js)

[TODO] To be written

##### Desktop front-end (desktop.js)

[TODO] To be written

#### Back-Ends
##### PanelDesktopData
PanelDesktopData is a back-end object providing interface to manage the content of the desktop.
This basically provides interfaces to remove and provide list of application launcher. 
It monitors the Freedesktop desktop directory (~/Desktop in English locale) for changes concerning .desktop files.
The interface is exposed to JSCore.

    PanelDesktopData

    [JSCore] DesktopData()
    [JSCore] list update()
             // Returns list of launchers as JavaScript object with following fields:
             // * icon: Full path to icon depending on current theme
             // * name: Name of launcher
             // * desktop: Desktop file name
    [JSCore] DesktopData.updateCallback(function) 
             // sets the function to call when changes happens in Desktop directory
    [JSCORE] DesktopData.removeFromDesktop(string) static


##### PanelPlaces
PanelPlaces is a back-end object handling GNOME's Places objects. PanelPlaces handles localized Places.

    PanelPlaces

    [JSCORE] void Places.updateCallback(function)
        // Sets function to be called when any of the Places is changed
    [JSCORE] list Places.update()
        // Returns the list of the Places as a JavaScript array with following fields:
        // * Home, which is an object of following fields:
        //   * icon: Full path of "gtk-home" in current theme
        //   * name: Localized string of "Home"
        //   * uri: Uri to the home
        // * Special directories, which is prepended with following object:
        //   * name: Localized string of "Bookmarks"
        //   * isHeader: true
        //   Then followed with following directories as object:
        //   * icon: Full path of the directory icon in current theme
        //   * name: The name of the directory
        //   * uri: The uri of the directory
        // * Mounts, which is prepended with following object:
        //   * name: Localized string of "Mounts"
        //   * isHeader: true
        //   Then followed with following directories as object:
        //   * icon: Full path of the mount icon in current theme
        //   * name: The name of the mount 
        //   * uri: The uri of the mount
        // * Network, which contains following objects:
        //   * Networks, which is of object:
        //     * icon: Full path of the "gtk-network" icon in current theme
        //     * name: Localized string of "My network"
        //     * uri: Uri of "network:///"
        //   * Connect to server, which is of object:
        //     * icon: Full path of the "gtk-fs-network" icon in current theme
        //     * name: Localized string of "Connect to server..."
        //     * command: String of  "nautilus-connect-server"


##### PanelUser
PanelUser is a back-end object which provides information about the user which owns the session.

    PanelUser

    [PROPERTY] string icon_file read-only
    [PROPERTY] string real_name read-only
    [PROPERTY] string host_name read-only
    [JSCORE] string UserAccount.getIconFile()
    [JSCORE] string UserAccount.getRealName()
    [JSCORE] string UserAccount.getHostName()


##### PanelXdgData
PanelXdgData is a back-end object providing the Freedesktop menu system. It opens the whole sequence of the menu according to the catalog name passed in the constructor. It monitors the Freedesktop data directory as well as the applications desktop directory.

    PanelXdgData
    
    [JSCORE] XdgData.updateCallback(function)
        // Sets function to be called when any of the XdgData is changed
    [JSCORE] XdgData.put_to_desktop(filename)
        // Prepares the .desktop file for filename [TODO] Rename to putToDesktop
    [JSCore] list update()
        // Returns list of menu structure as a JavaScript array of:
        // * Directory, prepended with header object:
        //   * icon: Full path to the directory icon in the current theme
        //   * name: Name of the directory
        //   * children: An array of Entry below 
        // * Entry, an object of:
        //   * icon: Full path to the entry icon in the current theme
        //   * name: The name of the entry
        //   * desktop: Full path to the .desktop file of the entry

#### Helpers
##### PanelUtils
PanelUtils is a set of helper functions

##### PanelScreen
PanelScreen is a utility static functions for handling screen.

### Development View

#### Dependencies

##### X11
Manokwari uses explicit X11 functions, hence may not be easily modified for used with other windowing system.

##### D-Bus
Manokwari uses session D-Bus to perform IPC to following parts of the system:
 * GNOME session manager
 * Freedesktop account manager

#### Source code structure

The structure of source code is partitioned as follows:
 * src/: Contains the source code written in Vala
 * system/: Contains the JavaScript, CSS, and HTML5 files accessible from the webviews
 * vapi/: Contains custom vapi files
 * po/: Contains translations files
 * data/: Contains distribution files

### Physical View

#### File distributions
Files in system/ directory is installed in a directory (set to /usr/share/manokwari/system) which would be available for the webviews. Other than that, usual autotools based installation files are deployed in the system such as:
 * manokwari binary is installed in /usr/bin
 * manokwari.desktop is installed in /usr/share/applications
 * manokwari.mo is installed in translation directory

### Scenarios
The lifecycle of Manokwari is of as follows:
 * Started by gnome-session
 * Run indefinitely until any of the following occurs:
   * User chose shutdown or login menu
   * Manokwari is unable to respond gnome-session when asked for something via D-Bus
   * Internal error which causes Manokwari to crash
   
