
using Gtk;
using WebKit;
using JSCore;

public class PanelMenuHTML: WebView {
    string translate_uri (string old) {
        var uri = old.replace("http://system", "file://" + Config.SYSTEM_PATH);
        stdout.printf("translate uri: " + uri + "\n");
        return uri;
    }

    string translate_theme (string old) {
        var uri = "file://%s".printf(Utils.get_icon_path (old.replace("theme://", "")));
        stdout.printf("translate theme: " + uri + "\n");
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

        var settings = new WebKit.Settings();
        settings.allow_file_access_from_file_urls = true;
        settings.allow_universal_access_from_file_urls = true;

        // FIX: Webkit2
        //  if (Environment.get_variable("MANOKWARI_DEBUG") == null) {
        //      settings.enable_default_context_menu = false;
        //  }
        set_settings(settings);

        // FIX: Webkit2 web-extension
        //  window_object_cleared.connect ((frame, context) => {
        //      PanelXdgData.setup_js_class ((JSCore.GlobalContext) context);
        //      Utils.setup_js_class ((JSCore.GlobalContext) context);
        //      PanelPlaces.setup_js_class ((JSCore.GlobalContext) context);
        //      PanelSessionManager.setup_js_class ((JSCore.GlobalContext) context);
        //      PanelUser.setup_js_class ((JSCore.GlobalContext) context);
        //  });
    }

    public void start(string uri) {
        if (uri.has_prefix("theme://")) {
            load_uri(translate_theme(uri));
        } else {
            load_uri(translate_uri (uri));
        }
    }

    // FIX: Webkit2 web-extension
    //  public void triggerShowAnimation () {
    //      unowned JSCore.Context context = get_focused_frame ().get_global_context();
    //      var s = new String.with_utf8_c_string ("menu.prepareShow()");
    //      context.evaluate_script (s, null, null, 0, null);
    //  }

    //  public void triggerHideAnimation () {
    //      unowned JSCore.Context context = get_focused_frame ().get_global_context();
    //      var s = new String.with_utf8_c_string ("menu.prepareHide()");
    //      context.evaluate_script (s, null, null, 0, null);
    //  }

    //  public bool handleEsc() {
    //      unowned JSCore.Context context = get_focused_frame ().get_global_context();
    //      var s = new String.with_utf8_c_string ("menu.handleEsc()");
    //      var r = context.evaluate_script (s, null, null, 0, null);
    //      if (r.is_boolean (context)) {
    //          return r.to_boolean (context);
    //      }

    //      return false;
    //  }


}

