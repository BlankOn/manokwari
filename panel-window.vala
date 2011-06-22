using Gtk;
using Cairo;
using Wnck;

public class PanelWindowDescription : PanelAbstractWindow {
    public signal void hidden ();
    private Label label;
    private bool _cancel_hiding;
    private bool popup_shown = false;
    private Wnck.Window window_info;

    public signal void clicked ();

    public void cancel_hiding() {
        _cancel_hiding = true;
    }

    bool hide_description () {
        if (_cancel_hiding)
            return false;

        hide ();
        hidden ();
        return false;
    }

    public void set_window_info (Wnck.Window info) {
        window_info = info;
        label.set_text (info.get_name ());
    }

    public PanelWindowDescription () {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        add_events (Gdk.EventMask.STRUCTURE_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        hide();
        label = new Label ("");
        label.show ();
        add (label);

        leave_notify_event.connect (() => {
            if (popup_shown)
                return false;

            _cancel_hiding = false;
            GLib.Timeout.add (250, hide_description); 

            return true; 
        });

        button_press_event.connect ((event) => {
            if (event.button == 3 && event.type == Gdk.EventType.BUTTON_PRESS) { // right click
                show_popup (event);
            } else {
                activate_window ();
            }
            return true; 
        });
    }

    public void show_popup (Gdk.EventButton event) {
        var menu = new Wnck.ActionMenu (window_info);

        var button = event.button;
        var event_time = event.time;

        menu.deactivate.connect (() => {
            stdout.printf("xxxxx\n");
            popup_shown = false;
            hide ();
        });
        menu.attach_to_widget (this, null);

        popup_shown = true;
        menu.popup (null, null, null, button, event_time);
    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = 50; 
    }

    public override void get_preferred_width (out int min, out int max) {
        var r = rect();
        min = max = r.width;
    }

    public void activate_window () {
        var t = new DateTime.now_local ();
        window_info.activate ((uint32) t.to_unix());
    }
}

public class PanelWindowEntry : DrawingArea {
    private Gdk.Rectangle rect;
    private Wnck.Window window_info;
    private Wnck.WindowState last_state;
    private Gtk.StateFlags state;
    private PanelWindowDescription description;

    public signal void description_shown ();

    private bool show_description () {
        description.show_all ();
        description_shown ();
        return false;
    }

    private void sync_window_states () {
        if (window_info.is_minimized ()) {
            state = StateFlags.INSENSITIVE;
        } else {
            state = StateFlags.NORMAL;
        }
        description.set_state_flags (state, true);
        queue_draw ();
    }

    public PanelWindowEntry (Wnck.Window info, ref PanelWindowDescription d) {
        add_events (Gdk.EventMask.STRUCTURE_MASK
            | Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK);

        window_info = info;
        last_state = info.get_state ();
        description = d;
        sync_window_states ();
        d.set_window_info (info);

        var screen = get_screen();
        screen.get_monitor_geometry (screen.get_primary_monitor(), out rect);

        window_info.state_changed.connect((mask, new_state) => {
            if (new_state == last_state)
                return;

            sync_window_states ();
        });

        leave_notify_event.connect ((event) => {
            sync_window_states ();
            return false;
        });
        enter_notify_event.connect ((event) => {
            description.set_window_info (info);
            state = StateFlags.PRELIGHT;
            description.set_state_flags (state, true);
            queue_draw ();
            GLib.Timeout.add (100, show_description); 
            description.cancel_hiding ();
            return false; 
        });

        description_shown.connect (() => {
            description.get_window().move (0, rect.height -  get_window ().get_height () - description.get_window ().get_height ());
        });

        button_press_event.connect ((event) => {
            state = StateFlags.SELECTED;
            description.set_state_flags (state, true);
            queue_draw ();
            description.activate_window ();
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
        style.set_state (state);
        Gtk.render_background (style, cr, 0, 0, get_window ().get_width (), get_window ().get_height ());
        return true;
    }

}

public class PanelWindowHost : PanelAbstractWindow {
    private PanelWindowDescription description;
    private bool active;
    private HBox box;
    private new Wnck.Screen screen;
    private int num_visible_windows;

    public signal void windows_gone();
    public signal void windows_visible();

    public bool no_windows_around () {
        update ();
        return (num_visible_windows == 0);
    }

    public PanelWindowHost () {
        num_visible_windows = 0;
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        active = false;
        description = new PanelWindowDescription ();
        screen = Wnck.Screen.get_default ();
        box = new HBox (true, 0);
        add(box);

        box.show ();
        description.hide ();
        show();
        var r = rect();
        move (0, r.height - get_window ().get_height ());

        description.hidden.connect (() => {
            move (0, r.height - get_window ().get_height ());
        });

        screen.window_opened.connect ((w) => {
            if (!w.is_skip_tasklist()) {
                var t = new DateTime.now_local ();
                w.activate ((uint32) t.to_unix());
                update ();

                w.state_changed.connect((mask, state) => {
                    update ();
                });
            }
        });
        screen.window_closed.connect ((w) => {
            if (!w.is_skip_tasklist())
                update ();
        });

    }

    public override void get_preferred_width (out int min, out int max) {
        var r = rect();
        min = max = r.width;
    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = 12; 
    }

    public void update () {
        set_struts(); 
        foreach (unowned Widget w in box.get_children ()) {
            box.remove (w);
        }
        var num_windows = 0;
        foreach (unowned Wnck.Window w in screen.get_windows()) {
            if (!w.is_skip_tasklist () && w.get_name() != "blankon-panel") {
                var e = new PanelWindowEntry (w, ref description);
                e.show ();
                box.pack_start (e, true, true, 1);
                if (!w.is_minimized ())
                    num_windows ++;
            }
        }
        if (num_windows == 0)
            windows_gone ();
        else
            windows_visible ();
        num_visible_windows = num_windows;
    }

    public void dismiss () {
        description.hide ();
    }
}
