using Gtk;
[DBus (name = "org.gnome.SessionManager")]
interface SessionManager : Object {
    public abstract void shutdown () throws IOError;
    public abstract void logout (uint32 mode) throws IOError;
    public abstract bool can_shutdown () throws IOError;
}


public class PanelMenuBox : PanelAbstractWindow {
    private int active_column = 0;
    private const int COLUMN_WIDTH = 320;
    private const int START_POS = 100;

    private Layout columns;

    public signal void dismissed ();
    public signal void sliding_right ();
    public signal void about_to_show_content ();

    private PanelAnimatedAdjustment adjustment;
    private unowned Widget? content_widget = null;

    private SessionManager session = null;

    public int get_active_column () {
        return active_column;
    }

    private void reset () {
        adjustment.set_value (0);
        active_column = 0;
        hide_content_widget ();
    }

    public void slide_left () {
        adjustment.set_target (START_POS);
        adjustment.start ();
        active_column = 0;
    }

    public void slide_right () {
        about_to_show_content (); // hide all contents first

        if (content_widget != null) {
            show_content_widget ();
        } else
            return;

        adjustment.set_target (COLUMN_WIDTH + START_POS);
        adjustment.start ();
        active_column = 1;
        sliding_right ();
    }
    
    private void show_content_widget () {
        if (content_widget != null)
            content_widget.show_all ();
    }

    private void hide_content_widget () {
        if (content_widget == null)
            return;
        content_widget.hide ();
    }

    public PanelMenuBox () {
        try {
            session =  Bus.get_proxy_sync (BusType.SESSION,
                                                  "org.gnome.SessionManager", "/org/gnome/SessionManager");
        } catch (Error e) {
            stdout.printf ("Unable to connect to session manager\n");
        }
        set_type_hint (Gdk.WindowTypeHint.DIALOG);

        adjustment = new PanelAnimatedAdjustment (0, 0, 0, 5, 0, 0);
        adjustment.finished.connect (() => {
            if (active_column == 0 && content_widget != null)
                hide_content_widget ();
        });


        var height = PanelScreen.get_primary_monitor_geometry ().height;

        // Create the columns
        columns = new Layout(null, null);
        columns.set_size(COLUMN_WIDTH * 2 + START_POS, height);

        // Create outer scrollable
        var panel_area = new PanelScrollableContent ();
        panel_area.set_hadjustment (adjustment);
        panel_area.add (columns);
        panel_area.show_all ();
        panel_area.set_scrollbar_policy (PolicyType.NEVER, PolicyType.NEVER);

        // Add to window
        add (panel_area);
        set_size_request (COLUMN_WIDTH, height);

        // Create inner scrollables
        var left_scrollable = new PanelScrollableContent ();
        var right_scrollable  = new PanelScrollableContent ();
        left_scrollable.set_min_content_height (height);
        right_scrollable.set_min_content_height (height);
        left_scrollable.set_min_content_width (COLUMN_WIDTH);
        right_scrollable.set_min_content_width (COLUMN_WIDTH);

        var left_column = new VBox (false, 0);
        left_scrollable.set_widget (left_column);

        var right_column = new VBox (false, 0);
        right_scrollable.set_widget (right_column);

        left_scrollable.set_scrollbar_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
        right_scrollable.set_scrollbar_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);

        columns.put (left_scrollable, START_POS, 0);
        columns.put (right_scrollable, COLUMN_WIDTH + START_POS, 0);

        var favorites = new PanelMenuFavorites ();
        left_column.pack_start (favorites, false, false, 0);

        favorites.menu_clicked.connect (() => {
            dismiss ();
        });

        favorites.deactivate.connect (() => {
            dismiss ();
        });

        var all_apps_opener = new PanelItem.with_label ( _("All applications") );
        all_apps_opener.set_image ("gnome-applications");
        left_column.pack_start (all_apps_opener, false, false, 0);

        var cc_opener = new PanelItem.with_label ( _("Settings") );
        cc_opener.set_image ("gnome-control-center");
        left_column.pack_start (cc_opener, false, false, 0);

        var places_opener = new PanelItem.with_label ( _("Places") );
        places_opener.set_image ("gtk-home");
        left_column.pack_start (places_opener, false, false, 0);

        if (session != null) {
            var logout = new PanelItem.with_label ( _("Logout...") );
            logout.set_image ("gnome-logout");
            left_column.pack_start (logout, false, false, 0);
            logout.activate.connect (() => {
                try {
                    dismiss ();
                    session.logout (0);
                } catch (Error e) {
                    show_dialog (_("Unable to logout: %s").printf (e.message));
                }
            });

            try {
                if (session.can_shutdown ()) {
                    var shutdown = new PanelItem.with_label ( _("Shutdown...") );
                    shutdown.set_image ("system-shutdown");
                    left_column.pack_start (shutdown, false, false, 0);
                    shutdown.activate.connect (() => {
                        try {
                            dismiss ();
                            session.shutdown ();
                        } catch (Error e) {
                            show_dialog (_("Unable to shutdown: %s").printf (e.message));
                        }
                    });
                }
            } catch (Error e) {
                stdout.printf ("Can't determine can shutdown or not");
            }
        }

        //////////////////////////////////////////////////////
        // Second column

