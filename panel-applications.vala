using GMenu;
using Gtk;

public class PanelApplications  {
    private MenuBar menu;

    public PanelApplications () {
    }

    private void update (TreeDirectory root, MenuShell shell) {
        foreach (TreeItem item in root.get_contents ()) {
            switch (item.get_type()) {
            case TreeItemType.DIRECTORY:
                var i = (TreeDirectory) item;
                var entry = new PanelItem.with_label (i.get_name ());
                stdout.printf ("d-->%s\n", i.get_name());
                entry.set_image (new Image.from_icon_name (i.get_icon (), IconSize.LARGE_TOOLBAR));
                entry.show ();

                shell.append (entry);
                var popup = new Menu ();
                update (i, popup);

                entry.set_submenu (popup);

                break;

            case TreeItemType.ENTRY:
                var i = (TreeEntry) item;
                var entry = new PanelItem.with_label (i.get_display_name ());
                stdout.printf ("-->%s\n", i.get_display_name());
                entry.set_image (new Image.from_icon_name (i.get_icon (), IconSize.LARGE_TOOLBAR));
                entry.show ();
                shell.append (entry);
                break;
            }
        }
    }

    public MenuBar menubar () { 
        menu = new MenuBar ();
        menu.set_pack_direction (PackDirection.TTB);
        var tree = GMenu.Tree.lookup ("applications.menu", TreeFlags.NONE);
        var root = tree.get_root_directory ();

        update(root, menu);
        return menu;
    }
}
