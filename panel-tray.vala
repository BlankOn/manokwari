using Gtk;
using Gdk;
using X;

public class PanelTray : Layout {
    private Gdk.Rectangle rect;
    private Invisible invisible;
    private HBox box;
    private uint size;
    private uint default_size = 25;

    public signal void new_item_added ();

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = (int) default_size; 
    }

    public override void get_preferred_width (out int min, out int max) {
        min = (int) size;
        max = min;
    }

    private void update_size () {
        size = default_size * box.get_children ().length ();
    }

    private void add_client (long xid) {

        // Skips already added clients
        foreach (unowned Widget w in box.get_children ()) {
            long id = (long) ((Gtk.Socket) w).get_id ();
            if (id == xid)
                return;
        }

        var w = new Gtk.Socket();
        w.show ();
        w.plug_removed.connect (() => {
            box.remove (w);
            update_size ();
            return false;
        });
        box.pack_start(w, false, false, 1);
        w.add_id (xid);
        w.get_plug_window ().resize ((int) default_size, (int) default_size);
        stdout.printf("%d\n", w.get_plug_window ().get_width ());
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

        var screen = get_screen();
        screen.get_monitor_geometry (screen.get_primary_monitor(), out rect);
        invisible = new Invisible ();
        invisible.add_events (Gdk.EventMask.PROPERTY_CHANGE_MASK |
                              Gdk.EventMask.STRUCTURE_MASK);
        invisible.realize();
        box = new HBox(true, 0);
        add(box);
        box.show ();

        setup_selection ();
    }
}

