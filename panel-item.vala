using Gtk;

public class PanelExpanderItem : Expander {

    public signal void expanding ();

    private bool expand_later () {
        set_expanded (true); 
        expanding ();
        return false;
    }

    public PanelExpanderItem (string title) {
         add_events (Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK
            | Gdk.EventMask.KEY_PRESS_MASK
            | Gdk.EventMask.KEY_RELEASE_MASK
            | Gdk.EventMask.POINTER_MOTION_MASK);

        enter_notify_event.connect ((o, event) => {
            GLib.Timeout.add (250, expand_later);
            return true;
        });

        set_label (title);
    }
}

public class PanelItem : Box {
    private HBox box;
    private DesktopAppInfo info;
    private EventBox event_box;
    private Label label;
    private Image image;

    public signal void activate ();

    public PanelItem () {
        init ();
    }

    public PanelItem.with_label (string title) {
        init ();
        label.set_text (title);
    }

    public void load_app_info (string filename) {
        info = new DesktopAppInfo.from_filename (filename);
    }

    private void init () {
        box = new HBox (false, 0);
        event_box = new EventBox ();
        add (event_box);
        event_box.add (box);
        event_box.set_above_child (true);
        event_box.set_visible_window (false);
        info = null;
        label = new Label ("");
        image = new Image.from_stock (Stock.MISSING_IMAGE, IconSize.LARGE_TOOLBAR); 
        label.show ();
        image.show ();
        box.show ();
        box.pack_start (image, false, false, 10);
        box.pack_start (label, false, false, 0);
        show ();

        event_box.add_events (Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK
            | Gdk.EventMask.KEY_PRESS_MASK
            | Gdk.EventMask.KEY_RELEASE_MASK
            | Gdk.EventMask.POINTER_MOTION_MASK);

        event_box.button_release_event.connect ((event) => {
            activate ();
            return false;
        });

        event_box.enter_notify_event.connect ((event) => {
            set_state(StateType.PRELIGHT);
            return true;
        });

        event_box.leave_notify_event.connect (() => {
            set_state(StateType.NORMAL);
            return true;
        });

    }

    public void set_image (string image_name) {
        if (image_name != "") {
            image.set_from_icon_name (image_name, IconSize.LARGE_TOOLBAR); 
            image.show ();
            return;
        }
        image.clear ();
    }

    public void append_filler (int width) { 
        var filler = new DrawingArea ();

        box.pack_start (filler, false, false, width);
        box.reorder_child (filler, 0);
    }

    public override bool draw (Cairo.Context cr) {
        StyleContext style = get_style_context ();
        style.set_state (get_state_flags ());
        Gtk.render_background (style, cr, 0, 0, get_window ().get_width (), get_window ().get_height ());
        base.draw (cr);
        return true;
    }

}
