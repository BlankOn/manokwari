using GMenu;
using Gtk;

// This class provides a header and containter to put contents 
public class PanelMenuContent : PanelScrollableContent {
    protected VBox bar;

    public signal void menu_clicked ();

    public PanelMenuContent (string? label) {
        bar = new VBox (false, 0);
        set_widget (bar);
        set_scrollbar_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);

        var filler = new DrawingArea ();
        filler.set_size_request (300, 20);

        bar.pack_start (filler, false, false, 0);
        if (label != null) {
            var l = new Label ("");
            l.set_markup ("<big>" + label + "</big>");
            bar.pack_start (l, false, false, 5);
        }
    }


    public void insert_separator () {
        bar.pack_start (new Separator (Orientation.HORIZONTAL), false, false, 10);
    }
}
