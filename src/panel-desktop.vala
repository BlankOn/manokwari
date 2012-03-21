using Gtk;
using Cairo;
using GMenu;


public class PanelDesktop: PanelAbstractWindow {

    PanelDesktopHTML desktop;
    PanelDesktopIdle idle;

    public signal void desktop_clicked();

    public PanelDesktop() {
        set_visual (this.screen.get_rgba_visual ());

        Gdk.RGBA c = Gdk.RGBA();
        c.red = 0.0;
        c.blue = 0.0;
        c.green = 0.0;
        c.alpha = 0.0;
        override_background_color(StateFlags.NORMAL, c);
        set_app_paintable(true);

        desktop = new PanelDesktopHTML ();
        desktop.show ();

        idle = new PanelDesktopIdle ();

        set_type_hint (Gdk.WindowTypeHint.DESKTOP);
        
        var screen = Gdk.Screen.get_default ();
        var root = screen.get_root_window ();
        set_size_request (root.get_width (), root.get_height ());
        add (desktop);

        move (0, 0);
        show_all ();
    
        desktop.button_press_event.connect (() => {
            desktop_clicked ();
            return false;
        });

        desktop.idle_activated.connect (() => {
            idle.activate();
        });
    }

}

