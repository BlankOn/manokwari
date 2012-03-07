using GMenu;
using Gee;
using Gtk;
using GLib;
using JSCore;

public class Favorites {
    StringBuilder json; // use StringBuilder to avoid appending immutable strings
    static Context* jsContext;
    JSCore.Object* jsObject;

    public signal void changed ();
   
    public Favorites () {
        json = new StringBuilder ();
        monitor ();
        populate ();

        changed.connect (() => {
            json.assign ("");
            populate ();

            if (jsContext != null && jsObject != null) {

                var s = new String.with_utf8_c_string ("updateCallback");
                var v = jsObject->get_property (jsContext, s, null);
                if (v != null) {
                    s = v.to_string_copy (jsContext, null);
                    jsContext->evaluate_script (s, null, null, 0, null);
                }
            }
        });

    }

    private void populate () {
        var list = get_list ();

        json.append("[");
        json.append("{name: '%s', isHeader: true},".printf(
                _("Favorites")
            ));
        foreach (string item in list) {
            if (item.get_char (0) == '-') // Don't display blacklisted entries
                continue;

            var info = new DesktopAppInfo.from_filename (item);
            var s = "{icon: '%s', name: '%s', desktop: '%s'},".printf(
                        Utils.get_icon_path(info.get_icon ().to_string().replace(".svg", "").replace(".png", "").replace(".xpm","")),
                        info.get_display_name (),
                        item
                    );

            json.append (s);
        }
        if (json.str [json.len - 1] == ',') {
            json.erase (json.len - 1, 1); // Remove trailing comma
        }
        json.append("]");
    }

    string get_json () {
        return json.str;
    }

    private static File get_custom_favorites_file () {
        return File.new_for_path (Environment.get_home_dir () + "/.config/blankon-panel/favorites");
    }

    public void monitor () {
        var custom_file = get_custom_favorites_file ();
        try {
            var monitor = custom_file.monitor (FileMonitorFlags.NONE, null);
            monitor.changed.connect (() => {
                changed ();
            });
        } catch (Error e) {
            stdout.printf ("Can't monitor custom favorite file: %s\n", e.message);
        }
    }

    public static void remove (string file) {
        var list = get_list ();

        int i = 0;
        bool duplicate = false;
        int remove_index = -1;
        foreach (var entry in list) {
            if (entry == "-" + file)
                duplicate = true;
            if ("-" + entry == file) {
                remove_index = i;
            }
            if (entry == file) {
                remove_index = i;
            }

            i ++;
        }
        if (remove_index != -1)
            list.remove_at (remove_index);
        if (! duplicate)
            list.add ("-" + file);
        write (list);

    }

    public static void add (string file) {
        var list = get_list ();

        int i = 0;
        bool duplicate = false;
        int remove_index = -1;
        foreach (var entry in list) {
            if (entry == file)
                duplicate = true;
            if (entry == "-" + file) {
                remove_index = i;
            }
            i ++;
        }
        if (remove_index != -1)
            list.remove_at (remove_index);
        if (! duplicate)
            list.add (file);
        write (list);
    }

    public static void write (Gee.ArrayList<string> list) {
        var custom_file = get_custom_favorites_file ();
        bool ok = false;
        DataOutputStream output = null;
        if (!custom_file.query_exists ()) {
            var dir_name = custom_file.get_path ().substring (0, custom_file.get_path ().last_index_of("/"));
            var dir = File.new_for_path (dir_name);
            if (!dir.query_exists ()) {
                try {
                    dir.make_directory_with_parents (null);
                    ok = true;
                } catch (Error e) {
                    stdout.printf ("Unable to create config directory for storing favorites: %s\n", e.message);
                }
            }
            if (ok) {
                try {
                    output = new DataOutputStream (custom_file.create (FileCreateFlags.PRIVATE, null));
                } catch (Error e) {
                    stdout.printf ("Unable to create favorites file: %s\n", e.message);
                    ok = false;
                }
            }
        } else {
            try {
                output = new DataOutputStream (custom_file.replace (null, false, FileCreateFlags.PRIVATE, null));
                ok = true;
            } catch (Error e) {
                stdout.printf ("Unable to append favorites file: %s\n", e.message);
            }
        }
        if (ok && output != null) {
            try {
                foreach (string entry in list) {
                    output.put_string (entry + "\n");
                }
                output.close ();
            } catch (Error e) {
                stdout.printf ("Unable to write to favorites file: %s\n", e.message);
            }
        }
    }

