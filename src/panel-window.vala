using Gtk;
using Cairo;
using Wnck;
using Gee;

public class PanelWindowPager : PanelAbstractWindow {
    public signal void hidden ();
    private bool _cancel_hiding;
    private ToggleButton desktop;

    public void reset_show_desktop () {
        desktop.set_active (false);
    }

    public PanelWindowPager () {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        var box = new VBox (false, 0);
        var pager = new Wnck.Pager ();
        pager.set_orientation (Orientation.VERTICAL);
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

        hide();

        desktop.toggled.connect (() => {
            Wnck.Screen screen = Wnck.Screen.get_default ();
            screen.toggle_showing_desktop (desktop.get_active ());
        });

        leave_notify_event.connect (() => {

            dismiss ();
            return true; 
        });

        map_event.connect (() => {
            PanelScreen.move_window (this, Gdk.Gravity.NORTH_EAST);
            get_window ().raise ();
            Utils.grab (this);
            return true;
        });
    }


    public override void get_preferred_width (out int min, out int max) {
        min = max = 80;
    }

    private void dismiss () {
        hide ();
        Utils.ungrab (this);
    }
}

public class PanelWindowPagerEntry : DrawingArea {
    private PanelWindowPager pager;
    private Gdk.Pixbuf icon = null;

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

        var icon_theme = IconTheme.get_default ();
        try {
            icon = icon_theme.load_icon ("user-desktop", 32, 0);
        } catch (Error e) {
            stderr.printf ("Unable to load icon 'user-desktop': %s\n", e.message);
        }
        pager = new PanelWindowPager ();
        show ();

        button_press_event.connect ((event) => {
            pager.show_all ();
            pager_shown ();
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
        int w = get_window ().get_width ();
        int h = get_window ().get_height ();
        Gtk.render_background (style, cr, 0, 0, w, h);
        if (icon != null)
            Gdk.cairo_set_source_pixbuf (cr, icon, (w - icon.width) / 2, (h - icon.height) / 2);
        cr.paint ();
        return true;
    }

}

public class PanelWindowEntry : DrawingArea {
    private Wnck.Window window_info;
    private Wnck.WindowState last_state;
    private Gtk.StateFlags state;
    private bool popup_shown = false;
    private Pango.Layout pango;
    private int Margin = 5;
    private bool oversize = false;

    const TargetEntry[] target_list = {
        { "STRING",     0, 0 }
    };

    public bool draw_info { private get; set; default = false; }

    public bool is_on_current_workspace () {
        return window_info.is_on_workspace (window_info.get_screen ().get_active_workspace());
    }

