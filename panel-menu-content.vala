using GMenu;
using Gtk;

public class PanelMenuContent  {
    private VBox menu;
    private string catalog;

    public signal void menu_clicked ();

    public PanelMenuContent (VBox bar, string catalog) {
        menu = bar;
        this.catalog = catalog;
    }

    private void update_tree (VBox parent, int level, TreeDirectory root) {
        foreach (TreeItem item in root.get_contents ()) {
            switch (item.get_type()) {
            case TreeItemType.DIRECTORY:
                var i = (TreeDirectory) item;

                var expander = new PanelExpanderItem (i.get_name ());
                parent.pack_start (expander, false, false, 0); 
                var box = new VBox (false, 0);
                expander.add (box);
                update_tree (box, level + 1, i);
                expander.expanding.connect(() => {
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
                    info.launch (null, new AppLaunchContext ());
                    menu_clicked ();
                });

                entry.append_filler (level * 10);
                parent.pack_start (entry, false, false, 0);
                break;
            }
        }
    }

    public void populate () { 
        var tree = GMenu.Tree.lookup (catalog, TreeFlags.NONE);
        var root = tree.get_root_directory ();

        update_tree (menu, 0, root);
    }

    public void insert_separator () {
        //menu.append (new SeparatorMenuItem ());
    }
}
