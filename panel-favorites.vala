using GMenu;

public class PanelFavorites {
    private List<GMenu.TreeEntry> favorite_apps;
    public PanelFavorites () {
    }

    private void update () {
        favorite_apps = new List<GMenu.TreeEntry> ();
        var tree = GMenu.Tree.lookup ("favorites.menu", GMenu.TreeFlags.NONE);
        var root = tree.get_root_directory ();
        foreach (GMenu.TreeItem item in root.get_contents ()) {
            if (item.get_type () == TreeItemType.ENTRY) {
                favorite_apps.append ((GMenu.TreeEntry) item);
            }
        }
    }

    public unowned List<GMenu.TreeEntry> list () {
        update();
        return favorite_apps;
    }
}
