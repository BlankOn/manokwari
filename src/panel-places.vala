using Gtk;
using GLib;
using JSCore;

public class PanelPlaces {
    StringBuilder json;
    static Context* jsContext;
    JSCore.Object* jsObject;

    private VolumeMonitor vol_monitor;
    private File bookmark_file;
    private FileMonitor bookmark_monitor;

    public signal void error ();
    public signal void launching ();

    public PanelPlaces () {
        json = new StringBuilder ();

        vol_monitor = VolumeMonitor.get ();
        bookmark_file = File.new_for_path (Environment.get_home_dir () + "/.gtk-bookmarks");
        try {
            bookmark_monitor = bookmark_file.monitor_file (FileMonitorFlags.NONE, null);
        } catch (Error e) {
            stdout.printf ("Can't monitor bookmark file: %s", e.message);
        }

        init_contents ();

        vol_monitor.mount_added.connect (() => {
            reset ();
        });
        vol_monitor.mount_changed.connect (() => {
            reset ();
        });
        vol_monitor.mount_removed.connect (() => {
            reset ();
        });

        bookmark_monitor.changed.connect (() => {
            reset ();
        });
    }

    public void reset () {

        json.assign ("");
        init_contents ();

        if (jsContext != null && jsObject != null) {

            var s = new String.with_utf8_c_string ("updateCallback");
            var v = jsObject->get_property (jsContext, s, null);
            if (v != null) {
                s = v.to_string_copy (jsContext, null);
                jsContext->evaluate_script (s, null, null, 0, null);
            }
        }
    }

    private void init_contents () {
        json.append("[");
        setup_home ();
        setup_special_dirs ();
        setup_mounts ();
        if (json.str [json.len - 1] == ',') {
            json.erase (json.len - 1, 1); // Remove trailing comma
        }
        json.append("]");
    }

    private void setup_home () {
        var f = File.new_for_path (Environment.get_home_dir ());
        var s = "{icon: '%s', name: '%s', uri: '%s'},".printf(
                    Utils.get_icon_path("gtk-home"),
                    _("Home"),
                    f.get_uri ()
                );

        json.append (s);
    }

    private void setup_special_dirs () {
        json.append("{name: '%s', isHeader: true},".printf(
                _("Bookmarks")
            ));

        for (int i = UserDirectory.DESKTOP; i < UserDirectory.N_DIRECTORIES; i ++) {
            var path = Environment.get_user_special_dir ((UserDirectory) i);
            if (path == null)
                continue;

            var icon = "gtk-directory";
            if (i == (int) UserDirectory.DESKTOP)
                icon = "desktop";

            var f = File.new_for_path (path);
            var s = "{icon: '%s', name: '%s', uri: '%s'},".printf(
                        Utils.get_icon_path(icon),
                        Filename.display_basename(path),
                        f.get_uri ()
                     );

            json.append (s);

        }


        if (bookmark_file.query_exists ()) {
            try {
                var input = new DataInputStream (bookmark_file.read ());
                string line;
                while ((line = input.read_line (null)) != null) {
                    var fields = line.split (" ");
                    if (fields.length == 2) {
                        var s = "{icon: '%s', name: '%s', uri: '%s'},".printf(
                                    Utils.get_icon_path("gtk-directory"),
                                    fields [1],
                                    fields [0]
                                 );
                        json.append (s);
                    }
                }
                input.close ();
            } catch (Error e) {
                stdout.printf ("Unable to read the bookmarks\n");
            }
        }

    }

    private void setup_mounts () {
        bool first_entry = false;
        var mounts = vol_monitor.get_mounts ();
        // This apparently can't be iterated using "foreach"
        for (int i = 0; i < mounts.length(); i ++) {
            var mount = mounts.nth_data (i);
            if (mount == null)
                continue;

            if (first_entry == false) {
                json.append("{name: '%s', isHeader: true},".printf(
                    _("Mounts")
                ));
                first_entry = true;
            }

            var s = "{icon: '%s', name: '%s', uri: '%s'},".printf(
                        Utils.get_icon_path("drive-harddisk"),     // Utils.get_icon_path(mount.get_icon ().to_string ()),
                        mount.get_name (),
                        mount.get_root ().get_uri ()
                     );
            json.append (s);
        }
    }

    public static JSCore.Object js_constructor (Context ctx,
            JSCore.Object constructor,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        exception = null;
        var c = new Class (js_class);
        var o = new JSCore.Object (ctx, c, null);
        var s = new String.with_utf8_c_string ("updateCallback");
        var f = new JSCore.Object.function_with_callback (ctx, s, js_set_update_callback);
        o.set_property (ctx, s, f, 0, null);


        s = new String.with_utf8_c_string ("update");
        f = new JSCore.Object.function_with_callback (ctx, s, js_update);
        o.set_property (ctx, s, f, 0, null);
        
        PanelPlaces* i = new PanelPlaces ();
        o.set_private (i);
        i->jsObject = o;
        return o;
    }

    public static JSCore.Value js_set_update_callback (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,

            out JSCore.Value exception) {

        exception = null;
        var i = thisObject.get_private() as PanelPlaces; 
        if (i != null && arguments.length == 1) {
            var s = new String.with_utf8_c_string ("updateCallback");
            thisObject.set_property (ctx, s, arguments[0], 0, null);
        }

        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_update (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,

            out JSCore.Value exception) {

        exception = null;
        var i = thisObject.get_private() as PanelPlaces; 
        if (i != null) {
            var result = i.get_json();
            var s = new String.with_utf8_c_string (result);
            return ctx.evaluate_script (s, null, null, 0, null);
        }
        return new JSCore.Value.undefined (ctx);
    }


    static const ClassDefinition js_class = {
        0,
        ClassAttribute.None,
        "Places",
        null,

        null,
        null,

        null,
        null,

        null,
        null,
        null,
        null,

        null,
        null,
        js_constructor,
        null,
        null
    };

    public static void setup_js_class (GlobalContext context) {
        jsContext = context;
        var c = new Class (js_class);
        var o = new JSCore.Object (context, c, context);
        var g = context.get_global_object ();
        var s = new String.with_utf8_c_string ("Places");
        g.set_property (context, s, o, PropertyAttribute.None, null);
    }

    string get_json () {
        return json.str;
    }

}
