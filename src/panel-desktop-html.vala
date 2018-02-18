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
        
        var settings = new WebKit.Settings();
        settings.set_enable_javascript(true);
        settings.allow_file_access_from_file_urls = true;
        settings.allow_universal_access_from_file_urls = true;
        settings.javascript_can_open_windows_automatically = true;
        settings.set_hardware_acceleration_policy(WebKit.HardwareAccelerationPolicy.NEVER);

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
        
        load_uri(translate_uri("http://system/desktop.html"));
    }
    
    //  FIX: Webkit2
    //  public void updateSize () {
    //      var attributes = get_viewport_attributes ();
    //      stderr.printf("iii -->\n");
    //      attributes.recompute ();
    //  }
}
