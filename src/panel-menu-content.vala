using GMenu;
using Gtk;

// This class provides a header and containter to put contents 
public class PanelMenuContent : VBox {
    protected VBox bar;

    public signal void menu_clicked ();

    public PanelMenuContent (string? label) {

        if (label != null) {
            var l = new Label ("");
            l.set_markup ("<big>\n" + label + "</big>");
            pack_start (l, false, false, 5);
        }
    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = 300;
    }

    public void insert_separator () {
        pack_start (new Separator (Orientation.HORIZONTAL), false, false, 10);
    }
}
