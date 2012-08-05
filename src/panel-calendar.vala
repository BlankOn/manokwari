using Gtk;

public class PanelCalendar : PanelAbstractWindow {
    private const int PADDING = 5;

    public signal void dismissed ();
    public signal void shown ();
    public signal void about_to_show_content ();

    Calendar calendar;
    Button button;

    public PanelCalendar () {
        calendar = new Calendar ();

        var box = new VBox (false, PADDING);
        add (box);
        box.pack_start (calendar, false, false, 0);
        PanelScreen.move_window (this, Gdk.Gravity.NORTH_EAST);

        button = new Button.with_label (_("Adjust date/time"));
        box.pack_start (button, false, false, 0);
        button.show ();

        button.clicked.connect(() => {
            var info = new DesktopAppInfo.from_filename ("/usr/share/applications/gnome-datetime-panel.desktop");
            try {
                info.launch (null, new AppLaunchContext ());
            } catch (Error e) {
                var dialog = new MessageDialog (null, DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE, _("Unable to launch date-time applet: %s"), e.message);
                dialog.response.connect (() => {
                            dialog.destroy ();
                        });
                dialog.show ();
            }
            hide ();
        });


    }

    public override void get_preferred_width (out int min, out int max) {
        calendar.get_preferred_width (out min, out max); 
    }

    public override void get_preferred_height (out int min, out int max) {
        int h1, h2;
        calendar.get_preferred_height (out h1, out h2); 
        min = h1;
        max = h2;
        button.get_preferred_height (out h1, out h2); 
        min += h1 + PADDING;
        max += h2 + PADDING;
    }

    bool real_hide () {
        hide ();
        return false;
    }

    public void try_hide () {
        GLib.Timeout.add (500, real_hide);
        dismissed ();
    }

    public void update_position (int y) {
        var g = PanelScreen.get_primary_monitor_geometry ();
        int min, max;
        calendar.get_preferred_width (out min, out max); 
        queue_resize();
        move(g.x + (g.width - max), g.y + y);
    }
}