    public static Gee.ArrayList<string> get_blacklist () {
        var list = get_list ();
        var new_list = new Gee.ArrayList <string> (); 
        foreach (string entry in list) {
            if (entry.get_char (0) == '-') {
                new_list.add (entry.substring (1));
            }
        }
        return new_list;
    }

    public static Gee.ArrayList<string> get_list () {
        var list = new Gee.ArrayList <string> ();

        var custom_file = get_custom_favorites_file ();
        if (custom_file.query_exists ()) {
            try {
                var input = new DataInputStream (custom_file.read ());
                string line;

                while ((line = input.read_line (null)) != null) {
                    if (line.last_index_of (".desktop") == (line.length - 8)) {
                        list.add (line);
                    }
                }
                input.close ();
            } catch (Error e) {
                stdout.printf ("Unable to read the custom bookmark to produce blacklist\n");
            }
        }

        var tree = GMenu.Tree.lookup ("favorites.menu", TreeFlags.NONE);
        var root = tree.get_root_directory ();

        foreach (TreeItem item in root.get_contents ()) {
            if (item.get_type() ==  TreeItemType.ENTRY) {
                var i = (TreeDirectory) item;
                if (list.index_of ("-" + i.get_desktop_file_path ()) < 0 &&
                    list.index_of (i.get_desktop_file_path ()) < 0) {
                    list.add (i.get_desktop_file_path ());
                }
            }
        }
        return list;
    }

    public static JSCore.Object js_constructor (Context ctx,
            JSCore.Object constructor,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        var c = new Class (js_class);
        var o = new JSCore.Object (ctx, c, null);
        var s = new String.with_utf8_c_string ("updateCallback");
        var f = new JSCore.Object.function_with_callback (ctx, s, js_set_update_callback);
        o.set_property (ctx, s, f, 0, null);


        s = new String.with_utf8_c_string ("update");
        f = new JSCore.Object.function_with_callback (ctx, s, js_update);
        o.set_property (ctx, s, f, 0, null);
        
        Favorites* i = new Favorites ();
        o.set_private (i);
        i->jsObject = o;
        return o;
    }

    public static JSCore.Value js_set_update_callback (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,

            out JSCore.Value exception) {

        var i = thisObject.get_private() as Favorites; 
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

        var i = thisObject.get_private() as Favorites; 
        if (i != null) {
            var result = i.get_json();
            var s = new String.with_utf8_c_string (result);
            return ctx.evaluate_script (s, null, null, 0, null);
        }
        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_add (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        if (arguments.length == 1) {
            var s = arguments [0].to_string_copy (ctx, null);
            char buffer[1024];
            s.get_utf8_c_string (buffer, buffer.length);
            add ((string) buffer);
        }

        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_remove (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        if (arguments.length == 1) {
            var s = arguments [0].to_string_copy (ctx, null);
            char buffer[1024];
            s.get_utf8_c_string (buffer, buffer.length);
            remove ((string) buffer);
        }

        return new JSCore.Value.undefined (ctx);
    }

    static const JSCore.StaticFunction[] js_funcs = {
        { "add", js_add, PropertyAttribute.ReadOnly },
        { "remove", js_remove, PropertyAttribute.ReadOnly },
        { null, null, 0 }
    };


    static const ClassDefinition js_class = {
        0,
        ClassAttribute.None,
        "Favorites",
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
        var s = new String.with_utf8_c_string ("Favorites");
        g.set_property (context, s, o, PropertyAttribute.None, null);
    }


}