        var back_button = new Button.from_stock (Stock.GO_BACK);
        back_button.set_focus_on_click (false);
        back_button.set_alignment (0, (float) 0.5);
        right_column.pack_start (back_button, false, false, 0);

        back_button.clicked.connect (() => {
            slide_left ();
        });

        // All application (2nd) column
        var all_apps = new PanelMenuXdg("applications.menu", _("Applications") );
        right_column.pack_start (all_apps);

        all_apps_opener.activate.connect (() => {
            content_widget = all_apps;
            slide_right (); 
        });

        all_apps.menu_clicked.connect (() => {
            dismiss ();
        });

        all_apps.deactivate.connect (() => {
            dismiss ();
        });

        var control_center = new PanelMenuXdg("settings.menu",  _("Settings") );
        right_column.pack_start (control_center);

        cc_opener.activate.connect (() => {
            content_widget = control_center;
            slide_right (); 
        });

        control_center.menu_clicked.connect (() => {
            dismiss ();
        });

        control_center.deactivate.connect (() => {
            dismiss ();
        });

        var places = new PanelPlaces ();
        right_column.pack_start (places);

        places.error.connect (() => {
            dismiss ();
        });
        places.launching.connect (() => {
            dismiss ();
        });

        places_opener.activate.connect (() => {
            content_widget = places;
            slide_right (); 
        });

        PanelScreen.move_window (this, Gdk.Gravity.NORTH_WEST);

        map_event.connect (() => {
            return false;
        });

        hide ();

        // Monitor changes to the directory

        var xdg_menu_dir = File.new_for_path ("/etc/xdg/menus");
        try {
            var xdg_menu_monitor = xdg_menu_dir.monitor (FileMonitorFlags.NONE, null);
            xdg_menu_monitor.changed.connect (() => {
               favorites.repopulate (); 
               favorites.show_all ();
               all_apps.repopulate (); 
               control_center.repopulate ();

               show_content_widget ();
            });
        } catch (Error e) {
            stdout.printf ("Can't monitor /etc/xdg/menus directory: %s\n", e.message);
        }

        var apps_dir = File.new_for_path ("/usr/share/applications");
        try {
            var apps_monitor = apps_dir.monitor (FileMonitorFlags.NONE, null);
            apps_monitor.changed.connect (() => {
               all_apps.repopulate (); 
               control_center.repopulate ();

               show_content_widget ();
            });
        } catch (Error e) {
            stdout.printf ("Can't monitor applications directory: %s\n", e.message);
        }

        // Signal connections
        button_press_event.connect((event) => {
            // Only dismiss if within the area
            // TODO: multihead
            if (event.x > get_window().get_width ()) {
                dismiss ();
                return true;
            }
            return false;
        });

        // Ignore any attempt to move this window
        configure_event.connect ((event) => {
            var rect = PanelScreen.get_primary_monitor_geometry ();
            if (event.x != rect.x ||
                event.y != rect.y)
                PanelScreen.move_window (this, Gdk.Gravity.NORTH_WEST);
            return false;
        });

        screen_size_changed.connect (() =>  {
            PanelScreen.move_window (this, Gdk.Gravity.NORTH_WEST);
            queue_resize ();
        });
        
        // Hide all contents when activating a content
        about_to_show_content.connect (() => {
            all_apps.hide ();
            control_center.hide ();
            places.hide ();
        });


    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = COLUMN_WIDTH;
    }

    public override void get_preferred_height (out int min, out int max) {
        min = max = PanelScreen.get_primary_monitor_geometry ().height; 
    }

    public override bool map_event (Gdk.Event event) {
        var w = get_window ().get_width ();
        var rect = PanelScreen.get_primary_monitor_geometry (); 
        get_window ().raise ();
        grab ();
        slide_left ();
        return true;
    }

    private void dismiss () {
        stdout.printf("Menu box dismissed \n");
        ungrab ();
        reset ();
        dismissed ();
    }

    private void show_dialog (string message) {
        dismiss ();
        var dialog = new MessageDialog (null, DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE, message);
        dialog.response.connect (() => {
            dialog.destroy ();
        });
        dialog.show ();
    }

    private void grab () {
        var device = get_current_event_device();

        if (device == null) {
            var display = get_display ();
            var manager = display.get_device_manager ();
            var devices = manager.list_devices (Gdk.DeviceType.MASTER).copy();
            device = devices.data;
        }
        var keyboard = device;
        var pointer = device;

        if (device.get_source() == Gdk.InputSource.KEYBOARD) {
            pointer = device.get_associated_device ();
        } else {
            keyboard = device.get_associated_device ();
        }

        var status = keyboard.grab(get_window(), Gdk.GrabOwnership.WINDOW, true, Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK, null, Gdk.CURRENT_TIME);
        status = pointer.grab(get_window(), Gdk.GrabOwnership.WINDOW, true, Gdk.EventMask.BUTTON_PRESS_MASK, null, Gdk.CURRENT_TIME);
    }

    private void ungrab () {
        var device = get_current_event_device();
        var secondary = device.get_associated_device();
        device.ungrab(Gdk.CURRENT_TIME);
        secondary.ungrab(Gdk.CURRENT_TIME);
    }
}
