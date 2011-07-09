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
        menu_box = new PanelMenuBox();
        set_visual (this.screen.get_rgba_visual ());

        set_size_request (40,40);

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

        // Clock
        var clock = new ClockWindow ();
        clock.show ();

        // SIGNALS
        button_press_event.connect (() => {
            if (menu_box.visible) {
                // If menu_box is visible and showing first column, 
                // then we want it to be closed when we got here.

                // But refuse to close it when there's no windows around
                if (menu_box.get_active_column () == 0 
                    && w.no_windows_around ()) {
                    return false;
                }
                
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
        if (menu_box.visible == false) {
            menu_box.show ();
            get_window ().raise ();
            menu_box.get_window ().lower ();
            menu_shown ();
        }
        return false;
    }

}

