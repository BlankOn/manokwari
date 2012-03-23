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

    var id = GLib.Environment.get_variable("DESKTOP_AUTOSTART_ID");
    var app = new Unique.App ("id.or.blankonlinux.Manokwari", id);
    if (app.is_running ()) {
        stdout.printf ("Manokwari is already running.\n");
        return 0;    
    }

    PanelSessionManager.getInstance ();
    try {
        XDGDBus session =  Bus.get_proxy_sync (BusType.SESSION, 
            "org.freedesktop.DBus", "/org/freedesktop/DBus");

        if (session != null) {
            var r = session.request_name ("org.gnome.Panel", 
                BusNameOwnerFlags.ALLOW_REPLACEMENT | BusNameOwnerFlags.REPLACE);

            if (r != 1 || // DBus.RequestNameReply.PRIMARY_OWNER
                r != 4) { // DBus.RequestNameReply.ALREADYY_OWNER
                stdout.printf ("Panel registration failed: %d\n", (int) r);
            }
        }
    } catch (Error e) {
        stdout.printf ("Unable to claim Panel to gnome-session");
    }


    // Desktop
    var d = new PanelDesktop ();
    d.show ();

    // Window 
    var w = new PanelWindowHost ();
    w.show();

    var menu_box = new PanelMenuBox();
    // SIGNALS
    w.menu_clicked.connect (() => {
        if (menu_box.visible) {
            menu_box.try_hide ();
        } else {
            // Otherwise we want to show it
            menu_box.show ();
        }
    });

    w.dialog_opened.connect (() => {
        if (menu_box.visible) {
            menu_box.try_hide ();
        }
    });

    d.desktop_clicked.connect (() => {
        if (menu_box.visible) {
            menu_box.try_hide ();
        }
    });

    w.windows_visible.connect (() => {
        if (menu_box.visible) {
            menu_box.try_hide ();
        }
    });


    Gtk.main ();
    return 0;
}
