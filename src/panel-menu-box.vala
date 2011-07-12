using Gtk;
[DBus (name = "org.gnome.SessionManager")]
interface SessionManager : Object {
    public abstract void shutdown () throws IOError;
    public abstract void logout (uint32 mode) throws IOError;
    public abstract bool can_shutdown () throws IOError;
}


public class PanelMenuBox : PanelAbstractWindow {
    private int filler_height = 27;
    private int active_column = 0;
    private Invisible evbox;
    private HBox columns;

    public signal void dismissed ();
    public signal void sliding_right ();

    private PanelAnimatedAdjustment adjustment;
    private unowned Widget? content_widget = null;

    private SessionManager session;

    public int get_active_column () {
        return active_column;
    }

    private int get_column_width () {
        foreach (unowned Widget w in columns.get_children ()) {
            return w.get_allocated_width ();
        }
        return 0;
    }

    private void reset () {
        adjustment.set_value (0);
        active_column = 0;
        hide_content_widget ();
    }

    public void slide_left () {
        adjustment.set_target (0);
        adjustment.start ();
        active_column = 0;
    }

    public void slide_right () {
        Allocation a;
        
        if (content_widget != null) {
            show_content_widget ();
            content_widget.get_allocation (out a);
        } else
            return;

        adjustment.set_target (a.x);
        adjustment.start ();
        active_column = 1;
        sliding_right ();
    }
    
    private void show_content_widget () {
        content_widget.show_all ();
    }

    private void hide_content_widget () {
        if (content_widget == null)
            return;
        content_widget.hide ();
    }

    public PanelMenuBox () {
        session =  Bus.get_proxy_sync (BusType.SESSION,
                                                  "org.gnome.SessionManager", "/org/gnome/SessionManager");
        set_type_hint (Gdk.WindowTypeHint.DIALOG);
        move (rect ().x, rect ().y);

        adjustment = new PanelAnimatedAdjustment (0, 0, rect ().width, 5, 0, 0);
        adjustment.finished.connect (() => {
            if (active_column == 0 && content_widget != null)
                hide_content_widget ();
        });

        // Create the columns
        columns = new HBox (true, 0);

        // Create outer scrollable
        var panel_area = new PanelScrollableContent ();
        panel_area.set_hadjustment (adjustment);
        panel_area.set_widget (columns);

        // Add to window
        add (panel_area);

        // Quick Launch (1st) column
        var quick_launch_box = new VBox (false, 0);
        columns.pack_start (quick_launch_box);

        var favorites = new PanelMenuContent("Favorites");
        quick_launch_box.pack_start (favorites, false, false, 0);
        favorites.populate ("favorites.menu");
        favorites.set_min_content_height (200);

        favorites.menu_clicked.connect (() => {
            dismiss ();
        });

        var all_apps_opener = new PanelItem.with_label ("All applications");
        all_apps_opener.set_image ("gnome-applications");
        quick_launch_box.pack_start (all_apps_opener, false, false, 0);

        var cc_opener = new PanelItem.with_label ("Settings");
        cc_opener.set_image ("gnome-control-center");
        quick_launch_box.pack_start (cc_opener, false, false, 0);

        var places_opener = new PanelItem.with_label ("Places");
        places_opener.set_image ("gtk-home");
        quick_launch_box.pack_start (places_opener, false, false, 0);

        try {
            var logout = new PanelItem.with_label ("Logout...");
            logout.set_image ("gnome-logout");
            quick_launch_box.pack_start (logout, false, false, 0);
            logout.activate.connect (() => {
                    session.logout (0);
                    });

            if (session.can_shutdown ()) {
                var shutdown = new PanelItem.with_label ("Shutdown...");
                shutdown.set_image ("system-shutdown");
                quick_launch_box.pack_start (shutdown, false, false, 0);
                shutdown.activate.connect (() => {
                        session.shutdown ();
                        });
            }
        } catch (Error e) {
            stdout.printf ("Unable to connect to session manager\n");
        }

        //////////////////////////////////////////////////////
        // Second column
        var content_box = new VBox (false, 0);
        columns.pack_start (content_box);

        var back_button = new Button.from_stock (Stock.GO_BACK);
        back_button.set_focus_on_click (false);
        back_button.set_alignment (0, (float) 0.5);
        content_box.pack_start (back_button, false, false, 0);

        back_button.clicked.connect (() => {
            slide_left ();
        });

        // All application (2nd) column
        var all_apps = new PanelMenuContent("Applications");
        content_box.pack_start (all_apps);

        all_apps_opener.activate.connect (() => {
            content_widget = all_apps;
            slide_right (); 
        });

        all_apps.menu_clicked.connect (() => {
            dismiss ();
        });

        all_apps.populate ("applications.menu");
        all_apps.set_min_content_height (rect ().height - 200); // TODO

        var control_center = new PanelMenuContent("Settings");
        content_box.pack_start (control_center);

        cc_opener.activate.connect (() => {
            content_widget = control_center;
            slide_right (); 
        });

        control_center.menu_clicked.connect (() => {
            dismiss ();
        });

        control_center.populate ("settings.menu");
        control_center.set_min_content_height (rect ().height - 200); // TODO

        var places = new PanelPlaces ();
        content_box.pack_start (places);
        places.set_min_content_height (rect ().height - 200); // TODO

        places_opener.activate.connect (() => {
            content_widget = places;
            slide_right (); 
        });

        show_all ();

        all_apps.hide ();
        control_center.hide ();
        places.hide ();

        var tray = new PanelTray ();
        quick_launch_box.pack_end (tray, false, false, 0);
        tray.show ();

        evbox = new Invisible ();
        evbox.add_events (Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK);

        evbox.show ();

        evbox.button_press_event.connect(() => {
            dismiss ();
            return true;
        });

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
            if (event.x != rect ().x ||
                event.y != rect ().y)
                move (rect ().x, rect ().y);
            return false;
        });
    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = get_column_width (); 
    }

    public override void get_preferred_height (out int min, out int max) {
        min = max = rect ().height; 
    }

    public override bool map_event (Gdk.Event event) {
        var w = get_window ().get_width ();
        evbox.show ();
        evbox.get_window ().move_resize (rect ().x + w, rect ().y, rect ().width - w, rect ().height);
        get_window ().raise ();
        return true;
    }

    private void dismiss () {
        stdout.printf("Menu box dismissed \n");
        evbox.hide ();
        reset ();
        dismissed ();
    }
}
