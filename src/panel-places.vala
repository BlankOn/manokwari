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
        setup_special_dirs ();
        setup_mounts ();
    }

    private void setup_home () {
        var home = new PanelItem.with_label ( _("Home") );
        home.set_image ("gtk-home");
        bar.pack_start (home, false, false, 0);

        home.activate.connect (() => {
            show_uri_from_path (Environment.get_home_dir ());
        });
    }

    private void setup_special_dirs () {
        insert_separator ();
        for (int i = UserDirectory.DESKTOP; i < UserDirectory.N_DIRECTORIES; i ++) {
            var path = Environment.get_user_special_dir ((UserDirectory) i);
            if (path == null)
                continue;

            var dir = new PanelItem.with_label (Filename.display_basename(path));
            if (i == (int) UserDirectory.DESKTOP)
                dir.set_image ("desktop");
            else
                dir.set_image ("gtk-directory");
            bar.pack_start (dir, false, false, 0);

            dir.activate.connect (() => {
                show_uri_from_path (path);
            });
        }

        var file = File.new_for_path (Environment.get_home_dir () + "/.gtk-bookmarks");

        if (file.query_exists ()) {
            var input = new DataInputStream (file.read ());
            string line;
            while ((line = input.read_line (null)) != null) {
                var fields = line.split (" ");
                if (fields.length == 2) {
                    var item = new PanelItem.with_label (fields [1]);
                    item.set_image ("gtk-directory");
                    bar.pack_start (item, false, false, 0);
                    item.activate.connect (() => {
                        stdout.printf("%s\n", fields[0]);
                        try {
                            show_uri (Gdk.Screen.get_default (), fields [0], get_current_event_time());
                        } catch (Error e) {
                            var dialog = new MessageDialog (null, DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE, "Error opening '%s': %s", fields [1], e.message);
                            dialog.response.connect (() => {
                                dialog.destroy ();
                            });
                            dialog.show ();

                        }
                    });
                }
            }
        }

    }

    private void setup_mounts () {
        insert_separator ();
        var vol_monitor = VolumeMonitor.get ();
        foreach (Mount mount in vol_monitor.get_mounts ()) {
            if (mount == null)
                continue;

            var item = new PanelItem.with_label (mount.get_name ());
            item.set_image_from_icon (mount.get_icon ());
            bar.pack_start (item, false, false, 0);
            item.activate.connect (() => {
                show_uri_from_path (mount.get_root().get_uri ());
            });
        }
    }

    private void show_uri_from_path (string? path) {
        var f = File.new_for_path (path);
        try {
            show_uri (Gdk.Screen.get_default (), f.get_uri (), get_current_event_time());
        } catch (Error e) {
            var dialog = new MessageDialog (null, DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE, "Error opening '%s': %s", path, e.message);
            dialog.response.connect (() => {
                    dialog.destroy ();
                    });
            dialog.show ();
        }
    }
}
