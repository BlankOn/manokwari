using GMenu;
using Gtk;

public class PanelMenuContent  {
    private MenuBar menu;
    private string catalog;

    public signal void menu_clicked ();

    public PanelMenuContent (MenuBar bar, string catalog) {
        menu = bar;
        this.catalog = catalog;
    }

    private void update_tree (TreeDirectory root) {
        foreach (TreeItem item in root.get_contents ()) {
            switch (item.get_type()) {
            case TreeItemType.DIRECTORY:
                var i = (TreeDirectory) item;
                update_tree (i);

                break;

            case TreeItemType.ENTRY:
                var i = (TreeEntry) item;
                var entry = new PanelItem.with_label (i.get_display_name ());
                entry.set_image (new Image.from_icon_name (i.get_icon (), IconSize.LARGE_TOOLBAR));
                entry.show ();

                entry.activate.connect (() => {
                    var info = new DesktopAppInfo.from_filename (i.get_desktop_file_path ());
                    info.launch (null, new AppLaunchContext ());
                    menu_clicked ();
                });
                menu.append (entry);
                break;
            }
        }
    }

    public void populate () { 
        var tree = GMenu.Tree.lookup (catalog, TreeFlags.NONE);
        var root = tree.get_root_directory ();

        update_tree (root);
    }

    public void insert_separator () {
        menu.append (new SeparatorMenuItem ());
    }
}
