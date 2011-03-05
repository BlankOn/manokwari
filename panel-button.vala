using Gtk;
using Cairo;
using GMenu;

public class PanelButtonWindow : PanelAbstractWindow {

    private ImageSurface surface;
    private PanelMenuBox menuBox;
    private Gdk.Rectangle rect;
    private Gdk.Pixbuf logo;

    public PanelButtonWindow() {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        menuBox = new PanelMenuBox();
        set_visual (this.screen.get_rgba_visual ());

        menuBox.set_transient_for(this);
    
        set_size_request (40,40);
        set_keep_above(true);

        Gdk.RGBA c = Gdk.RGBA();
        c.red = 0.0;
        c.blue = 0.0;
        c.green = 0.0;
        c.alpha = 0.0;
        override_background_color(StateFlags.NORMAL, c);
        set_app_paintable(true);
        
        var screen = get_screen();
        screen.get_monitor_geometry (screen.get_primary_monitor(), out rect);
        move (rect.x, rect.y);

        var icon_theme = IconTheme.get_default();
        logo = icon_theme.load_icon ("distributor-logo", 30, IconLookupFlags.GENERIC_FALLBACK);
    }

    public override bool draw (Context cr)
    {

        if (logo != null)
            Gdk.cairo_set_source_pixbuf (cr, logo, 0, 0);
        cr.paint();
        return false;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        if (menuBox.get_visible ()) { 
            menuBox.hide();
        } else {
            menuBox.show_all ();
        }
        return false;
    }

    public override bool button_release_event (Gdk.EventButton event) {
        //this.menu.activate();
        return false;
    }


}

public class xPanelButton : DrawingArea {
    private PanelMenu menu;
    private ImageSurface surface;

    public xPanelButton () {
        add_events (Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.POINTER_MOTION_MASK);

        surface = new ImageSurface.from_png("/home/mdamt/blankon.png");
        set_size_request (surface.get_width(), surface.get_height());

        Gdk.RGBA c = Gdk.RGBA();
        c.red = 0.0;
        c.blue = 0.0;
        c.green = 0.0;
        c.alpha = 0.0;
        override_background_color(StateFlags.NORMAL, c);
        set_app_paintable(true);

        menu = new PanelMenu();
        //menu.update_content();
    }

    public override bool draw (Context cr)
    {
        cr.set_source_surface(surface, 0, 0);
        cr.paint();
        return false;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        //this.menu.activate();
        return false;
    }

    public override bool button_release_event (Gdk.EventButton event) {
        //this.menu.activate();
        return false;
    }

}



public class xPanelMenu : Menu {

    public void f(Menu m, out int x, out int y, out bool push_in)
    {
        int xx, yy;
        get_attach_widget().get_window().get_position(out xx, out yy);
        stdout.printf (">: %d %d\n", xx, yy);
        x = xx;
        y = yy;
    }

    public new void activate() {
        select_first(false);
        popup(null, null, f, 0, 0);
    }

    public void update_content () {
        List<GMenu.TreeDirectory> directories = get_main_directories();

        foreach (GMenu.TreeDirectory item in directories) {
            var menu_item = new ImageMenuItem.with_label(item.get_name());
            stdout.printf (">: %s\n", item.get_icon());
            menu_item.set_image(new Image.from_icon_name (item.get_icon(), IconSize.MENU));
            append (menu_item);
        }
    }

    List<GMenu.TreeDirectory> get_main_directories () {
        var tree = GMenu.Tree.lookup ("applications.menu", GMenu.TreeFlags.SHOW_EMPTY);
        var root = tree.get_root_directory ();

        var dirs = new List<GMenu.TreeDirectory> ();

        foreach (GMenu.TreeItem item in root.get_contents ()) {
            if (item.get_type () == GMenu.TreeItemType.DIRECTORY) {
                dirs.append ((GMenu.TreeDirectory) item);
            }
        }

        return dirs;
    }

    public List<GMenu.TreeEntry> get_entries_flat (GMenu.TreeDirectory directory) {
        var entries = new List<GMenu.TreeEntry> ();

        foreach (GMenu.TreeItem item in directory.get_contents ()) {
            switch (item.get_type ()) {
            case GMenu.TreeItemType.DIRECTORY:
                entries.concat (get_entries_flat ((GMenu.TreeDirectory) item));
                break;
            case GMenu.TreeItemType.ENTRY:
                entries.append ((GMenu.TreeEntry) item);
                break;
            }
        }
        return entries;
    }

    public DesktopAppInfo get_desktop_app_info (GMenu.TreeEntry entry) {
        return new DesktopAppInfo.from_filename (entry.get_desktop_file_path ());
    }

    /* Launch an application described in DesktopAppInfo */
    public void launch_desktop_app_info (DesktopAppInfo info) {
        try {
            info.launch (null, new AppLaunchContext ());
        } catch (Error error) {
            stdout.printf ("Error: %s\n", error.message);
        }
    }
}
