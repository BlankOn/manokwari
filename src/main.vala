static int main (string[] args) {
    var settings = new GLib.Settings ("org.gnome.system.locale");
    var region = settings.get_string ("region");

    if (region != null && region != "") {
      GLib.Environment.set_variable("LC_MESSAGES", region, true);
      GLib.Environment.set_variable("LC_TIME", region, true);
      GLib.Environment.set_variable("LC_ALL", region, true);
      GLib.Environment.set_variable("LANG", region, true);
    }

    Intl.setlocale(LocaleCategory.ALL, "");
    Intl.setlocale(LocaleCategory.MESSAGES, "");
    Intl.setlocale(LocaleCategory.TIME, "");

    Intl.bindtextdomain( Config.GETTEXT_PACKAGE, Config.LOCALEDIR );
    Intl.bind_textdomain_codeset( Config.GETTEXT_PACKAGE, "UTF-8" );
    Intl.textdomain( Config.GETTEXT_PACKAGE );

 
    Gtk.init (ref args);

    var context = WebKit.WebContext.get_default();
    context.initialize_web_extensions.connect((event) => {
        GLib.print("SIGNAL: initialize-web-extensions (webext) \n");
        context.set_web_extensions_directory("/usr/lib64/manokwari/system");
        return;
    });

    var id = GLib.Environment.get_variable("DESKTOP_AUTOSTART_ID");
    var app = new Unique.App ("id.or.blankonlinux.Manokwari", id);
    if (app.is_running ()) {
        stdout.printf ("Manokwari is already running.\n");
        return 0;    
    }

    // Shell
    var manoshell = new PanelShell();

    // Desktop
    var manodesk = new PanelDesktop ();
    manodesk.show ();

    // Window 
    var manowin = new PanelWindowHost ();
    manowin.show();

    var menu_box = new PanelMenuBox();
    // SIGNALS
    manowin.menu_clicked.connect (() => {
        if (menu_box.visible) {
            menu_box.try_hide ();
        } else {
            // Otherwise we want to show it
            menu_box.show ();
        }
    });

    manowin.dialog_opened.connect (() => {
        if (menu_box.visible) {
            menu_box.try_hide ();
        }
    });

    manodesk.desktop_clicked.connect (() => {
        if (menu_box.visible) {
            menu_box.try_hide ();
        }
    });

    manowin.windows_visible.connect (() => {
        if (menu_box.visible) {
            menu_box.try_hide ();
        }
    });

    Gtk.main ();
    return 0;
}
