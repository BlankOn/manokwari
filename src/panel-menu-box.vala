using Gtk;

public class PanelMenuBox : PanelAbstractWindow {
    private const int COLUMN_WIDTH = 320;

    public signal void dismissed ();
    public signal void about_to_show_content ();
    PanelMenuHTML view;

    public PanelMenuBox () {
        view = new PanelMenuHTML ();
        view.show_all ();
        add (view);
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        set_title ("_blankon_panel_menu_");
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

        // Monitor changes to the directory

        var xdg_menu_dir = File.new_for_path ("/etc/xdg/menus");
        try {
            var xdg_menu_monitor = xdg_menu_dir.monitor (FileMonitorFlags.NONE, null);
            xdg_menu_monitor.changed.connect (() => {
            });
        } catch (Error e) {
            stdout.printf ("Can't monitor /etc/xdg/menus directory: %s\n", e.message);
        }

        var apps_dir = File.new_for_path ("/usr/share/applications");
        try {
            var apps_monitor = apps_dir.monitor (FileMonitorFlags.NONE, null);
            apps_monitor.changed.connect (() => {
            });
        } catch (Error e) {
            stdout.printf ("Can't monitor applications directory: %s\n", e.message);
        }

        button_press_event.connect((event) => {
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
            PanelScreen.move_window (this, Gdk.Gravity.NORTH_WEST);
            get_window ().raise ();
            Utils.grab (this);
            view.triggerShowAnimation();
            return true;
        });

        key_press_event.connect ((e) => {
            if (Gdk.keyval_name(e.keyval) == "Print") {
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
        stdout.printf("Menu box dismissed \n");
        view.triggerHideAnimation();
        Utils.ungrab (this);
        GLib.Timeout.add (500, try_hide);
    }

    bool try_hide () {
        hide ();
        return false;
    }
}
