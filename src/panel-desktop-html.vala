public class PanelDesktopHTML: WebKit.WebView {
    GLib.Settings gsettings = null;
    string translate_uri (string old) {
        var uri = old.replace("http://system", "file://" + Config.SYSTEM_PATH);
        return uri;
    }

    public PanelDesktopHTML () {
        Gdk.RGBA panel_color = Gdk.RGBA() {
            red = 0.0, blue = 0.0, green = 0.0, alpha = 0.0
        };

        set_app_paintable(true);
        set_background_color(panel_color);

        gsettings = new GLib.Settings ("org.gnome.desktop.background");
        gsettings.changed["picture-uri"].connect (() => {
            setBackground();
        });
        
        var settings = new WebKit.Settings();
        settings.set_enable_javascript(true);
        settings.allow_file_access_from_file_urls = true;
        settings.allow_universal_access_from_file_urls = true;
        settings.javascript_can_open_windows_automatically = true;

        if (GLib.Environment.get_variable("MANOKWARI_DEBUG") == null) {
            context_menu.connect((ctx_menu, event, hts) => {
                return true;
            });
        }

        set_settings(settings);
        
        resource_load_started.connect((resource, request) => {
            var uri = translate_uri (resource.uri);
            request.set_uri(uri);
        });
        
        load_changed.connect((event) => {
            if (event == WebKit.LoadEvent.FINISHED) {
                setBackground();
            }
        });

        load_uri(translate_uri("http://system/desktop.html"));
    }
    
    bool setBackground () { 
        var uri = gsettings.get_string("picture-uri");
        try {
            run_javascript.begin("desktop.setBackground('"+ uri + "')", null, (obj, res) => {
                WebKit.JavascriptResult ret = run_javascript.end(res);
                unowned JS.GlobalContext ctx = ret.get_global_context();
                unowned JS.Value val = ret.get_value();
                if (!val.is_boolean(ctx)) {
                    Timeout.add(500, setBackground);
                }
            });
        } catch (Error e) {
            stdout.printf("setBackground: \"%s\"\n", e.message);
        }
        return false;
    }

    //  FIX: Webkit2
    //  public void updateSize () {
    //      var attributes = get_viewport_attributes ();
    //      stderr.printf("iii -->\n");
    //      attributes.recompute ();
    //  }
}
