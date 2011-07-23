using GMenu;
using Gtk;

// This class opens an xdg menu and populates it
public class PanelMenuXdg : PanelMenuContent {

    private string catalog;

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
                parent.pack_start (expander, false, false, 0); 
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

        update_tree (bar, 0, root);
    }

    public void repopulate () {
        foreach (unowned Widget w in bar.get_children ()) {
            if (w is PanelExpanderItem ||
                w is PanelItem)
                bar.remove (w);
        }
        populate ();
    }
}
