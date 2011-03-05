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

public class PanelClock : PanelItem {
    private string clock_label = "00:00";
    private PanelClockWindow window;
    private bool active = false;

    public PanelClock() {
        base ();
        window = new PanelClockWindow ();

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
