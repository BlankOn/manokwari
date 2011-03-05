using GMenu;

public class PanelApplications {
    private List<GMenu.TreeItem> applications;
    public PanelApplications () {
    }

    private void update () {
        applications = new List<GMenu.TreeEntry> ();
        var tree = GMenu.Tree.lookup ("applications.menu", GMenu.TreeFlags.NONE);
        var root = tree.get_root_directory ();
        foreach (GMenu.TreeItem item in root.get_contents ()) {
            applications.append (item);
            stdout.printf ("%d\n", item.get_type ());
        }
    }

    public unowned List<GMenu.TreeItem> list () {
        update();
        return applications;
    }
}
