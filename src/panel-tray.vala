using Gtk;
using Gdk;
using X;

public class PanelTray : HBox {
    private Invisible invisible;

    public signal void new_item_added ();

    enum Message {
        REQUEST_DOCK,
        BEGIN,
        CANCEL
    }

    private void add_client (long xid) {

        // Skips already added clients
        foreach (unowned Widget w in get_children ()) {
            unowned Gtk.Socket socket = w as Gtk.Socket;
            if (socket != null) {
                long id = (long) socket.get_id ();
                if (id == xid)
                    return;
                }
        }

        var w = new Gtk.Socket();
        pack_start (w, false, false, 0);
        w.show ();

        w.add_id (xid);
        new_item_added ();

        hide ();
        show_all ();
        w.plug_removed.connect (() => {
            w.destroy ();
            show_all ();
            return true;
        });

    }

    private FilterReturn event_filter (Gdk.XEvent xev, Gdk.Event event) {
        unowned X.Display display = x11_get_default_xdisplay ();
        Gdk.FilterReturn return_value = Gdk.FilterReturn.CONTINUE;
        
        void* pointer = &xev;
        X.Event* xevent = (X.Event*) pointer;
                 
        if(xevent->type == X.EventType.ClientMessage) {
            if (xevent->xclient.message_type == display.intern_atom ("_NET_SYSTEM_TRAY_OPCODE", false)) {
                if (xevent->xclient.data_l [1] == Message.REQUEST_DOCK) {
                    add_client (xevent->xclient.data_l [2]);
                    return Gdk.FilterReturn.REMOVE;
                }
            } else {
                    stdout.printf("req: d\n");
            }
        }

        return return_value;
    }

    private bool setup_selection () {
        unowned X.Display display = x11_get_default_xdisplay ();
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
        var event = ClientMessageEvent();
        event.type          = X.EventType.ClientMessage;
        event.window        = display.root_window (screen.get_number ()); 
        event.message_type  = display.intern_atom ("MANAGER", false);
        event.format        = 32;
        event.data_l [0]    = Gdk.CURRENT_TIME;
        event.data_l [1]    = (long) display.intern_atom ("_NET_SYSTEM_TRAY_S%d".printf(screen.get_number()), false);
        event.data_l [2]    = xid;
        event.data_l [3]    = 0;
        event.data_l [4]    = 0;
        display.send_client_event (display.root_window (screen.get_number ()), false, X.EventMask.StructureNotifyMask, ref event);

        ulong data[1] = {0};
        display.change_property (xid, display.intern_atom ("_NET_SYSTEM_TRAY_ORIENTATION,", false), X.XA_CARDINAL, 32, X.PropMode.Replace, (uchar[])data, 1);

        invisible.get_window().add_filter(event_filter);
        return true;
    }

    public PanelTray () {
        invisible = new Invisible ();
        invisible.add_events (Gdk.EventMask.PROPERTY_CHANGE_MASK |
                              Gdk.EventMask.STRUCTURE_MASK);
        invisible.realize();
        show ();
        setup_selection ();
        var empty = new DrawingArea ();
        empty.show ();
        empty.set_size_request (10, 1);
        pack_end (empty, false, false, 0);
    }

    public override bool draw (Cairo.Context cr) {
        StyleContext style = get_style_context ();
        style.set_state (get_state_flags ());
        Gtk.render_background (style, cr, 0, 0, get_window ().get_width (), get_window ().get_height ());
        base.draw (cr);
        return true;
    }

}

