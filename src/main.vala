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

    var m = new PanelButtonWindow();
    m.show_all();

    try {
        XDGDBus session =  Bus.get_proxy_sync (BusType.SESSION, 
            "org.freedesktop.DBus", "/org/freedesktop/DBus");
        var r = session.request_name ("org.gnome.Panel", 
            BusNameOwnerFlags.ALLOW_REPLACEMENT | BusNameOwnerFlags.REPLACE);

        if (r != 1 || // DBus.RequestNameReply.PRIMARY_OWNER
            r != 4) { // DBus.RequestNameReply.ALREADYY_OWNER
            stdout.printf ("Panel registration failed: %d\n", (int) r);
        }
    } catch (Error e) {
        stdout.printf ("Unable to claim Panel to gnome-session");
    }

    Gtk.main ();
    return 0;
}
