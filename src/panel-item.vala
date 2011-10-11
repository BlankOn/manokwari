using Gtk;

public class PanelExpanderItem : Expander {
    private PanelItem item;

    public PanelExpanderItem (string title, string icon) {
        add_events (Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK
            | Gdk.EventMask.KEY_PRESS_MASK
            | Gdk.EventMask.KEY_RELEASE_MASK
            | Gdk.EventMask.POINTER_MOTION_MASK);

        item = new PanelItem.with_label (title);
        item.show ();
        item.set_image (icon);
        set_label_widget (item);
    }
}

public class PanelItem : Box {
    private HBox box;
    private DesktopAppInfo info;
    private EventBox event_box;
    private Label label;
    private Image image;
    private Gtk.Settings settings;
    private int MARGIN = 6;
    private bool pressed;

    public new signal void activate ();
    public new signal void right_clicked (Gdk.EventButton event);

    public PanelItem () {
        init ();
    }

    public PanelItem.with_label (string title) {
        init ();
        label.set_text (title);
    }

    public void set_text (string title) {
        label.set_text (title);
    }
    public void load_app_info (string filename) {
        info = new DesktopAppInfo.from_filename (filename);
    }

    private void init () {
        pressed = false;
        settings = Gtk.Settings.get_default ();
        box = new HBox (false, 0);
        event_box = new EventBox ();
        event_box.show ();
        add (event_box);
        event_box.add (box);
        event_box.set_above_child (true);
        event_box.set_visible_window (false);
        info = null;
        label = new Label ("");
        image = new Image.from_stock (Stock.MISSING_IMAGE, IconSize.LARGE_TOOLBAR); 
        label.show ();
        label.set_justify(Justification.LEFT);
        image.show ();
        box.show ();
        box.pack_start (image, false, false, 10);
        box.pack_start (label, false, true, 0);
        show ();

        // Set this for map-event

        event_box.add_events (Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.STRUCTURE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK
            | Gdk.EventMask.KEY_PRESS_MASK
            | Gdk.EventMask.KEY_RELEASE_MASK
            | Gdk.EventMask.POINTER_MOTION_MASK);


        event_box.button_press_event.connect ((event) => {
            pressed = true;

            return true;
        });

        event_box.button_release_event.connect ((event) => {
            if (pressed == false)
                return true;

            pressed = false;
            if (event.button == 1 && event.type == Gdk.EventType.BUTTON_RELEASE) { // left click
                activate ();
            } else if (event.button == 3 && event.type == Gdk.EventType.BUTTON_RELEASE) { // right click
                right_clicked (event);
            } 
            return true;
        });

        event_box.enter_notify_event.connect ((event) => {
            set_state(StateType.PRELIGHT);
            return true;
        });

        event_box.leave_notify_event.connect (() => {
            set_state(StateType.NORMAL);
            return true;
        });

        event_box.realize.connect (() => {
            event_box.set_size_request (get_toplevel().get_allocated_width () - MARGIN * 2, image.get_allocated_width ()+ MARGIN);
        });
    }

    public void set_image (string image_name) {
        if (image_name != "") {
            image.set_from_icon_name (image_name, IconSize.LARGE_TOOLBAR); 
            if (settings.gtk_menu_images)
                image.show ();
            return;
        }
        image.clear ();
    }

    public void set_image_from_icon (Icon icon) {
        image.set_from_gicon (icon, IconSize.LARGE_TOOLBAR); 
        if (settings.gtk_menu_images)
            image.show ();
    }

    public void append_filler (int width) { 
        var filler = new DrawingArea ();

        filler.show ();
        box.pack_start (filler, false, false, width);
        box.reorder_child (filler, 0);
    }

    public override bool draw (Cairo.Context cr) {
        StyleContext style = get_style_context ();
        style.set_state (get_state_flags ());
        Gtk.render_background (style, cr, MARGIN, 0, event_box.get_allocated_width (), get_allocated_height ()); 
        base.draw (cr);
        return true;
    }

}
