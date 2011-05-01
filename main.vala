using Gtk;

int main (string[] args) {


    Gtk.init (ref args);
    CssProvider css = CssProvider.get_default ();
    try {
        css.load_from_path ("/home/mdamt/src/blankon-panel/blankon-panel.css");
    }    catch (Error e) {
        stdout.printf ("Unable to load css file\n");
    }

    var h = new PanelHorizontal();
    h.destroy.connect (Gtk.main_quit);

    var m = new PanelButtonWindow();
    m.set_transient_for(h);

    h.show_all ();
    m.show_all();

    var w = new PanelWindowHost ();
    w.show();

    Gtk.main ();
    return 0;
}
