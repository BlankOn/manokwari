
using Gtk;
using WebKit;
using JSCore;

public class PanelMenuHTML: WebView {
    string translate_uri (string old) {
        var uri = old.replace("http://system", "file://" + Config.SYSTEM_PATH + "/");
        return uri;
    }

    string translate_theme (string old) {
        var uri = "file://%s".printf(Utils.get_icon_path (old.replace("theme://", "")));
        return uri;
    }

    public PanelMenuHTML () {
        set_visual (Gdk.Screen.get_default ().get_rgba_visual ());

        Gdk.RGBA c = Gdk.RGBA();
        c.red = 0.0;
        c.blue = 0.0;
        c.green = 0.0;
        c.alpha = 0.0;
        override_background_color(StateFlags.NORMAL, c);
        set_app_paintable(true);

        set_transparent (true);
        var settings = new WebSettings();
        settings.enable_file_access_from_file_uris = true;
        settings.enable_universal_access_from_file_uris = true;

        if (Environment.get_variable("MANOKWARI_DEBUG") == null) {
            settings.enable_default_context_menu = false;
        }
        set_settings(settings);

        resource_request_starting.connect((frame, resource, request, response) => {
            if (resource.uri.has_prefix("theme://")) {
                request.set_uri(translate_theme(resource.uri));
            } else {
                var uri = translate_uri (resource.uri);
                request.set_uri(uri);
            }
        });

        window_object_cleared.connect ((frame, context) => {
            PanelXdgData.setup_js_class ((JSCore.GlobalContext) context);
            Utils.setup_js_class ((JSCore.GlobalContext) context);
            PanelPlaces.setup_js_class ((JSCore.GlobalContext) context);
            PanelSessionManager.setup_js_class ((JSCore.GlobalContext) context);
            PanelUser.setup_js_class ((JSCore.GlobalContext) context);
        });
    }

    public void start() {
        load_uri ("http://system/menu.html");
    }

    public void triggerShowAnimation () {
        unowned JSCore.Context context = get_focused_frame ().get_global_context();
        var s = new String.with_utf8_c_string ("menu.prepareShow()");
        context.evaluate_script (s, null, null, 0, null);
    }

    public void triggerHideAnimation () {
        unowned JSCore.Context context = get_focused_frame ().get_global_context();
        var s = new String.with_utf8_c_string ("menu.prepareHide()");
        context.evaluate_script (s, null, null, 0, null);
    }

    public bool handleEsc() {
        unowned JSCore.Context context = get_focused_frame ().get_global_context();
        var s = new String.with_utf8_c_string ("menu.handleEsc()");
        var r = context.evaluate_script (s, null, null, 0, null);
        if (r.is_boolean (context)) {
            return r.to_boolean (context);
        }

        return false;
    }


}