    public void sync_window_states () {
        if (window_info.is_minimized ()) {
            state = StateFlags.INSENSITIVE;
        } else if (window_info.is_active()) {
            state = StateFlags.ACTIVE;
        } else if (window_info.needs_attention ()) {
            state = StateFlags.SELECTED;
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

        Gtk.drag_dest_set (
                this,
                DestDefaults.MOTION,
                target_list,
                Gdk.DragAction.COPY
                );

        window_info.state_changed.connect((mask, new_state) => {
            if (new_state == last_state)
                return;

            sync_window_states ();
        });

        window_info.name_changed.connect(() => {
            queue_draw ();
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
            return false; 
        });

        drag_motion.connect (() => {
            var w = get_toplevel ();
            if (w is PanelWindowHost) {
                ((PanelWindowHost) w).activate ();
            }
            window_info.activate (get_current_event_time());
            sync_window_states ();
            return false;
        });
    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = Margin * 2 + 100; 
    }

    public override void get_preferred_width (out int min, out int max) {
        max = PanelScreen.get_primary_monitor_geometry ().width;
        min = Margin * 2;
    }

    public override bool draw (Context cr) {
        StyleContext style = get_style_context ();
        style.set_state (state);

        Gtk.render_background (style, cr, 0, 0, get_allocated_width (), get_allocated_height ()); 
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
    private Image image;
    private PanelClock clock;
    private bool active;
    private HBox box;
    private PanelTray tray;
    private new Wnck.Screen screen;
    private int num_visible_windows = 0;
    private HashMap <Wnck.Window, PanelWindowEntry> entry_map ;
    private int height = 12;

    public signal void windows_gone (); // Emitted when all windows have gone, either closed or minimized
    public signal void windows_visible (); // Emitted when there is at least one window visible
    public signal void all_windows_visible (); // Emitted when all normal windows visible
    public signal void dialog_opened (); // Emitted when a dialog is opened
    public signal void menu_clicked (); // Emitted when the menu is clicked

    public signal void activated (); // Emitted when the window host is activated (the size is getting bigger)

    public signal void resized (int size); // Emitted when the window is resized
    enum Size {
        SMALL = 22,
        BIG = 34
    }

    public bool no_windows_around () {
        update (false);
        return (num_visible_windows == 0);
    }

    public PanelWindowHost () {
        image = new Image.from_icon_name("distributor-logo", IconSize.LARGE_TOOLBAR);
        var event_box = new EventBox();
        event_box.add (image);
        event_box.show_all ();

        entry_map = new HashMap <Wnck.Window, PanelWindowEntry> (); 

        tray = new PanelTray ();
        tray.show ();

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

        var clock = new PanelClock ();
        clock.show ();

        var a = new Alignment(0, 0.5f, 0, 0);
        a.add (clock);
        a.show ();

        var clock_event = new EventBox ();
        clock_event.show_all ();
        clock_event.add (a);


        var calendar = new PanelCalendar ();
        calendar.hide ();

        resized.connect((size) => {
            calendar.update_position (size);
        });

        outer_box.pack_end (pager_entry, false, false, 1);
        outer_box.pack_end (clock_event, false, false, 0);
        outer_box.pack_end (tray, false, false, 0);
        outer_box.pack_start (event_box, false, false, 0);
        outer_box.pack_start (box, true, true, 0);
        outer_box.show ();
        box.show();

        show();
        reposition ();

        set_struts(); 

        screen_size_changed.connect (() => {
            queue_resize ();
            reposition ();
        });

        screen.window_opened.connect ((w) => {
            if (!w.is_skip_tasklist()) {
                w.activate (get_current_event_time());
                update (true);

                w.workspace_changed.connect(() => {
                    update (true);
                });
            }

            if (w.get_window_type () == Wnck.WindowType.DIALOG) {
                dialog_opened ();
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

        screen.viewports_changed.connect (() => {
            update (true);
        });

        screen.active_workspace_changed.connect (() => {
            update (true);
        });

        enter_notify_event.connect (() => {
            resize (Size.BIG);
            activated ();
            return false;
        });

        leave_notify_event.connect ((e) => {
            int x, y;
            get_window ().get_position (out x, out y);
            // If e.y is negative then it's outside the area
            if (e.y > height) {
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

        event_box.button_press_event.connect (() => {
            menu_clicked ();
            resize (Size.SMALL);
            return false;
        });

        clock_event.button_release_event.connect(() => {
            if (calendar.visible) {
                calendar.hide ();
            } else {
                calendar.show_all ();
            }

            return true;
        });


    }

    private new void resize (Size size) {
        height = size;
        queue_resize ();
        set_size_request (PanelScreen.get_primary_monitor_geometry ().width, size);
        var draw_info = false;
        if (size == Size.BIG) {
            draw_info = true;
        }
        foreach (PanelWindowEntry e in entry_map.values) {
            e.draw_info = draw_info;
        }
        image.set_pixel_size (size);
        reposition();
        resized (size);
    }

    public override void get_preferred_width (out int min, out int max) {
        var r = PanelScreen.get_primary_monitor_geometry ().width;
        min = max = r;
    }

    public override void get_preferred_height (out int min, out int max) {
        min = max = height; 
    }

    public void update (bool emit_change_signals) {

        foreach (unowned Widget w in box.get_children ()) {
            if (w is PanelWindowEntry)
                box.remove (w);
        }

        var workspace = screen.get_active_workspace ();
        if (workspace == null)
            return;
        var num_total_windows = 0;
        var num_windows = 0;
        foreach (unowned Wnck.Window w in screen.get_windows()) {
            if (!w.is_skip_tasklist () 
              && (w.get_name() != "_manokwari_menu_")
              && w.is_on_workspace (workspace)) {
                var e = entry_map [w];
                if (e == null) {
                    e = new PanelWindowEntry (w);
                    entry_map.set (w, e);
                }
                if (!w.is_minimized ())
                    num_windows ++;
                num_total_windows ++;
            }
        }

        foreach (PanelWindowEntry e in entry_map.values) {
            if (height == Size.BIG) {
                e.draw_info = true;
            }
            if (e.is_on_current_workspace ()) {
                e.show ();
                box.pack_start (e, true, true, 1);
            }
        }
        if (emit_change_signals) {
            if (num_windows == 0) {
                windows_gone ();
            } else {
                windows_visible ();
            }
            resize (Size.SMALL); 

            if (num_windows == num_total_windows)
                all_windows_visible ();
        }
        num_visible_windows = num_windows;
    }

    public new void reposition () {
        PanelScreen.move_window (this, Gdk.Gravity.NORTH_WEST);
        set_keep_above(false);
    }

    public void dismiss () {
        resize (Size.SMALL);
    }

    public new void activate () {
        resize (Size.BIG);
    }
}
