using GMenu;
using GLib;
using JSCore;
using Gtk;

// This class opens an xdg menu and populates it
public class PanelXdgData {

    string catalog;
    StringBuilder json; // use StringBuilder to avoid appending immutable strings
    IconTheme icon;
    static Context* jsContext;
    JSCore.Object* jsObject;

    public signal void changed ();

    public PanelXdgData (string catalog) {
        json = new StringBuilder ();
        this.catalog = catalog;
        icon = IconTheme.get_default ();
        monitor();

        changed.connect (() => {
            if (jsContext != null && jsObject != null) {

                var s = new String.with_utf8_c_string ("updateCallback");
                var v = jsObject->get_property (jsContext, s, null);
                if (v != null) {
                    s = v.to_string_copy (jsContext, null);
            char buffer[1024];
            s.get_utf8_c_string (buffer, buffer.length);
            stdout.printf("%s\n", (string) buffer);
                    jsContext->evaluate_script (s, null, null, 0, null);
                }
            }
        });

    }

    void monitor () {
        var xdg_menu_dir = File.new_for_path ("/etc/xdg/menus");
        try {
            var xdg_menu_monitor = xdg_menu_dir.monitor (FileMonitorFlags.NONE, null);
            xdg_menu_monitor.changed.connect (() => {
                changed();
            });
        } catch (Error e) {
            stdout.printf ("Can't monitor /etc/xdg/menus directory: %s\n", e.message);
        }
        var apps_dir = File.new_for_path ("/usr/share/applications");
        try {
            var apps_monitor = apps_dir.monitor (FileMonitorFlags.NONE, null);
            apps_monitor.changed.connect (() => {
                changed();
            });
        } catch (Error e) {
            stdout.printf ("Can't monitor applications directory: %s\n", e.message);
        }

    }

    void update_tree (TreeDirectory root) {
        foreach (TreeItem item in root.get_contents ()) {
            switch (item.get_type()) {
            case TreeItemType.DIRECTORY:
                var i = (TreeDirectory) item;

                var s = "{icon: '%s', name: '%s',".printf(
                            Utils.get_icon_path(i.get_icon ().replace(".svg", "").replace(".png", "").replace(".xpm","")),
                            i.get_name ()
                        );
                json.append (s);
                json.append ("children:[");
                update_tree (i);
                if (json.str [json.len - 1] == ',') {
                    json.erase (json.len - 1, 1); // Remove trailing comma
                }
                json.append ("]"); // children
                json.append("},"); // {
                break;

            case TreeItemType.ENTRY:
                var i = (TreeEntry) item;
               
                var s = "{icon: '%s', name: '%s', desktop: '%s'},".printf(
                            Utils.get_icon_path(i.get_icon ().replace(".svg", "").replace(".png", "").replace(".xpm","")),
                            i.get_display_name (),
                            i.get_desktop_file_path ()
                        );
                json.append (s);
                break;
            }
        }
    }

    void populate () { 
        var tree = GMenu.Tree.lookup (catalog, TreeFlags.NONE);
        var root = tree.get_root_directory ();

        json.assign("[");
        update_tree (root);
        if (json.str [json.len - 1] == ',') {
            json.erase (json.len - 1, 1); // Remove trailing comma
        }
        json.append("]");
    }

    string get_json () {
        return json.str;
    }

    static void put_to_desktop (string filename) {
        var input_file = File.new_for_path (filename);
        var path = Environment.get_user_special_dir (UserDirectory.DESKTOP) + "/" + input_file.get_basename ();
        var file = File.new_for_path (path);
        if (file.query_exists ()) {
            show_dialog (_("Shortcut %s already exists in %s").printf (input_file.get_basename (), path));
            return;
        }

        DataInputStream input;
        DataOutputStream output;
        
        try {
            input = new DataInputStream (input_file.read ());
        } catch (Error e) {
            show_dialog (_("Unable to read %s: %s").printf (filename, e.message));
            return;
        }

        try {
            output = new DataOutputStream (file.create (FileCreateFlags.PRIVATE, null)); 
            var value = true;
        } catch (Error e) {
            show_dialog (_("Unable to create %s shortcut in %s: %s").printf (input_file.get_basename (), path, e.message));
            input.close ();
            return;
        }

        try {
            output.put_string ("#!/usr/bin/env xdg-open\n\n");
            string line;
            while ((line = input.read_line (null)) != null) {
                output.put_string (line + "\n");
            }
            output.close ();
            input.close ();
            GLib.FileUtils.chmod (path, 0700);
        } catch (Error e) {
            show_dialog (_("Unable to write %s shortcut in %s: %s").printf (input_file.get_basename (), path, e.message));
            input.close ();
            output.close ();
            return;
        }

    }

    public static JSCore.Object js_constructor (Context ctx,
            JSCore.Object constructor,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        var c = new Class (js_class);
        var o = new JSCore.Object (ctx, c, null);
        var s = new String.with_utf8_c_string ("update");
        var f = new JSCore.Object.function_with_callback (ctx, s, js_update);
        o.set_property (ctx, s, f, 0, null);
        s = new String.with_utf8_c_string ("updateCallback");
        f = new JSCore.Object.function_with_callback (ctx, s, js_set_update_callback);
        o.set_property (ctx, s, f, 0, null);

        if (arguments.length == 1) {
            s = arguments [0].to_string_copy (ctx, null);
            char buffer[1024];
            s.get_utf8_c_string (buffer, buffer.length);
            PanelXdgData* i = new PanelXdgData ((string) buffer);
            o.set_private (i);
            i->jsObject = o;
        }
        return o;
    }

    public static JSCore.Value js_set_update_callback (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,

            out JSCore.Value exception) {

        var i = thisObject.get_private() as PanelXdgData; 
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

        var i = thisObject.get_private() as PanelXdgData;
        if (i != null) {
            i.populate ();
            var result = i.get_json();
            var s = new String.with_utf8_c_string (result);
            return ctx.evaluate_script (s, null, null, 0, null);
        }
        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_put_to_desktop (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        if (arguments.length == 1) {
            var s = arguments [0].to_string_copy (ctx, null);
            char buffer[1024];
            s.get_utf8_c_string (buffer, buffer.length);
            put_to_desktop ((string) buffer);
        }

        return new JSCore.Value.undefined (ctx);
    }

    static const JSCore.StaticFunction[] js_funcs = {
        { "put_to_desktop", js_put_to_desktop, PropertyAttribute.ReadOnly },
        { null, null, 0 }
    };

    static const ClassDefinition js_class = {
        0,
        ClassAttribute.None,
        "XdgDataBackEnd",
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
        var s = new String.with_utf8_c_string ("XdgDataBackEnd");
        g.set_property (context, s, o, PropertyAttribute.None, null);
    }

    static void show_dialog (string message) {
        var dialog = new MessageDialog (null, DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE, "%s", message);
        dialog.response.connect (() => {
            dialog.destroy ();
        });
        dialog.show ();
    }

}
