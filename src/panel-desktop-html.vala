using Gtk;
using WebKit;
using JSCore;


public class PanelDesktopHTML: WebView {
    string translate_uri (string old) {
        var uri = old.replace("http://system", "file://" + Config.SYSTEM_PATH + "/");
        return uri;
    }

    public PanelDesktopHTML () {
        set_transparent (true);



        var settings = new WebSettings();
        settings.enable_file_access_from_file_uris = true;
        settings.enable_universal_access_from_file_uris = true;
        settings.javascript_can_open_windows_automatically = true;
        if (Environment.get_variable("MANOKWARI_DEBUG") == null) {
            settings.enable_default_context_menu = false;
        }
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

    public void updateSize () {
        var attributes = get_viewport_attributes ();
        stderr.printf("iii -->\n");
        attributes.recompute ();
    }
}
 
