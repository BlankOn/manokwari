using Gtk;

namespace PanelScreen {
    public static Gdk.Rectangle get_primary_monitor_geometry () {
        Gdk.Rectangle r = {0, 0};
        var screen = Gdk.Screen.get_default ();
        screen.get_monitor_geometry (screen.get_primary_monitor(), out r);
        return r;
    }

    public static void move_window (Window window, Gdk.Gravity gravity) {
        int x, y;
        Requisition min =  {0, 0};
        Requisition natural =  {0, 0};

        var monitor = get_primary_monitor_geometry ();

        window.get_preferred_size (out min, out natural);

        switch (gravity) {
        case Gdk.Gravity.NORTH_WEST:
            x = y = 0;
            break;

        case Gdk.Gravity.NORTH:
            y = 0;
            x = monitor.width / 2 - min.width / 2;
            break;

        case Gdk.Gravity.NORTH_EAST:
            y = 0;
            x = monitor.width - min.width;
            break;

        case Gdk.Gravity.WEST:
            x = 0;
            y = monitor.height / 2 - min.height / 2;
            break;

        case Gdk.Gravity.CENTER:
            x = monitor.width / 2 - min.width / 2;
            y = monitor.height / 2 - min.height / 2;
            break;

        case Gdk.Gravity.EAST:
            x = monitor.width - min.width; 
            y = monitor.height / 2 - min.height / 2;
            break;
            
        case Gdk.Gravity.SOUTH_WEST:
            x = 0;
            y = monitor.height - min.height;
            break;

        case Gdk.Gravity.SOUTH:
            x = monitor.width / 2 - min.width / 2;
            y = monitor.height - min.height;
            break;

        case Gdk.Gravity.SOUTH_EAST:
            x = monitor.width - min.width;
            y = monitor.height - min.height;
            break;

        case Gdk.Gravity.STATIC:
        default:
            x = y = 0;
            break;
        }

        x += monitor.x;
        y += monitor.y;
        window.move (x, y);
    }
}
