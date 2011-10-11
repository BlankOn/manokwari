namespace Utils {
    public bool launch_search () {
        try {
            GLib.Process.spawn_command_line_async ("synapse");
            return true;
        } catch (Error e) {
            return false;
        }
    }

    public bool launch_profile () {
        try {
            GLib.Process.spawn_command_line_async ("gnome-about-me");
            return true;
        } catch (Error e) {
            return false;
        }
    }

    public bool lock_screen () {
        try {
            GLib.Process.spawn_command_line_async ("gnome-screensaver-command -l");
            return true;
        } catch (Error e) {
            return false;
        }
    }

    public bool print_screen () {
        try {
            GLib.Process.spawn_command_line_async ("gnome-screenshot");
            return true;
        } catch (Error e) {
            return false;
        }
    }

    public void grab (Gtk.Window w) {
        var device = Gtk.get_current_event_device();

        if (device == null) {
            var display = w.get_display ();
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

        var status = keyboard.grab(w.get_window(), Gdk.GrabOwnership.WINDOW, true, Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK, null, Gdk.CURRENT_TIME);
        status = pointer.grab(w.get_window(), Gdk.GrabOwnership.WINDOW, true, Gdk.EventMask.BUTTON_PRESS_MASK, null, Gdk.CURRENT_TIME);
    }

    public void ungrab (Gtk.Window w) {
        var device = Gtk.get_current_event_device();
        var secondary = device.get_associated_device();
        device.ungrab(Gdk.CURRENT_TIME);
        secondary.ungrab(Gdk.CURRENT_TIME);
    }

}
