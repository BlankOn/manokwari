using Gtk;
using Gdk;

public class PanelAbstractWindow : Gtk.Window {
    public signal void screen_size_changed ();

    protected void set_struts () {
        ulong[] struts = new ulong[12];

        var r = PanelScreen.get_primary_monitor_geometry (); 

        var left = 0;
        var right = 0;
        var top = 0;
        var bottom = 0;
        var left_y0 = 0;
        var left_y1 = 0;
        var right_y0 = 0;
        var right_y1 = 0;
        var top_x0 = 0;
        var top_x1 = 0;
        var bottom_x0 = 0;
        var bottom_x1 = 0;

        var x = 0;
        var y = 0;

        get_window().get_position(out x, out y);
        var width = get_window().get_width ();
        var height = get_window().get_height ();

        if (width != r.width) {
            if (x < r.width / 2) {
                left = width;
                left_y0 = y;
                left_y1 = y + height;
            } else {
                right = width;
                right_y0 = y;
                right_y1 = y + height;
            }
        }

        if (height != r.height) {
            if (y < r.height / 2) {
                top = height;
                top_x0 = x;
                top_x1 = x + width;
            } else {
                bottom = height;
                bottom_x0 = x;
                bottom_x1 = x + width;
            }
        }

        struts[0] = left;
        struts[1] = right;
        struts[2] = top;
        struts[3] = bottom;
        struts[4] = left_y0;
        struts[5] = left_y1;
        struts[6] = right_y0;
        struts[7] = right_y1;
        struts[8] = top_x0;
        struts[9] = top_x1;
        struts[10] = bottom_x0;
        struts[11] = bottom_x1;


        stdout.printf("%d %d %d %d %d %d\n", left, right, top, bottom, y, r.height);
        unowned X.Display display = x11_get_default_xdisplay ();
        var xid = X11Window.get_xid (get_window ());

        display.change_property (xid, display.intern_atom ("_NET_WM_STRUT_PARTIAL", false), X.XA_CARDINAL, 32, X.PropMode.Replace, (uchar[])struts, 12);
        display.change_property (xid, display.intern_atom ("_NET_WM_STRUT", false), X.XA_CARDINAL, 32, X.PropMode.Replace, (uchar[])struts, 4);


    }

    public PanelAbstractWindow () {
        add_events (Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.STRUCTURE_MASK
            | Gdk.EventMask.POINTER_MOTION_MASK);

        skip_taskbar_hint = true;
        set_decorated (false);
        set_resizable (false);
        set_focus_on_map (true);
        set_accept_focus (true);
        stick ();
     
        var screen = get_screen();
        screen.monitors_changed.connect (() => {
            screen_size_changed ();
        });

        screen.size_changed.connect (() => {
            screen_size_changed ();
        });
    }
}
