using Gtk;
using GLib;

public class PanelPlaces : PanelMenuContent {
    private VolumeMonitor vol_monitor;

    public PanelPlaces () {
        base ("Places");
        vol_monitor = VolumeMonitor.get ();
        init_contents ();
        show_all ();

        vol_monitor.mount_added.connect (() => {
            reset ();
        });
        vol_monitor.mount_changed.connect (() => {
            reset ();
        });
        vol_monitor.mount_removed.connect (() => {
            reset ();
        });

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
            try {
                var input = new DataInputStream (file.read ());
                string line;
                while ((line = input.read_line (null)) != null) {
                    var fields = line.split (" ");
                    if (fields.length == 2) {
                        var item = new PanelItem.with_label (fields [1]);
                        item.set_image ("gtk-directory");
                        bar.pack_start (item, false, false, 0);
                        item.activate.connect (() => {
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
            } catch (Error e) {
                stdout.printf ("Unable to read the bookmarks\n");
            }
        }

    }

    private void setup_mounts () {
        insert_separator ();
        var mounts = vol_monitor.get_mounts ();
        // This apparently can't be iterated using "foreach"
        for (int i = 0; i < mounts.length(); i ++) {
            var mount = mounts.nth_data (i);
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
