using Cairo;
using Gtk;

public class PanelClockWindow : Window {
    
    public PanelClockWindow () {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        set_decorated (false);
        resizable = false;

        var box = new VBox (false, 10);
        add (box);

        var calendar = new Calendar ();
        box.pack_start (calendar, false, false);
    }
}

public class PanelClock : MenuItem {
    private string clock_label = "00:00";
    private PanelClockWindow window;
    private bool active = false;

    public PanelClock() {
        window = new PanelClockWindow ();

        // TODO move these into a base class
        leave_notify_event.connect (() => {
            deselect ();
            return true;
        });

        enter_notify_event.connect (() => {
            select ();
            return true;
        });


        activate.connect (() => {
            if (active) {
                window.hide ();
                active = false;
            } else {
                active = true;
                var screen = get_screen();
                Gdk.Rectangle rect;
                screen.get_monitor_geometry (screen.get_primary_monitor(), out rect);

                window.show_all (); 
                var x = rect.x + rect.width - get_allocated_width ();
                if (x + window.get_allocated_width () > rect.x + rect.width)
                    x = rect.x + rect.width - window.get_allocated_width ();

                window.move (x, get_allocated_height ());
            }
        });
        update_data();
    }

    public void update_data ()
    {
        // Update the label here
        set_label (clock_label);
    }
}
