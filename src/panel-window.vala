using Gtk;
using Cairo;
using Wnck;
using Gee;

public class PanelWindowPager : PanelAbstractWindow {
    public signal void hidden ();
    private bool _cancel_hiding;

    public void cancel_hiding() {
        _cancel_hiding = true;
    }

    bool hide_pager () {
        if (_cancel_hiding)
            return false;

        hide ();
        hidden ();
        return false;
    }

    public PanelWindowPager () {
        var pager = new Wnck.Pager ();
        add(pager);
        pager.show ();
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        hide();

        leave_notify_event.connect (() => {
            _cancel_hiding = false;
            GLib.Timeout.add (250, hide_pager); 

            return true; 
        });

    }


    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = 50; 
    }

    public override void get_preferred_width (out int min, out int max) {
        var r = rect();
        min = max = 100;
    }
}

public class PanelWindowPagerEntry : DrawingArea {
    private PanelWindowPager pager;
    private Gdk.Rectangle rect;

    public signal void pager_shown ();

    private bool show_pager_handler () {
        pager.show_all ();
        pager_shown ();
        return false;
    }

    public void hide_pager () {
        pager.hide ();
    }

    public PanelWindowPagerEntry () {
        add_events (Gdk.EventMask.STRUCTURE_MASK
            | Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK);

        pager = new PanelWindowPager ();
        show ();
        var screen = get_screen();
        screen.get_monitor_geometry (screen.get_primary_monitor(), out rect);

        button_press_event.connect ((event) => {
            stdout.printf("cccc\n");
            GLib.Timeout.add (100, show_pager_handler); 
            pager.cancel_hiding ();
            return false; 
        });

        enter_notify_event.connect ((event) => {
            GLib.Timeout.add (100, show_pager_handler); 
            pager.cancel_hiding ();
            return false; 
        });

        pager_shown.connect (() => {
            pager.get_window().move (0, rect.height -  get_window ().get_height () - pager.get_window ().get_height ());
        });

    }


    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = 10; 
    }

    public override void get_preferred_width (out int min, out int max) {
        max = min = 50;
    }

    public override bool draw (Context cr) {
        StyleContext style = get_style_context ();
        Gtk.render_background (style, cr, 0, 0, get_window ().get_width (), get_window ().get_height ());
        return true;
    }

}

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
        label.set_markup ("<big>" + info.get_name () + "</big>");
    }

    public PanelWindowDescription () {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
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
        window_info.activate (get_current_event_time());
    }
}

public class PanelWindowEntry : DrawingArea {
    private Gdk.Rectangle rect;
    private Wnck.Window window_info;
    private Wnck.WindowState last_state;
    private Gtk.StateFlags state;
    private PanelWindowDescription description;

    public signal void description_shown ();
    public signal void entered ();
    public signal void left ();

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
            left ();
            return false;
        });
        enter_notify_event.connect ((event) => {
            description.set_window_info (info);
            state = StateFlags.PRELIGHT;
            description.set_state_flags (state, true);
            queue_draw ();
            GLib.Timeout.add (100, show_description); 
            description.cancel_hiding ();
            entered ();
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
    private HashMap <Wnck.Window, PanelWindowEntry> entry_map ;
    private int height = 12;

    public signal void windows_gone();
    public signal void windows_visible();
    public signal void description_shown ();

    enum Size {
        Small = 12,
        Big = 50
    }

    public bool no_windows_around () {
        update (false);
        return (num_visible_windows == 0);
    }

    public PanelWindowHost () {
        entry_map = new HashMap <Wnck.Window, PanelWindowEntry> (); 

        num_visible_windows = 0;
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        active = false;
        description = new PanelWindowDescription ();
        screen = Wnck.Screen.get_default ();
        var outer_box = new HBox (false, 0); 
        box = new HBox (true, 0);
        add(outer_box);

        var pager_entry = new PanelWindowPagerEntry ();
        pager_entry.set_name ("PAGER");
        pager_entry.show ();
        outer_box.pack_start (pager_entry, false, false, 1);

        outer_box.pack_start (box, true, true, 1);
        outer_box.show ();

        box.show();
        description.hide ();
        show();
        var r = rect();
        move (0, r.height - get_window ().get_height ());

        pager_entry.pager_shown.connect (() => {
            description.hide ();
        });

        // Hide pager when description is shown
        description_shown.connect (() => {
            pager_entry.hide_pager ();
        });

        description.hidden.connect (() => {
        });

        screen.window_opened.connect ((w) => {
            if (!w.is_skip_tasklist()) {
                w.activate (get_current_event_time());
                update (true);

                w.state_changed.connect((mask, state) => {
                    update (true);
                });
            }
        });
        screen.window_closed.connect ((w) => {
            var e = entry_map [w];
            e.destroy ();
        });

        screen.active_workspace_changed.connect (() => {
            update (true);
        });

        enter_notify_event.connect (() => {
            resize (Size.Big);
            return false;
        });

        leave_notify_event.connect ((e) => {
            int x, y;
            get_window ().get_position (out x, out y);
            // If e.y is negative then it's outside the area
            if (e.y < 0) {
                resize (Size.Small);
                description.hide ();
            }
            return false;
        });
    }

    private new void resize (Size size) {
        height = size;
        queue_resize ();
        get_window ().move_resize (rect ().x, rect ().height - size, rect ().width, size);
    }

    public override void get_preferred_width (out int min, out int max) {
        var r = rect();
        min = max = r.width;
    }

    public override void get_preferred_height (out int min, out int max) {
        min = max = height; 
    }

    public void update (bool emit_change_signals) {
        set_struts(); 

        foreach (unowned Widget w in box.get_children ()) {
            if (w is PanelWindowEntry)
                box.remove (w);
        }

        var num_windows = 0;
        foreach (unowned Wnck.Window w in screen.get_windows()) {
            if (!w.is_skip_tasklist () 
              && (w.get_name() != "blankon-panel")
              && w.is_on_workspace (screen.get_active_workspace())) {
                var e = entry_map [w];
                if (e == null) {
                    e = new PanelWindowEntry (w, ref description);
                    entry_map.set (w, e);
                    
                    // Forward description_shown signal
                    // so the pager would close
                    e.description_shown.connect (() => {
                        description_shown ();
                    });

                }

                e.show ();
                box.pack_start (e, true, true, 1);
                if (!w.is_minimized ())
                    num_windows ++;
            }
        }
        if (emit_change_signals) {
            if (num_windows == 0)
                windows_gone ();
            else
                windows_visible ();
        }
        num_visible_windows = num_windows;
    }

    public void dismiss () {
        description.hide ();
    }
}
