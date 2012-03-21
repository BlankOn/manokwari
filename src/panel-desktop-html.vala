using Gtk;
using WebKit;
using JSCore;

[DBus (name = "org.gnome.ScreenSaver")]
interface ScreenSaver: GLib.Object {
    public abstract void simulate_user_activity () throws IOError;
    public signal void active_changed (bool active);
}

public class PanelDesktopHTML: WebView {
    ScreenSaver screensaver = null;

    public signal void idle_activated();

    string translate_uri (string old) {
        var uri = old.replace("http://system", "file://" + Config.SYSTEM_PATH + "/");
        return uri;
    }

    public PanelDesktopHTML () {
        set_transparent (true);


        try {
            screensaver =  Bus.get_proxy_sync (BusType.SESSION,
                                           "org.gnome.ScreenSaver", "/org/gnome/ScreenSaver");
        } catch (Error e) {
            stderr.printf ("Unable to connect to screen saver\n");
        }

        if (screensaver != null) {
            screensaver.active_changed.connect((active) =>  {
                if (active) {
                    idle_activated ();
                    try {
                        screensaver.simulate_user_activity ();
                    } catch (Error e) {

                        stderr.printf ("Unable to connect to screen saver: %s\n", e.message);
                    }
                }
            });
        }

        var settings = new WebSettings();
        settings.enable_file_access_from_file_uris = true;
        settings.enable_universal_access_from_file_uris = true;
        settings.javascript_can_open_windows_automatically = true;
        settings.enable_default_context_menu = false;
        set_settings(settings);


        resource_request_starting.connect((frame, resource, request, response) => {
            var uri = translate_uri (resource.uri);
            request.set_uri(uri);
        });

        window_object_cleared.connect ((frame, context) => {
            PanelDesktopData.setup_js_class ((JSCore.GlobalContext) context);
            Utils.setup_js_class ((JSCore.GlobalContext) context);
        });

        load_uri ("http://system/desktop.html");
    }
}
 
