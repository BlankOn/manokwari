using Gtk;
using WebKit;
using JSCore;

public class PanelDesktopHTML: WebView {
    string background_image = "cc";
    unowned JSCore.GlobalContext context = null;
    bool lastBgInitialized = false;

    string translate_uri (string old) {
        var uri = old.replace("http://system", "file://" + Config.SYSTEM_PATH + "/");
        return uri;
    }

    public PanelDesktopHTML () {
        var settings = new WebSettings();
        settings.enable_file_access_from_file_uris = true;
        settings.enable_universal_access_from_file_uris = true;
        set_settings(settings);


        resource_request_starting.connect((frame, resource, request, response) => {
            var uri = translate_uri (resource.uri);
            request.set_uri(uri);
        });

        window_object_cleared.connect ((frame, context) => {
            this.context = (JSCore.GlobalContext) context;
            set_background(background_image);
        });


        load_uri ("http://system/desktop.html");
    }

    public void set_background (string? bg) {
        if (bg == null) {
            return;
        }
        if (context != null) {
            if (lastBgInitialized == false) {
                var g = context.get_global_object ();
                var key = new String.with_utf8_c_string ("lastBg");
                var value = new String.with_utf8_c_string (bg);
                var js_value = new JSCore.Value.string (context, value);
                g.set_property (context, key, js_value, 0, null);
                lastBgInitialized = true;
            }

            var s = new String.with_utf8_c_string ("updateBackground('%s');".printf(bg));

            context.evaluate_script (s, null, null, 0, null);
        }
        background_image = bg;
    }
}
 
