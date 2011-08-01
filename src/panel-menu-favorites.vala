using GMenu;
using Gee;
using Gtk;
using GLib;

public class Favorites {

    public signal void changed ();
    
    public Favorites () {
    }

    private static File get_custom_favorites_file () {
        return File.new_for_path (Environment.get_home_dir () + "/.config/blankon-panel/favorites");
    }

    public void monitor () {
        var custom_file = get_custom_favorites_file ();
        try {
            var monitor = custom_file.monitor (FileMonitorFlags.NONE, null);
            monitor.changed.connect (() => {
                changed ();
            });
        } catch (Error e) {
            stdout.printf ("Can't monitor custom favorite file: %s\n", e.message);
        }
    }

    public static void remove (string file) {
        add ("-" + file);
    }

    public static void add (string file) {
        bool ok = false;
        var list = get_list ();
        var custom_file = get_custom_favorites_file ();
        DataOutputStream output = null;
        if (!custom_file.query_exists ()) {
            var dir_name = custom_file.get_path ().substring (0, custom_file.get_path ().last_index_of("/"));
            var dir = File.new_for_path (dir_name);
            if (!dir.query_exists ()) {
                try {
                    dir.make_directory_with_parents (null);
                    ok = true;
                } catch (Error e) {
                    stdout.printf ("Unable to create config directory for storing favorites: %s\n", e.message);
                }
            }
            if (ok) {
                try {
                    output = new DataOutputStream (custom_file.create (FileCreateFlags.PRIVATE, null));
                } catch (Error e) {
                    stdout.printf ("Unable to create favorites file: %s\n", e.message);
                    ok = false;
                }
            }
        } else {
            try {
                output = new DataOutputStream (custom_file.replace (null, false, FileCreateFlags.PRIVATE, null));
                ok = true;
            } catch (Error e) {
                stdout.printf ("Unable to append favorites file: %s\n", e.message);
            }
        }
        if (ok && output != null) {
            try {
                var duplicate = false;
                foreach (string entry in list) {
                    if (entry == file)
                        duplicate = true;
                    if (entry == "-" + file)
                        duplicate = true;
                    if ("-" + entry != file) // Write out entry if not deleted
                        output.put_string (entry + "\n");
                }
                if (! duplicate)
                    output.put_string (file + "\n");
                output.close ();
            } catch (Error e) {
                stdout.printf ("Unable to write to favorites file: %s\n", e.message);
            }
        }
    }

    public static Gee.ArrayList<string> get_blacklist () {
        var list = get_list ();
        var new_list = new Gee.ArrayList <string> (); 
        foreach (string entry in list) {
            if (entry.get_char (0) == '-') {
                new_list.add (entry.substring (1));
            }
        }
        return new_list;
    }

    public static Gee.ArrayList<string> get_list () {
        var list = new Gee.ArrayList <string> ();

        var custom_file = get_custom_favorites_file ();
        if (custom_file.query_exists ()) {
            try {
                var input = new DataInputStream (custom_file.read ());
                string line;

                while ((line = input.read_line (null)) != null) {
                    if (line.last_index_of (".desktop") == (line.length - 8)) {
                        list.add (line);
                    }
                }
                input.close ();
            } catch (Error e) {
                stdout.printf ("Unable to read the custom bookmark to produce blacklist\n");
            }
        }

        var tree = GMenu.Tree.lookup ("favorites.menu", TreeFlags.NONE);
        var root = tree.get_root_directory ();

        foreach (TreeItem item in root.get_contents ()) {
            if (item.get_type() ==  TreeItemType.ENTRY) {
                var i = (TreeDirectory) item;
                if (list.index_of ("-" + i.get_desktop_file_path ()) < 0 &&
                    list.index_of (i.get_desktop_file_path ()) < 0) {
                    list.add (i.get_desktop_file_path ());
                }
            }
        }
        return list;
    }
}


public class PanelMenuFavorites: PanelMenuContent {
    private Favorites content;

    public signal void deactivate ();

    public PanelMenuFavorites () {
        base (_("Favorites"));
        populate ();
        content = new Favorites ();
        content.monitor ();

        content.changed.connect (() => {
            repopulate ();
            show_all ();
        });
    }

    private void populate () {
        var list = Favorites.get_list ();
        foreach (string item in list) {
            if (item.get_char (0) == '-') // Don't display blacklisted entries
                continue;

            var info = new DesktopAppInfo.from_filename (item);
            var entry = new PanelItem.with_label (info.get_display_name ());
            entry.set_image (info.get_icon ().to_string ());
            entry.show ();
            pack_start (entry, false, false, 0);

            entry.right_clicked.connect ((e) => {
                show_popup (e, item);
            });

            entry.activate.connect (() => {
                try {
                    info.launch (null, new AppLaunchContext ());
                } catch (Error e) {
                    var dialog = new MessageDialog (null, DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE, _("Error opening menu item %s: %s").printf (info.get_display_name (), e.message));
                    dialog.response.connect (() => {
                        dialog.destroy ();
                    });
                    dialog.show ();
                }
                menu_clicked ();
            });
   
        }
        insert_separator ();
    }

    public void repopulate () {
        foreach (unowned Widget w in get_children ()) {
            if (w is PanelExpanderItem ||
                w is PanelItem || 
                w is Separator)
                remove (w);
        }
        populate ();
    }

    public void show_popup (Gdk.EventButton event, string item) {
        var menu = new Menu ();

        var entry = new MenuItem.with_label (_("Remove from Favorites"));
        entry.show ();
        menu.add (entry);

        entry.activate.connect (() => {
            Favorites.remove (item);
        });

        var button = event.button;
        var event_time = event.time;

        menu.deactivate.connect (() => {
            deactivate ();
        });
        menu.attach_to_widget (this, null);

        menu.popup (null, null, null, button, event_time);
    }
}

