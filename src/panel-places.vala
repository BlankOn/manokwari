using Gtk;
using GLib;

public class PanelPlaces : PanelMenuContent {
    private VolumeMonitor vol_monitor;
    private File bookmark_file;
    private FileMonitor bookmark_monitor;

    public signal void error ();
    public signal void launching ();

    public PanelPlaces () {
        base (_("Places"));
        vol_monitor = VolumeMonitor.get ();
        bookmark_file = File.new_for_path (Environment.get_home_dir () + "/.gtk-bookmarks");
        try {
            bookmark_monitor = bookmark_file.monitor_file (FileMonitorFlags.NONE, null);
        } catch (Error e) {
            stdout.printf ("Can't monitor bookmark file: %s", e.message);
        }

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

        bookmark_monitor.changed.connect (() => {
            reset ();
        });
    }

    public void reset () {

        foreach (unowned Widget w in bar.get_children ()) {
            w.destroy ();
        }

        init_contents ();
        show_all ();
    }

    private void init_contents () {
        setup_home ();
        setup_special_dirs ();
        setup_mounts ();
        setup_network ();
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


        if (bookmark_file.query_exists ()) {
            try {
                var input = new DataInputStream (bookmark_file.read ());
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
                                launching ();
                            } catch (Error e) {
                                show_dialog (_("Error opening '%s': %s").printf(fields [1], e.message));
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
                try {
                    show_uri (Gdk.Screen.get_default (), mount.get_root().get_uri (), get_current_event_time());
                    launching ();
                } catch (Error e) {
                    error ();
                    show_dialog (_("Error opening mount point '%s': %s").printf (mount.get_root ().get_uri (), e.message));
                }
            });
        }
    }

    private void setup_network () {
        insert_separator ();
        var network = new PanelItem.with_label (_("Network"));
        network.set_image ("gtk-network");
        bar.pack_start (network, false, false, 0);
        network.activate.connect (() => {
            try {
                show_uri (Gdk.Screen.get_default (), "network:///", get_current_event_time());
                launching ();
            } catch (Error e) {
                error ();
                show_dialog (_("Error opening Network: %s").printf (e.message));
            }
        });
        var item = new PanelItem.with_label (_("Connect to server..."));
        item.set_image ("gnome-fs-network");
        bar.pack_start (item, false, false, 0);
        item.activate.connect (() => {
            try {
                var app = AppInfo.create_from_commandline ("nautilus-connect-server", "Nautilus", AppInfoCreateFlags.NONE);
                app.launch (null, null);
                launching();
            } catch (Error e) {
                error ();
                show_dialog (_("Error opening Network: %s").printf (e.message));
            }
        });

    }

    private void show_uri_from_path (string? path) {
        var f = File.new_for_path (path);
        try {
            show_uri (Gdk.Screen.get_default (), f.get_uri (), get_current_event_time());
            launching();
        } catch (Error e) {
            error ();
            show_dialog (_("Error opening '%s': %s").printf (path, e.message));
        }
    }

    private void show_dialog (string message) {
        var dialog = new MessageDialog (null, DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE, message);
        dialog.response.connect (() => {
            dialog.destroy ();
        });
        dialog.show ();
    }
}
