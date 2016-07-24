using Gtk;
using Cairo;
using Wnck;
using Gee;
using Notify;

public class PanelWindowPager : PanelAbstractWindow {
    public signal void hidden ();
    private ToggleButton desktop;

    public void reset_show_desktop () {
        desktop.set_active (false);
    }

    public PanelWindowPager () {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        var box = new Box (Gtk.Orientation.VERTICAL, 0);
        var pager = new Wnck.Pager ();
        pager.set_orientation (Orientation.VERTICAL);
        add (box);
        box.pack_start (pager, false, false, 0);
        pager.show ();

        var icon = new Image.from_icon_name ("user-desktop-symbolic", IconSize.LARGE_TOOLBAR);
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
        get_style_context().add_class("manokwari-panel");
        get_style_context().remove_class("background");
        add_events (Gdk.EventMask.STRUCTURE_MASK
            | Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK);

        var icon_theme = IconTheme.get_default ();
        try {
            icon = icon_theme.load_icon ("user-desktop-symbolic", 24, 0);
        } catch (Error e) {
            stderr.printf ("Unable to load icon 'user-desktop-symbolic': %s\n", e.message);
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
        style.render_background (cr, 0, 0, w, h);
        if (icon != null)
            Gdk.cairo_set_source_pixbuf (cr, icon, (w - icon.width) / 2, (h - icon.height) / 2);
        cr.paint ();
        return true;
    }

}

public class PanelWindowEntry : DrawingArea {
    unowned Gdk.Pixbuf icon = null;
    public unowned Wnck.Window window_info;
    private Wnck.WindowState last_state;
    private Gtk.StateFlags state;
    private bool popup_shown = false;
    private Pango.Layout pango;
    private int Margin = 5;
    private bool oversize = false;
    int iconWidth = 24;


