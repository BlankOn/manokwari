using Gtk;
using Cairo;
using GMenu;

public class PanelButtonWindow : PanelAbstractWindow {

    private ImageSurface surface;
    private PanelMenuBox menuBox;
    private Gdk.Rectangle rect;
    private Gdk.Pixbuf logo;

    public PanelButtonWindow() {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        menuBox = new PanelMenuBox();
        set_visual (this.screen.get_rgba_visual ());

        menuBox.set_transient_for(this);
    
        set_size_request (40,40);
        set_keep_above(true);

        Gdk.RGBA c = Gdk.RGBA();
        c.red = 0.0;
        c.blue = 0.0;
        c.green = 0.0;
        c.alpha = 0.0;
        override_background_color(StateFlags.NORMAL, c);
        set_app_paintable(true);
        
        var screen = get_screen();
        screen.get_monitor_geometry (screen.get_primary_monitor(), out rect);
        move (rect.x, rect.y);

        var icon_theme = IconTheme.get_default();
        logo = icon_theme.load_icon ("distributor-logo", 30, IconLookupFlags.GENERIC_FALLBACK);
    }

    public override bool draw (Context cr)
    {

        if (logo != null)
            Gdk.cairo_set_source_pixbuf (cr, logo, 0, 0);
        cr.paint();
        return false;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        if (menuBox.get_visible ()) { 
            menuBox.hide();
        } else {
            menuBox.show_all ();
        }
        return false;
    }

    public override bool button_release_event (Gdk.EventButton event) {
        //this.menu.activate();
        return false;
    }

}

