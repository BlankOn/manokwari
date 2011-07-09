using Gtk;
using GLib;

public class PanelPlaces : PanelMenuContent {
    public PanelPlaces () {
        base ("Places");
        init_contents ();
        show_all ();
    }

    public void reset () {
        // TODO: Remove bar's content
        init_contents ();
    }

    private void init_contents () {
        setup_home ();
    }

    private void setup_home () {
        var home = new PanelItem.with_label ("Home");
        home.set_image ("gtk-home");
        bar.pack_start (home, false, false, 0);

        home.activate.connect (() => {
            var f = File.new_for_path (Environment.get_home_dir ());
            try {
                show_uri (Gdk.Screen.get_default (), f.get_uri (), get_current_event_time());
            } catch (Error e) {
            }
        });
    }
}
