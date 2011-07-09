using Gtk;
using GLib;


public class PanelPlaces : PanelMenuContent {

    public class UriItem : PanelItem {
        public UserDirectory id { get; set; default = UserDirectory.DESKTOP;}

        public UriItem (string label) 
        {
            set_text (label);
        }
    }

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
        setup_special_dirs ();
    }

    private void setup_home () {
        var home = new PanelItem.with_label ("Home");
        home.set_image ("gtk-home");
        bar.pack_start (home, false, false, 0);

        home.activate.connect (() => {
            show_uri_from_path (Environment.get_home_dir ());
        });
    }

    private void setup_special_dirs () {
        for (int i = UserDirectory.DESKTOP; i < UserDirectory.N_DIRECTORIES; i ++) {
            var path = Environment.get_user_special_dir ((UserDirectory) i);
            if (path == null)
                continue;

            var dir = new UriItem ("Desktop");
            dir.set_image ("gtk-dir");
            dir.id = (UserDirectory) i;
            bar.pack_start (dir, false, false, 0);

            dir.activate.connect (() => {
                show_uri_from_path (path);
            });
        }
    }

    private void show_uri_from_path (string? path) {
        stdout.printf("%s\n", path);
        var f = File.new_for_path (path);
        try {
            show_uri (Gdk.Screen.get_default (), f.get_uri (), get_current_event_time());
        } catch (Error e) {
        }
    }
}
