using Gtk;

public class PanelDesktopIdle: PanelAbstractWindow {

    string background_path = "";
    PanelDesktopIdleView idle;

    public PanelDesktopIdle() {
        set_visual (this.screen.get_rgba_visual ());

        Gdk.RGBA c = Gdk.RGBA();
        c.red = 0.0;
        c.blue = 0.0;
        c.green = 0.0;
        c.alpha = 0.0;
        override_background_color(StateFlags.NORMAL, c);
        set_app_paintable(true);

        idle = new PanelDesktopIdleView ();
        idle.hide ();
        set_type_hint (Gdk.WindowTypeHint.DIALOG);
        
        var screen = Gdk.Screen.get_default ();
        var root = screen.get_root_window ();
        set_size_request (root.get_width (), root.get_height ());
        add (idle);

        move (0, 0);
    
        idle.motion_notify_event.connect (() => {
            deactivate ();
            return false;
        });

        idle.button_press_event.connect (() => {
            deactivate ();
            return false;
        });


        background_path = Environment.get_home_dir () + "/.config/manokwari/idle-background";
        var background = File.new_for_path (background_path);
        try {
            var background_monitor = background.monitor (FileMonitorFlags.NONE, null);
            background_monitor.changed.connect(() => {
                idle.set_background (background_path);        
            });
        } catch (Error e) {
            stdout.printf ("Can't monitor idle background file: %s\n", e.message);
        }
    }

    public void activate () {
        idle.set_background (background_path);        
        show_all ();
        idle.triggerShowAnimation();
        fullscreen ();
    }

    void deactivate () {
        idle.triggerHideAnimation();
        GLib.Timeout.add (1000, real_hide);
    }

    bool real_hide () {
        hide ();
        return false;
    }
}

