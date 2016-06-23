using Gtk;

public class PanelMenuBox : PanelAbstractWindow {
    private const int COLUMN_WIDTH = 265;

    public signal void dismissed ();
    public signal void shown ();
    public signal void about_to_show_content ();
    PanelMenuHTML view;

    public PanelMenuBox () {
        try {
        var bus = Bus.get_sync (GLib.BusType.SESSION);
        bus.signal_subscribe (null,
                "org.gtk.gio.DesktopAppInfo",
                "Launched",
                "/org/gtk/gio/DesktopAppInfo",
                null,
                0,
                dismiss);
        } catch (Error e) {
            stderr.printf ("Unable to subscribe to desktop launcher's \"Launched\" signal: %s\n", e.message);
        }

        view = new PanelMenuHTML ();
        view.show_all ();
        add (view);
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        set_title ("_manokwari_menu_");
        set_visual (this.screen.get_rgba_visual ());

        Gdk.RGBA c = Gdk.RGBA();
        c.red = 0.0;
        c.blue = 0.0;
        c.green = 0.0;
        c.alpha = 0.0;
        override_background_color(StateFlags.NORMAL, c);
        set_app_paintable(true);

        PanelScreen.move_window (this, Gdk.Gravity.NORTH_WEST);
        view.start();

        hide ();

        button_press_event.connect((event) => {

        stdout.printf("xxx\n");
            // Only dismiss if within the area
            // TODO: multihead
            if (event.x > get_window().get_width ()) {
                dismiss ();
                return true;
            }
            return false;
        });

        screen_size_changed.connect (() =>  {
            PanelScreen.move_window (this, Gdk.Gravity.NORTH_WEST);
            queue_resize ();
        });

        map_event.connect (() => {
            shown ();
            PanelScreen.move_window (this, Gdk.Gravity.NORTH_WEST);
            get_window ().raise ();
            Utils.grab (this);
            view.triggerShowAnimation();
            return true;
        });

        key_press_event.connect ((e) => {
            if (Gdk.keyval_name(e.keyval) == "Escape") {
                if (view.handleEsc () == false) {
                    dismiss ();
                }
            } else if (Gdk.keyval_name(e.keyval) == "Print") {
                if (Utils.print_screen () == false) {
                    stdout.printf ("Unable to take screenshot\n");
                }
            }
            return false;
        });

    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = COLUMN_WIDTH;
    }

    public override void get_preferred_height (out int min, out int max) {
        min = max = PanelScreen.get_primary_monitor_geometry ().height; 
    }

    private void dismiss () {
        if (visible) {
            stdout.printf("Menu box dismissed \n");
            Utils.ungrab (this);
            try_hide ();
        }
    }

    bool real_hide () {
        hide ();
        return false;
    }

    public void try_hide () {
        view.triggerHideAnimation();
        GLib.Timeout.add (500, real_hide);
        dismissed ();
    }
}
