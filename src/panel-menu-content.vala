using GMenu;
using Gtk;

public class PanelMenuContent : PanelScrollableContent {
    protected VBox bar;

    public signal void menu_clicked ();

    public PanelMenuContent (string? label) {
        bar = new VBox (false, 0);
        set_widget (bar);
        set_scrollbar_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);

        var filler = new DrawingArea ();
        filler.set_size_request (300, 20);

        bar.pack_start (filler, false, false, 0);
        if (label != null) {
            var l = new Label ("");
            l.set_markup ("<big>" + label + "</big>");
            bar.pack_start (l, false, false, 5);
        }
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

                entry.append_filler (level * 20);
                parent.pack_start (entry, false, false, 0);
                break;
            }
        }
    }

    public void populate (string catalog) { 
        var tree = GMenu.Tree.lookup (catalog, TreeFlags.NONE);
        var root = tree.get_root_directory ();

        update_tree (bar, 0, root);
    }

    public void insert_separator () {
        bar.pack_start (new Separator (Orientation.HORIZONTAL), false, false, 10);
    }
}
