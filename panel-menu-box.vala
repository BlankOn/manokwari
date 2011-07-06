using Gtk;


public class PanelMenuBox : PanelAbstractWindow {
    private int filler_height = 27;
    private int active_column = 0;
    private HBox columns;

    public signal void dismissed ();
    public signal void cancelled ();
    public signal void sliding_right ();

    private PanelAnimatedAdjustment adjustment;

    public int get_active_column () {
        return active_column;
    }

    private int get_column_width () {
        foreach (unowned Widget w in columns.get_children ()) {
            return w.get_allocated_width ();
        }
        return 0;
    }

    public void slide_left () {
        adjustment.set_target (0);
        adjustment.start ();
        active_column = 0;
    }

    public void slide_right () {
        adjustment.set_target (get_column_width ());
        adjustment.start ();
        active_column = 1;
        sliding_right ();
    }


    public PanelMenuBox () {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        move (rect ().x, rect ().y);

        adjustment = new PanelAnimatedAdjustment (0, 0, rect ().width, 5, 0, 0);

        // Create the columns
        columns = new HBox (true, 0);

        // Create outer scrollable
        var panel_area = new PanelScrollableContent (adjustment, null, columns);

        // Add to window
        add (panel_area);

        var filler1 = new DrawingArea ();
        filler1.set_size_request (250, 20);

        // Quick Launch (1st) column
        var quick_launch_box = new VBox (false, 0);
        columns.pack_start (quick_launch_box);

        var quick_launch_bar = new VBox (false, 0);
        quick_launch_box.pack_start (filler1, false, false, 20);
        quick_launch_box.pack_start (quick_launch_bar, false, false, 0);
        var favorites = new PanelMenuContent (quick_launch_bar, "favorites.menu");
        favorites.populate ();
        favorites.insert_separator ();

        favorites.menu_clicked.connect (() => {
            dismiss ();
        });

        var all_apps_opener = new PanelItem.with_label ("All applications");
        all_apps_opener.set_image ("");
        all_apps_opener.activate.connect (() => {
            slide_right (); 
        });
        quick_launch_bar.pack_start (all_apps_opener, false, false, 0);

        // All application (2nd) column
        var all_apps_bar = new VBox (false, 0);
        var all_apps_area = new PanelScrollableContent (null, null, all_apps_bar);
        all_apps_area.set_scrollbar_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
        var all_apps_box = new VBox (false, 0);
        columns.pack_start (all_apps_box);

        var filler2 = new DrawingArea ();
        all_apps_box.pack_start (filler2, false, false, 20);
        all_apps_box.pack_start (all_apps_area, false, false, 0);


        var applications = new PanelMenuContent (all_apps_bar, "applications.menu");
        applications.menu_clicked.connect (() => {
            dismiss ();
        });

        applications.populate ();
        applications.insert_separator ();

        all_apps_area.set_min_content_height (rect ().height -  filler_height - 200); // TODO
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
        adjustment.set_value (0);
        active_column = 0;
        dismissed ();
    }
}
