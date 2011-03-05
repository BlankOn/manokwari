using Gtk;

public class PanelMenuBox : PanelAbstractWindow {
    private Gdk.Rectangle rect;
    private VBox box;
    private PanelFavorites favorites;
    private PanelApplications applications;
    private MenuBar favorite_bar;
    private MenuBar applications_bar;

    public PanelMenuBox () {
        var screen = get_screen();
        screen.get_monitor_geometry (screen.get_primary_monitor(), out rect);
        move (rect.x, rect.y);
        box = new VBox (false, 0);
        add (box);

        favorites = new PanelFavorites ();
        favorite_bar = new MenuBar ();
        favorite_bar.set_pack_direction (PackDirection.TTB);

        applications = new PanelApplications ();
        applications_bar = new MenuBar ();
        applications_bar.set_pack_direction (PackDirection.TTB);

        update_content ();

        box.pack_start (favorite_bar, false, false);
        box.pack_start (applications_bar, false, false);


    }

    public void update_content () {
        foreach (GMenu.TreeEntry item in favorites.list ()) {
            var menu = new PanelItem.with_label (item.get_display_name ());
            menu.always_show_image = true;
            menu.set_image (new Image.from_icon_name (item.get_icon (), IconSize.LARGE_TOOLBAR));
            menu.load_app_info (item.get_desktop_file_path ());
            menu.activate.connect (() => {
                dismiss ();
            });
            favorite_bar.append (menu);
        }

        foreach (GMenu.TreeItem item in applications.list ()) {
            if (item.get_type () == GMenu.TreeItemType.ENTRY) {
                GMenu.TreeEntry i = (GMenu.TreeEntry) item;
                var menu = new PanelItem.with_label (i.get_display_name ());
                menu.always_show_image = true;
                menu.set_image (new Image.from_icon_name (i.get_icon (), IconSize.LARGE_TOOLBAR));
                menu.load_app_info (i.get_desktop_file_path ());
                menu.activate.connect (() => {
                    dismiss ();
                });
                applications_bar.append (menu);
            }
            else if (item.get_type () == GMenu.TreeItemType.DIRECTORY) {
                GMenu.TreeDirectory i = (GMenu.TreeDirectory) item;
                var menu = new PanelItem.with_label (i.get_name ());
                menu.always_show_image = true;
                menu.set_image (new Image.from_icon_name (i.get_icon (), IconSize.LARGE_TOOLBAR));
                menu.load_app_info (i.get_desktop_file_path ());
                menu.activate.connect (() => {
                    dismiss ();
                });
                applications_bar.append (menu);
            }

        }
    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = 300; 
    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = rect.height; 
    }

    public override bool map_event (Gdk.Event event) {
        var device = get_current_event_device();

        if (device == null) {
            var display = get_display ();
            var manager = display.get_device_manager ();
            var devices = manager.list_devices (Gdk.DeviceType.MASTER).copy();
            device = devices.data;
        }
        var keyboard = device;
        var pointer = device;

        if (device.get_source() == Gdk.InputSource.KEYBOARD) {
            pointer = device.get_associated_device ();
        } else {
            keyboard = device.get_associated_device ();
        }


        var status = keyboard.grab(get_window(), Gdk.GrabOwnership.WINDOW, true, Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK, null, Gdk.CURRENT_TIME);
        status = pointer.grab(get_window(), Gdk.GrabOwnership.WINDOW, true, Gdk.EventMask.BUTTON_PRESS_MASK, null, Gdk.CURRENT_TIME);
        return true;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        dismiss ();
        return true;
    }

    private void dismiss () {
        var device = get_current_event_device();
        var secondary = device.get_associated_device();
        device.ungrab(Gdk.CURRENT_TIME);
        secondary.ungrab(Gdk.CURRENT_TIME);
        hide();
    }
}
