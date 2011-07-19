using Gtk;
[DBus (name = "org.freedesktop.DBus")]
interface XDGDBus : Object {
    public abstract uint32 request_name (string name, uint32 flags) throws IOError;
}

int main (string[] args) {

    Intl.bindtextdomain( Config.GETTEXT_PACKAGE, Config.LOCALEDIR );
    Intl.bind_textdomain_codeset( Config.GETTEXT_PACKAGE, "UTF-8" );
    Intl.textdomain( Config.GETTEXT_PACKAGE );

    Gtk.init (ref args);
    CssProvider css = CssProvider.get_default ();
    try {
        css.load_from_path (Config.PKGDATADIR + "/blankon-panel.css");
    }    catch (Error e) {
        stdout.printf ("Unable to load css file\n");
    }

    var m = new PanelButtonWindow();
    m.show_all();

    XDGDBus session =  Bus.get_proxy_sync (BusType.SESSION, 
        "org.freedesktop.DBus", "/org/freedesktop/DBus");
    var r = session.request_name ("org.gnome.Panel", 
        BusNameOwnerFlags.ALLOW_REPLACEMENT | BusNameOwnerFlags.REPLACE);

    if (r != 1 || // DBus.RequestNameReply.PRIMARY_OWNER
        r != 4) { // DBus.RequestNameReply.ALREADYY_OWNER
        stdout.printf ("Panel registration failed: %d\n", (int) r);
    }

    Gtk.main ();
    return 0;
}
