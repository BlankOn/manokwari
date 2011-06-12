using Gtk;
using Gdk;
using X;

public class PanelTray : PanelAbstractWindow {
    private Invisible invisible;
    private HBox box;
    private uint size;
    private uint default_size = 30;

    public signal void new_item_added ();

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = (int) default_size; 
    }

    public override void get_preferred_width (out int min, out int max) {
        var r = rect();
        min = (int) size;
        max = r.width;
    }

    private void update_size () {
        size = default_size * box.get_children ().length ();
    }

    private void add_client (long xid) {
        var w = new Gtk.Socket();
        w.show ();
        w.plug_removed.connect (() => {
            box.remove (w);
            update_size ();
            return false;
        });
        box.pack_start(w, true, true, 1);
        w.add_id (xid);
        update_size ();
        new_item_added ();
    }

    private FilterReturn event_filter (Gdk.XEvent xev, Gdk.Event event) {
        var display = x11_get_default_xdisplay ();
        Gdk.FilterReturn return_value = Gdk.FilterReturn.CONTINUE;
        
        void* pointer = &xev;
        X.Event* xevent = (X.Event*) pointer;
                 
        if(xevent->type == X.EventType.ClientMessage) {
            if (xevent->xclient.message_type == display.intern_atom ("_NET_SYSTEM_TRAY_OPCODE", false)) {
                add_client (xevent->xclient.data.l [2]);
            }
        }

        return return_value;
    }

    private bool setup_selection () {
        var display = x11_get_default_xdisplay ();
        var screen = get_screen();
        var atom = Gdk.Atom.intern ("_NET_SYSTEM_TRAY_S%d".printf(screen.get_number()), false);

        var owner = Selection.owner_get_for_display (get_display (), atom);
        if (owner != null) {
            stdout.printf ("Tray is already owned by someone else.\n");
            return false;
        }

        if (Selection.owner_set_for_display (get_display (), invisible.get_window (), atom, Gdk.CURRENT_TIME, true) == false) {
            stdout.printf ("Unable to claim Tray.\n");
            return false;
        }
        var xid = (long) X11Window.get_xid (invisible.get_window ());
        var event = ClientMessageEvent ();
        event.type          = X.EventType.ClientMessage;
        event.window        = display.root_window (screen.get_number ()); 
        event.message_type  = display.intern_atom ("MANAGER", false);
        event.format        = 32;
        event.data.l [0]    = Gdk.CURRENT_TIME;
        event.data.l [1]    = (long) display.intern_atom ("_NET_SYSTEM_TRAY_S%d".printf(screen.get_number()), false);
        event.data.l [2]    = xid;
        event.data.l [3]    = 0;
        event.data.l [4]    = 0;
        X.Event e = (X.Event) event;
        display.send_event (display.root_window (screen.get_number ()), false, X.EventMask.StructureNotifyMask, ref e);

        ulong data[1] = {0};
        display.change_property (xid, display.intern_atom ("_NET_SYSTEM_TRAY_ORIENTATION,", false), X.XA_CARDINAL, 32, X.PropMode.Replace, (uchar[])data, 1);

        invisible.get_window().add_filter(event_filter);
        return true;
    }

    public PanelTray () {
        size = 0;
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        invisible = new Invisible ();
        invisible.add_events (Gdk.EventMask.PROPERTY_CHANGE_MASK |
                              Gdk.EventMask.STRUCTURE_MASK);
        invisible.realize();
        box = new HBox(true, 0);
        add(box);
        box.show ();

        set_gravity (Gdk.Gravity.NORTH_EAST);
        setup_selection ();
    }
}

public class PanelTrayHost : PanelAbstractWindow {
    private uint default_size = 50;
    private PanelTray tray;

    bool hide_tray () {
        tray.hide ();
        return false;
    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = (int) default_size; 
    }

    public override void get_preferred_width (out int min, out int max) {
        var r = rect();
        min = max = 5;
    }

    public PanelTrayHost () {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        tray = new PanelTray ();
        show_all ();
        show_tray ();
        set_gravity (Gdk.Gravity.NORTH);
        move(rect ().width - get_window ().get_width (), 0);

        button_press_event.connect ((event) => {
            if (tray.visible)
                tray.hide ();
            else
                show_tray ();
            return false; 
        });

        tray.new_item_added.connect (() => {
            if (!tray.visible)   
                GLib.Timeout.add (3250, hide_tray);
            show_tray ();
        });
    }

    private void show_tray () {
        tray.show ();
        tray.move(rect ().width - tray.get_window ().get_width () - get_window ().get_width (), 0);
    }
}
