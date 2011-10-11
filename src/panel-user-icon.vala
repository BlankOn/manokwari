using Gtk;
using Cairo;

public class PanelUserIcon : DrawingArea {
    private Gdk.Pixbuf icon = null;
    private Pango.Layout pango;
    const int ICON_MARGIN = 5;
    const int ICON_SIZE = 48;
    string name = "";
    private Gtk.StateFlags state;

    public signal void deactivate ();
 
    public PanelUserIcon () {
        pango = new Pango.Layout (get_pango_context ());
        load_data ();
        add_events (Gdk.EventMask.STRUCTURE_MASK
            | Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK);

        var face_file = File.new_for_path (Environment.get_home_dir () + "/.face");
        try {
            var face_file_monitor = face_file.monitor (FileMonitorFlags.NONE, null);
            face_file_monitor.changed.connect (() => {
                load_data ();
            });
        } catch (Error e) {
            stdout.printf ("Can't monitor face file: %s\n", e.message);
        }

        var passwd_file = File.new_for_path ("/etc/passwd");
        try {
            var passwd_file_monitor = passwd_file.monitor (FileMonitorFlags.NONE, null);
            passwd_file_monitor.changed.connect (() => {
                load_data ();
            });
        } catch (Error e) {
            stdout.printf ("Can't monitor passwd file: %s\n", e.message);
        }


        state = StateFlags.NORMAL;
        leave_notify_event.connect ((event) => {
            state = StateFlags.NORMAL;
            queue_draw ();
            return false;
        });
        enter_notify_event.connect ((event) => {
            state = StateFlags.PRELIGHT;
            queue_draw ();
            return false;
        });
        button_press_event.connect ((event) => {
            if (event.button == 3 && event.type == Gdk.EventType.BUTTON_PRESS) { // right click
                show_popup (event);
            } 
            return false;
        });
    }


    public override void get_preferred_height (out int min, out int max) {
        min = max = ICON_MARGIN * 2 + ICON_SIZE;
    }

    void load_data () {
        name = get_name ();
        try {
            icon = new Gdk.Pixbuf.from_file_at_scale (Environment.get_home_dir () + "/.face", ICON_SIZE, ICON_SIZE, false);
        } catch (Error e) {
            try {
                var icon_theme = IconTheme.get_default ();
                icon = icon_theme.load_icon ("gnome-session", ICON_SIZE, 0);
            } catch (Error e) {
                stderr.printf ("Unable to load icon 'gnome-session': %s\n", e.message);
            }
        }
    }

    public override bool draw (Context cr) {
        StyleContext style = get_style_context ();
        int w = get_window ().get_width ();
        int h = get_window ().get_height ();
        Gtk.render_background (style, cr, 0, 0, w, h);

        if (icon != null)
            Gdk.cairo_set_source_pixbuf (cr, icon, ICON_MARGIN, ICON_MARGIN);

        pango.set_font_description (style.get_font (Gtk.StateFlags.NORMAL));
        pango.set_markup ("<big>" + name + "</big>", -1);
        var text_x = 2 * ICON_MARGIN + ICON_SIZE; 
        var text_y = 0;

        int text_w, text_h;
        pango.get_pixel_size (out text_w, out text_h);
        text_y = h / 2 - text_h / 2; 

        Gtk.render_layout (style, cr, text_x, text_y, pango);
        cr.paint ();
        return true;
    }

    string get_name () {
        string retval = GLib.Environment.get_real_name ();

        if (retval == "Unknown")
            retval = GLib.Environment.get_user_name ();

        stdout.printf ("%s\n", retval);
        return retval;
    }

    public void show_popup (Gdk.EventButton event) {
        var menu = new Menu ();

        var entry = new MenuItem.with_label (_("Edit profile"));
        entry.show ();
        menu.add (entry);

        entry.activate.connect (() => {
            Utils.launch_profile ();
            deactivate ();
        });

        var button = event.button;
        var event_time = event.time;

        menu.deactivate.connect (() => {
            deactivate ();
        });
        menu.attach_to_widget (this, null);

        menu.popup (null, null, null, button, event_time);

    }

}
