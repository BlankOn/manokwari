using Gtk;
using Cairo;
using Wnck;
using Gee;

public class PanelWindowPager : PanelAbstractWindow {
    public signal void hidden ();
    private bool _cancel_hiding;
    private ToggleButton desktop;

    bool allow_hiding () {
        _cancel_hiding = false;
        return false;
    }

    public void cancel_hiding() {
        _cancel_hiding = true;
        GLib.Timeout.add (250, allow_hiding); 
    }

    bool hide_pager () {
        if (_cancel_hiding)
            return false;

        hide ();
        hidden ();
        return false;
    }

    public void reset_show_desktop () {
        desktop.set_active (false);
    }

    public PanelWindowPager () {
        var box = new HBox (false, 0);
        var pager = new Wnck.Pager ();
        add (box);
        box.pack_start (pager, false, false, 0);
        pager.show ();

        var icon = new Image.from_icon_name ("user-desktop", IconSize.LARGE_TOOLBAR);
        desktop = new ToggleButton ();
        desktop.set_tooltip_text (_("Click here to hide all windows and show desktop"));
        desktop.add(icon);
        box.pack_start (desktop, true, true, 0);
        desktop.show_all ();

        box.show ();

        set_type_hint (Gdk.WindowTypeHint.DOCK);
        hide();

        desktop.toggled.connect (() => {
            Wnck.Screen screen = Wnck.Screen.get_default ();
            screen.toggle_showing_desktop (desktop.get_active ());
        });

        leave_notify_event.connect (() => {
            hide_pager (); 

            return true; 
        });

        map_event.connect (() => {
            move (rect ().x, rect ().y + rect ().height -  get_window ().get_height ());
            get_window ().raise ();
            return false;
        });
    }


    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = 50; 
    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = 200;
    }

}

public class PanelWindowPagerEntry : DrawingArea {
    private PanelWindowPager pager;
    private Gdk.Rectangle rect;

    public signal void pager_shown ();

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
            pager.show_all ();
            pager_shown ();
            pager.cancel_hiding ();
            return false; 
        });

    }

    public void reset_show_desktop () {
        // Forward to pager
        pager.reset_show_desktop ();
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

    public void sync_window_states () {
        if (window_info.is_minimized ()) {
            state = StateFlags.INSENSITIVE;
        } else if (window_info.is_active()) {
            state = StateFlags.ACTIVE;
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
                    window_info.activate (get_current_event_time());
                }
                sync_window_states ();
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

    public signal void windows_gone (); // Emitted when all windows have gone, either closed or minimized
    public signal void windows_visible (); // Emitted when there is at least one window visible
    public signal void all_windows_visible (); // Emitted when all normal windows visible

    enum Size {
        SMALL = 12,
        BIG = 50
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
        reposition ();

        set_struts(); 

        screen_size_changed.connect (() => {
            reposition ();
        });

        screen.window_opened.connect ((w) => {
            if (!w.is_skip_tasklist()) {
                w.activate (get_current_event_time());
                update (true);

                w.state_changed.connect(() => {
                    update (true);
                });

                w.workspace_changed.connect(() => {
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


        screen.active_window_changed.connect (() => {
            foreach (PanelWindowEntry e in entry_map.values) {
                e.sync_window_states ();
            }
        });

        screen.active_workspace_changed.connect (() => {
            update (true);
        });

        enter_notify_event.connect (() => {
            // Only resize if there are visible windows
            if (entry_map.size > 0) {
                resize (Size.BIG);
            }
            return false;
        });

        leave_notify_event.connect ((e) => {
            int x, y;
            get_window ().get_position (out x, out y);
            // If e.y is negative then it's outside the area
            if (e.y < 0) {
                resize (Size.SMALL);
            }
            return false;
        });

        all_windows_visible.connect (() => {
            pager_entry.reset_show_desktop ();
        });

        configure_event.connect (() => {
            if (get_window ().get_height () == Size.SMALL) {
                set_struts(); 
            }
            return false;
        });
    }

    private new void resize (Size size) {
        height = size;
        queue_resize ();
        get_window ().move_resize (rect ().x, rect ().height - size, rect ().width, size);
        var draw_info = false;
        if (size == Size.BIG) {
            draw_info = true;
            stdout.printf("%d %d\n", size, get_window().get_height());
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

        foreach (unowned Widget w in box.get_children ()) {
            if (w is PanelWindowEntry)
                box.remove (w);
        }

        var num_total_windows = 0;
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
                num_total_windows ++;
            }
        }
        if (emit_change_signals) {
            if (num_windows == 0) {
                resize (Size.SMALL); 
                windows_gone ();
            } else {
                windows_visible ();
            }

            if (num_windows == num_total_windows)
                all_windows_visible ();
        }
        num_visible_windows = num_windows;
    }

    public new void reposition () {
        move (rect ().x, rect ().y + rect ().height - get_window ().get_height ());
        queue_resize ();
    }

    public void dismiss () {
        resize (Size.SMALL);
    }
}
