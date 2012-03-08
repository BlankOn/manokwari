using Gtk;

public class PanelClock : Label {
	
    private const int MARGIN = 10;
    private Pango.Layout pango;

	public PanelClock () {
        pango = new Pango.Layout (get_pango_context ());
        pango.set_alignment (Pango.Alignment.CENTER);
		Timeout.add (1000 * 30, update);
        update ();

	}
	
	private bool update () {
		char bufferClock[100];
		Time t = Time.local (time_t ());
		t.strftime (bufferClock, _("%a, %e %b %Y %H:%M"));

        StyleContext style = get_style_context ();
        pango.set_font_description (style.get_font (get_state_flags ()));
        pango.set_markup ((string) bufferClock, -1);

        int text_w, text_h;
        pango.get_pixel_size (out text_w, out text_h);

        set_size_request (text_w + MARGIN, text_h);
        queue_draw ();
		return true;
	}
	
	public override bool draw (Cairo.Context cr) {
        StyleContext style = get_style_context ();
        style.set_state (get_state_flags ());
        Gtk.render_layout (style, cr, MARGIN/2, 0, pango);
        return true;
    }
	
}


