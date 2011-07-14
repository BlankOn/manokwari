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

public class PanelWindowEntry : DrawingArea {
    private Gdk.Rectangle rect;
    private Wnck.Window window_info;
    private Wnck.WindowState last_state;
    private Gtk.StateFlags state;
    private bool popup_shown = false;
    private Pango.Layout pango;
    private int Margin = 5;
    private bool oversize = false;

    public bool draw_info { private get; set; default = false; }

    private void sync_window_states () {
        if (window_info.is_minimized ()) {
            state = StateFlags.INSENSITIVE;
        } else {
            state = StateFlags.NORMAL;
        }
        queue_draw ();
    }

    public PanelWindowEntry (Wnck.Window info) {
        pango = new Pango.Layout (get_pango_context ());

        add_events (Gdk.EventMask.STRUCTURE_MASK
            | Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK);

        window_info = info;
        last_state = info.get_state ();
        sync_window_states ();

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
            state = StateFlags.PRELIGHT;
            queue_draw ();
            if (oversize)
                set_tooltip_text (window_info.get_name ());
            else
                set_tooltip_text ("");
            return false; 
        });

        button_press_event.connect ((event) => {
            if (event.button == 3 && event.type == Gdk.EventType.BUTTON_PRESS) { // right click
                show_popup (event);
            } else {
                if (window_info.is_active ()) {
                    window_info.minimize ();
                } else {
                    state = StateFlags.SELECTED;
                    queue_draw ();
                    window_info.activate (get_current_event_time());
                }
            }
            return true; 
        });

    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = Margin * 2; 
    }

    public override void get_preferred_width (out int min, out int max) {
        max = rect.width;
        min = Margin * 2;
    }

    public override bool draw (Context cr) {
        StyleContext style = get_style_context ();
        style.set_state (state);
        Gtk.render_background (style, cr, 0, 0, get_window ().get_width (), get_window ().get_height ());
        if (draw_info) {
            var dir = get_direction ();
            int icon_x = 0, icon_y = 0;
            int text_start = 0;
            unowned Gdk.Pixbuf icon = window_info.get_icon ();
            var w = get_window ().get_width ();
            var h = get_window ().get_height ();
            int icon_margin = Margin;
            if (icon != null) {
                icon_margin = h / 2 - icon.get_height () / 2;
                if (icon_margin < 0)
                    icon_margin = Margin;
                if (dir == TextDirection.LTR) {
                    icon_x = icon_margin;
                    icon_y = icon_margin;
                    text_start = icon_x + icon.get_width () + icon_margin;
                } else {
                    icon_x = w - icon.get_width () - icon_margin;
                    icon_y = icon_margin;
                    text_start = icon_x - icon_margin;
                }
                Gdk.cairo_set_source_pixbuf (cr, window_info.get_icon (), icon_x, icon_y);
            }
            pango.set_font_description (style.get_font (state));
            pango.set_markup ("<big>" + window_info.get_name () + "</big>", -1);
            int text_x, text_y, text_w, text_h;
            var text_margin = icon_margin; 
            pango.get_pixel_size (out text_w, out text_h);
            text_y = h / 2 - text_h / 2; 
            oversize = false;
            if (dir == TextDirection.LTR) {
                text_x = text_start; 
                if (text_x + text_w > w)
                    oversize = true;
            } else {
                text_x = text_start - text_w; 
                if (text_x < 0) {
                    text_x = Margin;
                    oversize = true;
                }
            }
            Gtk.render_layout (style, cr, text_x, text_y, pango);

            cr.paint ();
        }
        return true;
    }

    public void show_popup (Gdk.EventButton event) {
        var menu = new Wnck.ActionMenu (window_info);

        var button = event.button;
        var event_time = event.time;

        menu.deactivate.connect (() => {
            popup_shown = false;
        });
        menu.attach_to_widget (this, null);

        popup_shown = true;
        menu.popup (null, null, null, button, event_time);
    }


}

public class PanelWindowHost : PanelAbstractWindow {
    private bool active;
    private HBox box;
    private new Wnck.Screen screen;
    private int num_visible_windows = 0;
    private HashMap <Wnck.Window, PanelWindowEntry> entry_map ;
    private int height = 12;

    public signal void windows_gone();
    public signal void windows_visible();

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
        show();
        var r = rect();
        move (0, r.height - get_window ().get_height ());

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
            if (e != null) {
                e.destroy ();
                entry_map.unset (w);
            }
        });

        screen.active_workspace_changed.connect (() => {
            update (true);
        });

        enter_notify_event.connect (() => {
            // Only resize if there are visible windows
            if (entry_map.size > 0) {
                resize (Size.Big);
            }
            return false;
        });

        leave_notify_event.connect ((e) => {
            int x, y;
            get_window ().get_position (out x, out y);
            // If e.y is negative then it's outside the area
            if (e.y < 0) {
                resize (Size.Small);
            }
            return false;
        });
    }

    private new void resize (Size size) {
        height = size;
        queue_resize ();
        get_window ().move_resize (rect ().x, rect ().height - size, rect ().width, size);
        var draw_info = false;
        if (size == Size.Big) {
            draw_info = true;
        }
        foreach (PanelWindowEntry e in entry_map.values) {
            e.draw_info = draw_info;
        }
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
                    e = new PanelWindowEntry (w);
                    entry_map.set (w, e);
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
}
