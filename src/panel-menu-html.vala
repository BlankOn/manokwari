public class PanelMenuHTML: WebKit.WebView {
    bool handleEsc_ret;

    private string translate_uri(string old) {
        var uri = old.replace("http://system", "file://" + Config.SYSTEM_PATH);
        stdout.printf("translate uri: " + uri + "\n");
        return uri;
    }

    private string translate_theme(string old) {
        var uri = "file://%s".printf(Utils.get_icon_path (old.replace("theme://", "")));
        stdout.printf("translate theme: " + uri + "\n");
        return uri;
    }

    public PanelMenuHTML() {
        set_visual(Gdk.Screen.get_default().get_rgba_visual());

        Gdk.RGBA panel_color = Gdk.RGBA() {
            red = 0.0, blue = 0.0, green = 0.0, alpha = 0.0
        };
        
        set_background_color(panel_color);
        set_app_paintable(true);

        var settings = new WebKit.Settings();
        settings.set_enable_javascript(true);
        settings.allow_file_access_from_file_urls = true;
        settings.allow_universal_access_from_file_urls = true;
        settings.set_hardware_acceleration_policy(WebKit.HardwareAccelerationPolicy.NEVER);

        if (GLib.Environment.get_variable("MANOKWARI_DEBUG") == null) {
            context_menu.connect((ctx_menu, event, hts) => {
                return true;
            });
        }
        
        set_settings(settings);
        
        resource_load_started.connect((resource, request) => {
            request.set_uri(resource.uri);
        });

        handleEsc_ret = false;
    }

    public void start(string uri) {
        if (uri.has_prefix("theme://")) {
            load_uri(translate_theme(uri));
        } else {
            load_uri(translate_uri (uri));
        }
    }

    public void triggerShowAnimation() {
        run_javascript.begin("menu.prepareShow()", null, (obj, res) => {
            try {
                run_javascript.end(res);
            } catch (Error e) {
                stdout.printf("triggerShowAnimation: \"%s\"\n", e.message);
            }
        });
    }

    public void triggerHideAnimation() {
        run_javascript.begin("menu.prepareHide()", null, (obj, res) => {
            try {
                run_javascript.end(res);
            } catch (Error e) {
                stdout.printf("triggerHideAnimation: \"%s\"\n", e.message);
            }
        });
    }

    public bool handleEsc() {
        try {
            run_javascript.begin("menu.handleEsc()", null, (obj, res) => {
                WebKit.JavascriptResult ret = run_javascript.end(res);
                unowned JS.GlobalContext ctx = ret.get_global_context();
                unowned JS.Value val = ret.get_value();
                if (val.is_boolean(ctx)) {
                    this.handleEsc_ret = val.to_boolean(ctx);
                }
            });
            return this.handleEsc_ret;
        } catch (Error e) {
            stdout.printf("handleEsc: \"%s\"\n", e.message);
        }
        return false;
    }
}
