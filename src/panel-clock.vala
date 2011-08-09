using Gtk;

public class PanelClock : Label {
	
	public PanelClock () {
		Timeout.add (1000 * 30, update);
        set_justify (Justification.CENTER);
        update ();
	}
	
	private bool update () {
		char bufferClock[20];
		char bufferDate[50];
		Time t = Time.local (time_t ());
		t.strftime (bufferClock, _("%H:%M"));
		t.strftime (bufferDate, _("%a, %e %b %Y"));
		set_markup ("\n\r<span font='24' weight='bold'>     <u>" + (string) bufferClock + "</u>     </span>" + "\n" + "<span font='10'>" + (string) bufferDate + "</span>\n\r");
		return true;
	}
	
	public override bool draw (Cairo.Context cr) {
        StyleContext style = get_style_context ();
        style.set_state (get_state_flags ());
        Gtk.render_background (style, cr, 0, 0, get_allocated_width (), get_allocated_height ());
        base.draw (cr);
        return true;
    }
	
}

public class ClockWindow : PanelAbstractWindow {
    private PanelClock clock;
    private Gdk.DeviceManager device_manager;

    public ClockWindow () {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        device_manager = Gdk.Display.get_default ().get_device_manager ();
        add_events (Gdk.EventMask.STRUCTURE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK);

        set_visual (this.screen.get_rgba_visual ());
        Gdk.RGBA c = Gdk.RGBA();
        c.red = 0.0;
        c.blue = 0.0;
        c.green = 0.0;
        c.alpha = 0.0;
        override_background_color(StateFlags.NORMAL, c);
        set_app_paintable(true);

        clock = new PanelClock ();
        add (clock);
        show_all ();
        screen_size_changed.connect (() => {
            reposition ();
        });

        enter_notify_event.connect (() => {
            setup_hole ();
            GLib.Timeout.add (1000, try_bring_back);
            return false;
        });
    }

    public void bring_back () {
        set_opacity (1.0);
        get_window ().input_shape_combine_region (null, 0, 0);
    }

    public bool try_bring_back () {
        int x, y;

        set_opacity (0.3);
        var pointer = device_manager.get_client_pointer ();
        pointer.get_position (null, out x, out y);

        int wx, wy;
        get_window ().get_position (out wx, out wy);
        if (x >= wx && x <= wx + get_window ().get_width () &&
            y >= wy && y <= wy + get_window ().get_height ()) {
            // Cursor is nside clock's window
            // Try to bring back next time
            return true;
        }

        // Cursor is outside clock's window
        // Let's bring it back now
        bring_back ();
        return false;
    }

    public void setup_hole () {
        set_opacity (0.1);
        Cairo.RectangleInt r = Cairo.RectangleInt();
        r.x = 0;
        r.y = 0;
        r.width = 1;
        r.height = 1;

        var region = new Cairo.Region.rectangle (r);
        get_window ().input_shape_combine_region (region, 0, 0);
    }

    public override bool map_event (Gdk.Event event) {
        reposition ();
        return true;
    }

    public new void reposition () {
        int w = clock.get_allocated_width ();
        int h = clock.get_allocated_height ();
        set_size_request (w, h);

        var rect = PanelScreen.get_primary_monitor_geometry ();

        move (rect.x + rect.width - w - (w / 8), rect.y + h / 8);
        queue_resize ();
    }

}
