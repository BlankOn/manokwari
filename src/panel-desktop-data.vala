using GMenu;
using GLib;
using JSCore;
using Gtk;

// This class prepares data in desktop 
public class PanelDesktopData {

    FileMonitor desktop_monitor = null;
    StringBuilder json; // use StringBuilder to avoid appending immutable strings
    static Context* jsContext;
    JSCore.Object* jsObject;
    uint scheduled = 0;
    uint64 last_schedule = 0;
    string path;

    public signal void changed ();

    public PanelDesktopData () {
        path = Environment.get_user_special_dir (UserDirectory.DESKTOP);
        json = new StringBuilder ();
        monitor();

        changed.connect (() => {
            if (scheduled > 0) {
                // It is already scheduled to update
                return;
            }

            // Not yet scheduled, let's make time
            schedule_for_kick_js ();
        });

    }

    void schedule_for_kick_js () {
        var d = new DateTime.now_local();
        if (d.to_unix () - last_schedule > 1) {
            // Last update was over a second ago
            // Let's kick JS now
            kick_js ();
        } else  {
            // It's recently kicked,
            // if it's not yet scheduled, let's do it
            // otherwise just skip this request
            if (scheduled == 0) {
                // schedule to kick JS in the next second 
                scheduled = Timeout.add (1000, kick_js);
            }
        }
    }

    bool kick_js () {
        if (jsContext != null && jsObject != null) {

            var s = new String.with_utf8_c_string ("updateCallback");
            var v = jsObject->get_property (jsContext, s, null);
            if (v != null) {
                s = v.to_string_copy (jsContext, null);
                char buffer[1024];
                s.get_utf8_c_string (buffer, buffer.length);
                jsContext->evaluate_script (s, null, null, 0, null);
                s = null;
            }
        }
        // Save the time
        var d = new DateTime.now_local();
        last_schedule = d.to_unix ();
        
        // Say that we're done
        scheduled = 0;
        return false;
    }


    void monitor () {
        var desktop_dir = File.new_for_path (path);
        try {
            desktop_monitor = desktop_dir.monitor (FileMonitorFlags.NONE, null);
            desktop_monitor.changed.connect (() => {
                changed();
            });
        } catch (Error e) {
            stdout.printf ("Can't monitor desktop directory: %s\n", e.message);
        }
    }

    void update_tree () {
        try {
            var dir = Dir.open (path, 0);
            while (true) {
                var name = dir.read_name ();
                if (name == null) {
                    break;
                }
                if (name.has_suffix (".desktop")) {
                    var info = new DesktopAppInfo.from_filename (path + "/" + name);
                    var s = "{icon: '%s', name: '%s', desktop: '%s'},".printf(
                                Utils.get_icon_path(info.get_icon ().to_string (), 120),
                                info.get_name (),
                                name
                            );
                    json.append (s);
                }
            }
        } catch (FileError e) {
            stdout.printf ("Unable to open desktop directory: %s\n", e.message);
        }
    }

    void populate () { 
        json.assign("[");
        update_tree ();
        if (json.str [json.len - 1] == ',') {
            json.erase (json.len - 1, 1); // Remove trailing comma
        }
        json.append("]");
    }


    static void remove_from_desktop (string filename) {
        var path = Environment.get_user_special_dir (UserDirectory.DESKTOP) + "/" + filename;
        var file = File.new_for_path (path);
        if (file.query_exists ()) {
            try {
                file.delete ();
            } catch (Error e) {
            }
        };
    }

    public static JSCore.Object js_constructor (Context ctx,
            JSCore.Object constructor,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        exception = null;
        var c = new Class (js_class);
        var o = new JSCore.Object (ctx, c, null);
        var s = new String.with_utf8_c_string ("update");
        var f = new JSCore.Object.function_with_callback (ctx, s, js_update);
        o.set_property (ctx, s, f, 0, null);
        s = new String.with_utf8_c_string ("updateCallback");
        f = new JSCore.Object.function_with_callback (ctx, s, js_set_update_callback);
        o.set_property (ctx, s, f, 0, null);

        PanelDesktopData* i = new PanelDesktopData ();
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
        var i = thisObject.get_private() as PanelDesktopData; 
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
        var i = thisObject.get_private() as PanelDesktopData;
        if (i != null) {
            i.populate ();
            var s = new String.with_utf8_c_string (i.json.str);
            var r = ctx.evaluate_script (s, null, null, 0, null);
            s = null;
            i.json.assign ("");
            return r;
        }
        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_remove_from_desktop (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        exception = null;
        if (arguments.length == 1) {
            var s = arguments [0].to_string_copy (ctx, null);
            char buffer[1024];
            s.get_utf8_c_string (buffer, buffer.length);
            remove_from_desktop ((string) buffer);
        }

        return new JSCore.Value.undefined (ctx);
    }

    static const JSCore.StaticFunction[] js_funcs = {
        { "removeFromDesktop", js_remove_from_desktop, PropertyAttribute.ReadOnly },
        { null, null, 0 }
    };

    static const ClassDefinition js_class = {
        0,
        ClassAttribute.None,
        "DesktopData",
        null,

        null,
        js_funcs,

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
        var s = new String.with_utf8_c_string ("DesktopData");
        g.set_property (context, s, o, PropertyAttribute.None, null);
    }

}
