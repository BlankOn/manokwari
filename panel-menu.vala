using Gtk;
using Cairo;
using Wnck;

public class PanelWindowDescription : PanelAbstractWindow {
    public signal void hidden ();
    private Gdk.Rectangle rect;
    private Label label;
    private bool _cancel_hiding;

    public void cancel_hiding() {
        _cancel_hiding = true;
    }

    public void set_label (string s) {
        label.set_text (s);
    }

    private bool hide_description () {
        if (_cancel_hiding)
            return false;

        hide ();
        hidden ();
        return false;
    }

    public PanelWindowDescription () {
        add_events (Gdk.EventMask.STRUCTURE_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        hide();
        var screen = get_screen ();
        screen.get_monitor_geometry (screen.get_primary_monitor(), out rect);
        label = new Label ("");
        label.show ();
        add (label);

        leave_notify_event.connect (() => {
            _cancel_hiding = false;
            GLib.Timeout.add (250, hide_description); 

            return false; 
        });
    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = 50; 
    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = rect.width;
    }


}

public class PanelWindowEntry : DrawingArea {
    private Wnck.Window window_info;
    private Gdk.Rectangle rect;
    private PanelWindowDescription description;

    public signal void description_shown ();

    private bool show_description () {
        description.set_label (window_info.get_name ());
        description.show_all ();
        description_shown ();
        return false;
    }

    public PanelWindowEntry (Wnck.Window info, PanelWindowDescription d) {
        add_events (Gdk.EventMask.STRUCTURE_MASK
            | Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK);

        window_info = info;
        description = d;
        var screen = get_screen ();
        screen.get_monitor_geometry (screen.get_primary_monitor(), out rect);

        enter_notify_event.connect ((event) => {
            var i = GLib.Timeout.add (100, show_description); 
            description.cancel_hiding ();
            return false; 
        });

        description_shown.connect (() => {
            description.get_window().move (0, rect.height -  get_window ().get_height () - description.get_window ().get_height ());
        });

        button_press_event.connect ((event) => {
            info.activate (Gdk.CURRENT_TIME);
            return false; 
        });


    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = 10; 
    }

    public override void get_preferred_width (out int min, out int max) {
        max = rect.width;
        min = 10;
    }

    public override bool draw (Context cr) {
        StyleContext style = get_style_context ();
        Gtk.render_background (style, cr, 0, 0, get_window ().get_width (), get_window ().get_height ());
        return false;
    }

}

public class PanelWindowHost : PanelAbstractWindow {
    private Gdk.Rectangle rect;
    private PanelWindowDescription description;
    private bool active;
    private HBox box;
    private Wnck.Screen screen;

    public PanelWindowHost () {
        active = false;
        description = new PanelWindowDescription ();
        screen = Wnck.Screen.get_default ();
        box = new HBox (true, 0);
        add(box);
        var s = get_screen ();
        s.get_monitor_geometry (s.get_primary_monitor(), out rect);

        box.show ();
        description.hide ();
        show();
        move (0, rect.height);

        description.hidden.connect (() => {
            get_window().move (0, rect.height);
        });

        screen.window_opened.connect ((w) => {
            if (!w.is_skip_tasklist())
                update ();
        });
        screen.window_closed.connect ((w) => {
            if (!w.is_skip_tasklist())
                update ();
        });

    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = rect.width;
    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = 12; 
    }

    public void update () {
        foreach (unowned Widget w in box.get_children ()) {
            box.remove (w);
        }
        foreach (unowned Wnck.Window w in screen.get_windows()) {
            if (!w.is_skip_tasklist () && w.get_name() != "blankon-panel") {
                var e = new PanelWindowEntry (w, description);
                e.show ();
                box.pack_start (e, true, true, 1);
            }
        }
    }
}
