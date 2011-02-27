using Gtk;
using Gdk;
using Cairo;

public class PanelHorizontal : Gtk.Window {
    private Alignment box;
    private Gdk.Rectangle rect;
    private MenuBar bar;

    public PanelHorizontal () {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        box = new Alignment (1, 0, 0, 0);
        add (box);
        set_decorated (false);
        resizable = false;

        bar = new MenuBar ();

        box.add (bar);

        var clock = new PanelClock();
        bar.append (clock);

        box.show_all();

        var screen = get_screen();
        screen.get_monitor_geometry (screen.get_primary_monitor(), out rect);
        move (rect.x, rect.y);
    }

    public override void get_preferred_width (out int min, out int max) {
        // TODO
        min = max = rect.width;
    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = 32; 
    }

}
