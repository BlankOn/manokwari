using GMenu;
using Gtk;

// This class provides a header and containter to put contents
public class PanelExtraContent : VBox {
    protected VBox bar;

    public signal void extra_clicked ();

    public PanelExtraContent (string? label) {

        if (label != null) {
            var l = new Label ("");
            l.set_markup ("<big>\n" + label + "</big>");
            l.show ();
            pack_end (l, false, false, 5);
        }
        show_all ();
    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = 260;
    }

    public void insert_separator () {
        var separator = new Separator (Orientation.HORIZONTAL);
        separator.show ();
        pack_end (separator, false, false, 10);
    }
}
