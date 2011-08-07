namespace Utils {
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
}
