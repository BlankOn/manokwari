using WebKit;
using JSCore;

public class PanelDesktopIdleView: WebView {
    string translate_uri (string old) {
        var uri = old.replace("http://system", "file://" + Config.SYSTEM_PATH + "/");
        return uri;
    }

    public PanelDesktopIdleView () {
        var settings = new WebSettings();
        settings.enable_file_access_from_file_uris = true;
        settings.enable_universal_access_from_file_uris = true;
        settings.javascript_can_open_windows_automatically = true;
        settings.enable_default_context_menu = false;
        set_settings(settings);

        set_transparent (true);

        resource_request_starting.connect((frame, resource, request, response) => {
            var uri = translate_uri (resource.uri);
            request.set_uri(uri);
        });

        window_object_cleared.connect ((frame, context) => {
            Utils.setup_js_class ((JSCore.GlobalContext) context);
        });


        load_uri ("http://system/idle.html");

    }

    public void triggerHideAnimation () {
        unowned JSCore.Context context = get_focused_frame ().get_global_context();
        var s = new String.with_utf8_c_string ("idle.hideIdleScreen()");
        context.evaluate_script (s, null, null, 0, null);
    }

    public void triggerShowAnimation () {
        unowned JSCore.Context context = get_focused_frame ().get_global_context();
        var s = new String.with_utf8_c_string ("idle.showIdleScreen()");
        context.evaluate_script (s, null, null, 0, null);
    }

    public void set_background (string bg) {
        unowned JSCore.Context context = get_main_frame ().get_global_context();
        var s = new String.with_utf8_c_string ("idle.setBackground('" + bg + "')");
        context.evaluate_script (s, null, null, 0, null);
    }


}

