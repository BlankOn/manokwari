using Gtk;


public class PanelMenuBox : PanelAbstractWindow {
    private int filler_height = 27;
    private int active_column = 0;
    private HBox columns;

    public signal void dismissed ();
    public signal void cancelled ();
    public signal void sliding_right ();

    private PanelAnimatedAdjustment adjustment;
    private unowned Widget? content_widget = null;

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
        content_widget.hide ();
    }

    public PanelMenuBox () {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        move (rect ().x, rect ().y);

        adjustment = new PanelAnimatedAdjustment (0, 0, rect ().width, 5, 0, 0);
        adjustment.finished.connect (() => {
            if (active_column == 0 && content_widget != null)
                hide_content_widget ();
        });

        // Create the columns
        columns = new HBox (true, 0);

        // Create outer scrollable
        var panel_area = new PanelScrollableContent (adjustment, null);
        panel_area.set_widget (columns);

        // Add to window
        add (panel_area);

        // Quick Launch (1st) column
        var quick_launch_box = new VBox (false, 0);
        columns.pack_start (quick_launch_box);

        var favorites = new PanelMenuContent("Favorites", "favorites.menu");
        quick_launch_box.pack_start (favorites, false, false, 0);
        favorites.populate ();
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

        // Second column
        var content_box = new VBox (false, 0);
        columns.pack_start (content_box);

        // All application (2nd) column
        var all_apps = new PanelMenuContent("Applications", "applications.menu");
        content_box.pack_start (all_apps);

        all_apps_opener.activate.connect (() => {
            content_widget = all_apps;
            slide_right (); 
        });

        all_apps.menu_clicked.connect (() => {
            dismiss ();
        });

        all_apps.populate ();
        all_apps.set_min_content_height (rect ().height - 200); // TODO

        var control_center = new PanelMenuContent("Settings", "systems.menu");
        content_box.pack_start (control_center);

        cc_opener.activate.connect (() => {
            content_widget = control_center;
            slide_right (); 
        });

        control_center.menu_clicked.connect (() => {
            dismiss ();
        });

        control_center.populate ();
        control_center.set_min_content_height (rect ().height - 200); // TODO

        show_all ();

        all_apps.hide ();
        control_center.hide ();

        button_press_event.connect((event) => {
            // Only dismiss if within the area
            // TODO: multihead
            if (event.x > get_window().get_width ()) {
                dismiss ();
                cancelled ();
                return true;
            }
            return false;
        });
    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = get_column_width (); 
    }

    public override void get_preferred_height (out int min, out int max) {
        min = max = rect ().height - 10; 
    }

    public override bool map_event (Gdk.Event event) {
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
        return true;
    }


    private void dismiss () {
        var device = get_current_event_device();
        var secondary = device.get_associated_device();
        device.ungrab(Gdk.CURRENT_TIME);
        secondary.ungrab(Gdk.CURRENT_TIME);
        stdout.printf("Menu box dismissed \n");
        reset ();
        dismissed ();
    }
}
