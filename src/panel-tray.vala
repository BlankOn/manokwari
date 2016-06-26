using Gtk;
using Cairo;
using Gdk;
using X;

public class PanelTray : Box {
    private Invisible invisible;
    HashTable<long?, long> hash = new HashTable<long?, long> (int64_hash, int64_equal);

    public signal void new_item_added ();

    enum Message {
        REQUEST_DOCK,
        BEGIN,
        CANCEL
    }

    private void add_client (X.Window xid) {
        long id = (long) xid;
        // Skips already added clients
        if (hash[id] == 1) {
          stderr.printf("%ld Skipped\n", id);
          return;
        }

        var w = new PanelSocket(xid);
        pack_start (w, false, false, 0);

        new_item_added ();
        hash[id] = 1;
        show_all();
        stderr.printf("Added\n");
        
        w.plug_removed.connect (() => {
          stderr.printf("Removed\n");
          long wid = (long) w.get_id ();
          hash.remove(wid);
          w.destroy ();
          show_all ();
          return true;
        });
    }

    private FilterReturn event_filter (Gdk.XEvent xev, Gdk.Event event) {
        unowned X.Display display = Gdk.X11.get_default_xdisplay ();
        Gdk.FilterReturn return_value = Gdk.FilterReturn.CONTINUE;
        
        X.Event* xevent = (X.Event*) xev;
                 
        if(xevent->type == X.EventType.ClientMessage) {
            if (xevent->xclient.message_type == display.intern_atom ("_NET_SYSTEM_TRAY_OPCODE", false)) {
                if (xevent->xclient.data_l [1] == Message.REQUEST_DOCK) {
                    var id = xevent->xclient.data_l [2];
                    add_client (id);
                    return Gdk.FilterReturn.REMOVE;
                }
            } else {
                    stderr.printf("req: d\n");
            }
        }

        return return_value;
    }

    private bool setup_selection () {
      unowned X.Display display = Gdk.X11.get_default_xdisplay ();
      var screen = get_screen();
      stderr.printf("Tray get selection for %d\n", screen.get_number ());
      var atom = Gdk.Atom.intern ("_NET_SYSTEM_TRAY_S%d".printf(screen.get_number()), false);

      var owner = Selection.owner_get_for_display (get_display (), atom);
      if (owner != null) {
          stderr.printf ("Tray is already owned by someone else.\n");
          return false;
      }

      if (Selection.owner_set_for_display (get_display (), invisible.get_window (), atom, Gdk.CURRENT_TIME, true) == false) {
          stderr.printf ("Unable to claim Tray.\n");
          return false;
      }

      var win = (Gdk.X11.Window) invisible.get_window();
      var xid = (long) win.get_xid ();
      var event = ClientMessageEvent();
      event.type          = X.EventType.ClientMessage;
      event.window        = display.root_window (screen.get_number ()); 
      event.message_type  = display.intern_atom ("MANAGER", false);
      event.format        = 32;
      event.data_l [0]    = Gdk.X11.get_server_time(win);
      event.data_l [1]    = (long) display.intern_atom ("_NET_SYSTEM_TRAY_S%d".printf(screen.get_number()), false);
      event.data_l [2]    = xid;
      event.data_l [3]    = 0;
      event.data_l [4]    = 0;
      display.send_client_event (display.root_window (screen.get_number ()), false, X.EventMask.StructureNotifyMask, ref event);

      ulong data[1] = {0};
      display.change_property (xid, display.intern_atom ("_NET_SYSTEM_TRAY_ORIENTATION,", false), X.XA_CARDINAL, 32, X.PropMode.Replace, (uchar[])data, 1);

      invisible.get_window().add_filter(event_filter);
      stderr.printf("Tray selected");
      return true;
    }

    public PanelTray () {
      stderr.printf ("Tray .\n");
      invisible = new Invisible ();
      invisible.add_events (Gdk.EventMask.PROPERTY_CHANGE_MASK |
                            Gdk.EventMask.STRUCTURE_MASK);

      unowned X.Display display = Gdk.X11.get_default_xdisplay ();
      var visual_atom = display.intern_atom ("_NET_SYSTEM_TRAY_VISUAL", false);

      var visual = get_screen().get_rgba_visual ();
      var xvisual = ((Gdk.X11.Visual)visual).get_xvisual(); 
      ulong      data[1] ={ xvisual.get_visual_id() };
      var xid = (long) ((Gdk.X11.Window) invisible.get_window()).get_xid ();

      display.change_property (xid, visual_atom, X.XA_VISUALID, 32, X.PropMode.Replace,(uchar[])data, 1);
      setup_selection ();
      invisible.realize();
    }


}

