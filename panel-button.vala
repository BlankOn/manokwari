using Gtk;
using Cairo;
using GMenu;

public class PanelButtonWindow : PanelAbstractWindow {

    private PanelMenuBox menu_box;
    private Gdk.Pixbuf logo;
    private bool ignore_enter_notify;

    public signal void menu_shown ();

    public PanelButtonWindow() {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        add_events (Gdk.EventMask.STRUCTURE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        menu_box = new PanelMenuBox();
        set_visual (this.screen.get_rgba_visual ());

        set_size_request (40,40);
        set_keep_above(true);

        Gdk.RGBA c = Gdk.RGBA();
        c.red = 0.0;
        c.blue = 0.0;
        c.green = 0.0;
        c.alpha = 0.0;
        override_background_color(StateFlags.NORMAL, c);
        set_app_paintable(true);
        
        show ();
        move (rect ().x, rect ().y);

        var icon_theme = IconTheme.get_default();
        logo = icon_theme.load_icon ("distributor-logo", 30, IconLookupFlags.GENERIC_FALLBACK);

        // Window 
        var w = new PanelWindowHost ();
        w.show();
        if (w.no_windows_around ())
            show_menu_box ();

        var tray = new PanelTrayHost ();
        tray.show ();

        // SIGNALS
        leave_notify_event.connect (() => {
            // This will be visited when the
            // menu box is opened and the button got restacked
            // Make sure the next enter notify without prior
            // visit to here will be ignored
            if (ignore_enter_notify) {
                ignore_enter_notify = false;
            } else {
                ignore_enter_notify = true;
            }
            return true;
        });

        enter_notify_event.connect (() => {
            // This will be visited when 
            // the menu box is opened, and the button got restacked
            // so ignore this when it happens.
            if (ignore_enter_notify) {
                return true;
            }
            show_menu_box (); 
            ignore_enter_notify = true;
            return true;
        });

        button_press_event.connect (() => {
            if (menu_box.visible) {
                // If menu_box is visible and showing first column, 
                // then we want it to be closed when we got here.

                // But refuse to close it when there's no windows around
                if (menu_box.get_active_column () == 0 
                    && w.no_windows_around ())
                    return false;
                
                // If it's showing second column, just go back to 
                // first column
                if (menu_box.get_active_column () == 1) {
                    menu_box.slide_left ();
                    return true;
                }

                // Close it otherwise
                menu_box.hide ();
            } else {
                // Otherwise we want to show it
                show_menu_box ();
            }

           return true;
        });

        w.windows_gone.connect (() => {
        stdout.printf ("all windows gone\n");
            show_menu_box ();
        });

        menu_box.dismissed.connect (() => {
            if (w.no_windows_around ())
                return;
            menu_box.hide ();
        });

        w.windows_visible.connect (() => {
            if (menu_box.visible) 
                menu_box.hide ();
        });

        menu_shown.connect (() => {
            w.dismiss ();
        });
    }

    public override bool draw (Context cr)
    {

        if (logo != null)
            Gdk.cairo_set_source_pixbuf (cr, logo, 0, 0);
        cr.paint();
        return false;
    }

    private bool show_menu_box () {
        menu_box.show_all ();
        get_window ().raise ();
        menu_box.get_window ().lower ();
        menu_shown ();
        return false;
    }

}

