using Gtk;

int main (string[] args) {
    Gtk.init (ref args);


    var h = new PanelHorizontal();
    h.destroy.connect (Gtk.main_quit);

    var m = new PanelButtonWindow();
    m.set_transient_for(h);

    m.show_all();
    h.show_all ();

    Gtk.main ();
    return 0;
}