    public signal void entered ();
    public signal void left ();

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
        get_style_context().add_class("manokwari-panel");
        get_style_context().remove_class("background");
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
            left ();
            return false;
        });
        enter_notify_event.connect ((event) => {
            state = StateFlags.PRELIGHT;
            queue_draw ();
            if (oversize)
                set_tooltip_text (window_info.get_name ());
            else
                set_tooltip_text ("");
            entered ();
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

    void update_icon () {
        icon = window_info.get_mini_icon ();
        if (icon == null) {
            icon = window_info.get_icon ();
        }
    }
 
    public override void get_preferred_height (out int min, out int max) {
        update_icon ();
        // TODO
        if (icon != null) {
            min = max = icon.get_width () + Margin * 2;
        } else {
            min = max = Margin; 
        }
    }

    public override void get_preferred_width (out int min, out int max) {
        get_preferred_height (out min, out max); 
    }

    public override bool draw (Context cr) {
        StyleContext style = get_style_context ();
        style.set_state (state);

        style.render_background (cr, 0, 0, get_allocated_width (), get_allocated_height ()); 

        update_icon ();

        if (icon != null) {
            Gdk.cairo_set_source_pixbuf (cr, icon, Margin, Margin);
        }

        cr.paint ();
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

public class PanelWindowEntryDescriptions : PanelAbstractWindow {
    ArrayList <PanelWindowEntry> stack;
    unowned HashMap <Wnck.Window, unowned PanelWindowEntry> entry_map;
    HashMap <unowned PanelWindowEntry, int> position_map;
    unowned PanelWindowEntry active_entry = null;
    unowned PanelWindowEntry old_entry = null;
    private Pango.Layout pango;
    bool hiding = false;
    AnimatedProperty anim;
    uint hiding_timeout = 0;

    public double offset {
        get; set; default = 0;
    }

    public PanelWindowEntryDescriptions (HashMap <Wnck.Window, PanelWindowEntry> entry_map) {
        get_style_context().add_class("manokwari-panel-window-names");
        get_style_context().remove_class("background");
        pango = new Pango.Layout (get_pango_context ());
        stack = new ArrayList<PanelWindowEntry>();
        position_map = new HashMap<PanelWindowEntry, int> ();
        this.entry_map = entry_map;
        set_type_hint (Gdk.WindowTypeHint.DOCK);

        set_app_paintable(true);
        
        hide ();
        PanelScreen.move_window (this, Gdk.Gravity.NORTH_WEST);

        anim = new AnimatedProperty (this);
        anim.set_property ("offset");
        
        anim.frame.connect (() => {
            queue_draw ();
        });
    }

    public void clear_entry (PanelWindowEntry e) {
        position_map.unset (e);
    }

    public override void get_preferred_height (out int min, out int max) {
        min = max = 34; 
    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = PanelScreen.get_primary_monitor_geometry ().width;
    }

    int drawInfo (Context cr, StyleContext style, Gtk.StateFlags state, Gdk.Pixbuf? icon, string text, int start, bool backward = false) {
        var dir = get_direction ();
        int icon_x = 0, icon_y = 0, icon_width = 0;

        style.set_state (state);
        if (icon != null) {
            icon_width = icon.get_width ();
        }
        pango.set_font_description (style.get_font (state));
        pango.set_markup ("<big>%s</big>".printf (text), -1);
      
        var h = get_window ().get_height (); 
        var icon_margin = 5;

        int text_x, text_y, text_w, text_h;
        pango.get_pixel_size (out text_w, out text_h);
        text_y = h / 2 - text_h / 2; 

        if (backward) {
            icon_x = start - (icon_margin * 2 + icon_width + text_w);
            if (dir == TextDirection.LTR) {
                text_x = start - (icon_margin + text_w);
            } else {
                text_x = start; 
            }
        } else {
            icon_x = start;
            if (dir == TextDirection.LTR) {
                text_x = start + icon_width + icon_margin;
            } else {
                text_x = start; 
            }
        }

        var occupied = icon_margin * 3 + text_w + icon_width;
        style.render_background (cr, icon_x + offset - icon_margin, 0, occupied, get_allocated_height ()); 
        if (icon != null) {
            Gdk.cairo_set_source_pixbuf (cr, icon, icon_x + offset, 0);
        }
        style.render_layout (cr, text_x + offset, text_y, pango);

        if (state == StateFlags.NORMAL) {
            cr.paint_with_alpha (0.3);
        } else {
            cr.paint ();
        }

        var new_start = occupied + start;
        if (backward) {
            return start - new_start;
        } else {
            return new_start;
        }
    }

    public override bool draw (Context cr) {
        StyleContext style = get_style_context ();

        var state = StateFlags.NORMAL;

        stack.clear ();
        style.render_background (cr, 0, 0, get_allocated_width (), get_allocated_height ()); 

        if (active_entry != null)  {
            var start_x = -1;
            var pushing = true;
            var backward_start = -1;

            foreach (unowned PanelWindowEntry e in entry_map.values) {

                if (e.is_on_current_workspace () == false) {
                    continue;
                }
                if (e == active_entry) {
                    state = StateFlags.PRELIGHT;
                    int x, y;
                    e.get_window ().get_position (out x, out y);

                    start_x = x;
                    pushing = false;
                    backward_start = x;
                } else {
                    state = StateFlags.NORMAL;
                    if (pushing) {
                        stack.add (e);
                    }
                }

                if (pushing == false) {
                    var icon = e.window_info.get_icon ();
                    position_map [e] = start_x;
                    start_x = drawInfo (cr, style, state, icon, e.window_info.get_name (), start_x);
                }
            }

            start_x = backward_start;
            state = StateFlags.NORMAL;
            while (stack.size > 0) {
                PanelWindowEntry? e = stack.remove_at (stack.size - 1);
                if (e == null) {
                    break;
                }

                var icon = e.window_info.get_icon ();
                start_x = drawInfo (cr, style, state, icon, e.window_info.get_name (), start_x, true);
                position_map [e] = start_x;
            }
        }

        return true;
    }

    public new void activate (PanelWindowEntry e) {
        hiding = false;
        old_entry = active_entry;
        active_entry = e;
        if (get_visible () == false) {
            show_all ();
        } else {
            queue_draw ();
        }

        int start = position_map [e];
        int end = 0;

        offset = 0;
        if (old_entry != null) {
            end = position_map [old_entry];
            offset = start - end;
        }

        anim.set_final_value (0);
        anim.start ();
    }

    public void deactivate () {
        try_hide ();
    }

    public void try_hide () {
        if (hiding_timeout != 0) {
          GLib.Source.remove(hiding_timeout);
        }
        hiding_timeout = GLib.Timeout.add (250, real_hide);
        hiding = true;
    }

    public void slow_hide () {
        if (hiding_timeout != 0) {
          GLib.Source.remove(hiding_timeout);
        }
        hiding_timeout = GLib.Timeout.add (1000, real_hide);
        hiding = true;
    }


    bool real_hide () {
        if (hiding == true) {
            hide ();
        }
        hiding_timeout = 0;
        return false;
    }


    public void update_position (int y) {
        queue_resize ();
        var g = PanelScreen.get_primary_monitor_geometry ();
        move (g.x, g.y + y);
    }

    public void cycle() {
        Wnck.Screen screen = Wnck.Screen.get_default ();
        var current = screen.get_active_window();
        unowned Wnck.Window first = null;
        bool next = false;
        unowned Wnck.Window selected = null;
        foreach (Wnck.Window w in entry_map.keys) {
          if (entry_map[w].is_on_current_workspace () == false) {
            continue;
          }
          if (first == null) {
              first = w;
          }
          if (next == true) {
              selected = w;
              break;
          }
          if (current == w) {
              next = true;
          } else {
              next = false;
          } 
        }
        if (selected == null) {
            selected = first;
        }

        if (selected == null) return;

        var e = entry_map[selected];
        if (e != null) {
            activate(e);
            selected.activate(get_current_event_time());
            slow_hide();
        }
    }
}

public class PanelWindowHost : PanelAbstractWindow {
    private Image logo;
    private bool active;
    private Box box;
    private PanelTray tray;
    private new Wnck.Screen screen;
    private int num_visible_windows = 0;
    const string BRIGHTNESS_PROP_IFACE = "org.gnome.SettingsDaemon.Power.Screen";
    const string BRIGHTNESS_PROP_NAME = "Brightness";
    private HashMap <unowned Wnck.Window, unowned PanelWindowEntry> entry_map ;
    private int height = 24;
    PanelWindowEntryDescriptions descriptions;
    PanelCalendar calendar;
    PanelHotkey hotkey;
    DBusProperties bus;
    Notify.Notification indicator;

    public signal void windows_gone (); // Emitted when all windows have gone, either closed or minimized
    public signal void windows_visible (); // Emitted when there is at least one window visible
    public signal void all_windows_visible (); // Emitted when all normal windows visible
    public signal void dialog_opened (); // Emitted when a dialog is opened
    public signal void menu_clicked (); // Emitted when the menu is clicked

    public signal void activated (); // Emitted when the window host is activated (the size is getting bigger)

    public bool no_windows_around () {
        update (false);
        return (num_visible_windows == 0);
    }

    public PanelWindowHost () {
        try {
            bus = Bus.get_proxy_sync (BusType.SESSION, "org.gnome.SettingsDaemon.Power", "/org/gnome/SettingsDaemon/Power");
        } catch (Error e) {
            stderr.printf ("Unable to connect to power manager\n");
        }


        indicator = new Notify.Notification("Manokwari", "", Utils.get_icon_path("display-brightness"));
        indicator.set_timeout(5);
        Notify.init ("Manokwari");

        hotkey = new PanelHotkey();

        hotkey.bind("<Alt>Tab");
        hotkey.bind("Print");
        hotkey.bind("<Mod4>x");
        hotkey.bind("MonBrightnessUp");
        hotkey.bind("MonBrightnessDown");
        hotkey.triggered.connect((key) => {
          handleKey(key);
        });
        
        logo = new Image.from_icon_name("distributor-logo", IconSize.LARGE_TOOLBAR);
        var event_box = new EventBox();
        event_box.add (logo);
        event_box.show_all ();

        logo.set_pixel_size (height);

        entry_map = new HashMap <Wnck.Window, PanelWindowEntry> (); 

        tray = new PanelTray ();
        tray.show ();

        num_visible_windows = 0;
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        active = false;
        screen = Wnck.Screen.get_default ();
        var outer_box = new Box (Gtk.Orientation.HORIZONTAL, 0);
        box = new Box (Gtk.Orientation.HORIZONTAL, 1);
        get_style_context().add_class("manokwari-panel");
        get_style_context().remove_class("background");
        add(outer_box);

        var pager_entry = new PanelWindowPagerEntry ();
        pager_entry.set_name ("PAGER");
        pager_entry.show ();

        descriptions = new PanelWindowEntryDescriptions (entry_map);
        descriptions.update_position (height);

        var clock = new PanelClock ();
        clock.show ();

        var a = new Alignment(0, 0.5f, 0, 0);
        a.add (clock);
        a.show ();

        var clock_event = new EventBox ();
        clock_event.show_all ();
        clock_event.add (a);

        calendar = new PanelCalendar ();
        calendar.update_position (height);
        calendar.hide ();

        outer_box.pack_end (pager_entry, false, false, 1);
        outer_box.pack_end (clock_event, false, false, 0);
        outer_box.pack_end (tray, false, false, 0);
        outer_box.pack_start (event_box, false, false, 6);
        outer_box.pack_start (box, false, false, 0);
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
                descriptions.clear_entry (e);
                e.destroy ();
                entry_map.unset (w);
                update (false);
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
            activated ();
            return false;
        });

        all_windows_visible.connect (() => {
            pager_entry.reset_show_desktop ();
        });

        configure_event.connect (() => {
            set_struts(); 
            return false;
        });

        event_box.button_press_event.connect (() => {
            menu_clicked ();
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
                    e.entered.connect(() => {
                        descriptions.activate(e);
                    });

                    e.left.connect(() => {
                        descriptions.deactivate();
                    });
                }
                if (!w.is_minimized ())
                    num_windows ++;
                num_total_windows ++;
            }
        }

        foreach (PanelWindowEntry e in entry_map.values) {
            if (e.is_on_current_workspace ()) {
                e.show ();
                box.pack_start (e, true, true, 0);
            }
        }
        if (emit_change_signals) {
            if (num_windows == 0) {
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
        PanelScreen.move_window (this, Gdk.Gravity.NORTH_WEST);
        descriptions.update_position (height);
        calendar.update_position (height);
        set_keep_above(false);
    }

    void handleKey(string key) {
    stderr.printf("--------> %s\n", key);
      if (key == "<Alt>Tab") {
        handleWindowCycle();
      }
      else if (key == "<Mod4>x") {
        menu_clicked();
      }
      else if (key == "Print") {
        Utils.print_screen();
      }
      else if (key == "MonBrightnessUp") {
        handleBrightnessUp();
      } else if (key == "MonBrightnessDown") {
        handleBrightnessDown();
      }

    }

    void handleWindowCycle() {
        descriptions.cycle();      
    }


    void showBrightnessIndicator(int value) {
        indicator.set_hint("value", value);
        indicator.show ();
    }

    void handleBrightnessUp() {
        if (bus == null) return;
        var value = bus.get(BRIGHTNESS_PROP_IFACE, BRIGHTNESS_PROP_NAME);
        int32 val = value.get_int32();

        if (val + 10 > 100) {
          val = 100;
        } else {
          val += 10;
        }
        showBrightnessIndicator(val);
        bus.set(BRIGHTNESS_PROP_IFACE, BRIGHTNESS_PROP_NAME, new Variant.int32(val));
    }

    void handleBrightnessDown() {
        if (bus == null) return;
        var value = bus.get(BRIGHTNESS_PROP_IFACE, BRIGHTNESS_PROP_NAME);
        int32 val = value.get_int32();

        if (val - 10 < 10) {
          val = 0;
        } else {
          val -= 10;
        }
        showBrightnessIndicator(val);
        bus.set(BRIGHTNESS_PROP_IFACE, BRIGHTNESS_PROP_NAME, new Variant.int32(val));
    }
}
