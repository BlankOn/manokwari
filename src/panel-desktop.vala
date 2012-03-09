using Gtk;
using Cairo;
using GMenu;


public class PanelDesktop: PanelAbstractWindow {

    const string BG_KEY = "picture-uri";
    PanelDesktopHTML desktop;
    GLib.Settings settings = null;

    public PanelDesktop() {
        settings = new GLib.Settings ("org.gnome.desktop.background");
        desktop = new PanelDesktopHTML ();
        desktop.show ();
        set_type_hint (Gdk.WindowTypeHint.DESKTOP);
        
        var screen = Gdk.Screen.get_default ();
        var root = screen.get_root_window ();
        set_size_request (root.get_width (), root.get_height ());
        add (desktop);

        move (0, 0);
        show_all ();
    
        settings.changed[BG_KEY].connect(() => {
            set_background ();
        });

        map_event.connect (() => {
            set_background ();
            return true;
        });

    }

    void set_background () {
        try {
            var bg = settings.get_string (BG_KEY);
            desktop.set_background (bg);
        } catch (Error e) {
        }

    }
}

