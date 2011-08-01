using GMenu;
using Gee;
using Gtk;
using GLib;


// This class opens an xdg menu and populates it
public class PanelMenuXdg : PanelMenuContent {

    private string catalog;
    public signal void deactivate ();

    public PanelMenuXdg (string catalog, string? label) {
        base (label);
        this.catalog = catalog;
        populate ();
    }

    private void update_tree (VBox parent, int level, TreeDirectory root) {
        foreach (TreeItem item in root.get_contents ()) {
            switch (item.get_type()) {
            case TreeItemType.DIRECTORY:
                var i = (TreeDirectory) item;

                var expander = new PanelExpanderItem (i.get_name (), i.get_icon ());
                pack_start (expander, false, false, 0); 
                var box = new VBox (false, 0);
                expander.add (box);
                update_tree (box, level + 1, i);
                expander.activate.connect(() => {
                    foreach (unowned Widget w in parent.get_children ()) {
                        if (w is Expander && w != expander) {
                            ((PanelExpanderItem)w).set_expanded (false);
                        }
                    }
                });
                break;

            case TreeItemType.ENTRY:
                var i = (TreeEntry) item;
                var entry = new PanelItem.with_label (i.get_display_name ());
                entry.set_image (i.get_icon ());
                entry.show ();

                entry.right_clicked.connect ((e) => {
                    show_popup (e, i);
                });

                entry.activate.connect (() => {
                    var info = new DesktopAppInfo.from_filename (i.get_desktop_file_path ());
                    try {
                        info.launch (null, new AppLaunchContext ());
                    } catch (Error e) {
                        var dialog = new MessageDialog (null, DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE, _("Error opening menu item %s: %s").printf (i.get_display_name (), e.message));
                        dialog.response.connect (() => {
                            dialog.destroy ();
                        });
                        dialog.show ();
                    }
                    menu_clicked ();
                });

                entry.append_filler (level * 20);
                parent.pack_start (entry, false, false, 0);
                break;
            }
        }
    }

    private void populate () { 
        var tree = GMenu.Tree.lookup (catalog, TreeFlags.NONE);
        var root = tree.get_root_directory ();

        update_tree (this, 0, root);
    }

    public void repopulate () {
        foreach (unowned Widget w in get_children ()) {
            if (w is PanelExpanderItem ||
                w is PanelItem)
                remove (w);
        }
        populate ();
    }

    public void show_popup (Gdk.EventButton event, TreeEntry item) {
        var menu = new Menu ();

        var entry = new MenuItem.with_label (_("Add to Favorites"));
        entry.show ();
        menu.add (entry);

        entry.activate.connect (() => {
            Favorites.add (item.get_desktop_file_path ());
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
