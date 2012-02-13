using GMenu;
using GLib;
using JSCore;
using Gtk;

// This class opens an xdg menu and populates it
public class PanelXdgData {

    string catalog;
    StringBuilder json; // use StringBuilder to avoid appending immutable strings
    IconTheme icon;

    public PanelXdgData (string catalog) {
        json = new StringBuilder ();
        this.catalog = catalog;
        icon = IconTheme.get_default ();
    }

    void update_tree (TreeDirectory root) {
        foreach (TreeItem item in root.get_contents ()) {
            switch (item.get_type()) {
            case TreeItemType.DIRECTORY:
                var i = (TreeDirectory) item;

                var s = "{icon: '%s', name: '%s',".printf(
                            get_icon_path(i.get_icon ().replace(".svg", "").replace(".png", "").replace(".xpm","")),
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
                            get_icon_path(i.get_icon ().replace(".svg", "").replace(".png", "").replace(".xpm","")),
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

        json.append("[");
        update_tree (root);
        if (json.str [json.len - 1] == ',') {
            json.erase (json.len - 1, 1); // Remove trailing comma
        }
        json.append("]");
        stdout.printf("%s\n", get_json());
    }

    string get_json () {
        return json.str;
    }

    string get_icon_path (string name) {
        var i = icon.lookup_icon (name, 24, IconLookupFlags.GENERIC_FALLBACK);
        return i.get_filename();
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

        if (arguments.length == 1) {
            s = arguments [0].to_string_copy (ctx, null);
            char buffer[1024];
            s.get_utf8_c_string (buffer, buffer.length);
            PanelXdgData* i = new PanelXdgData ((string) buffer);
            o.set_private (i);
        }
        return o;
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


    static const ClassDefinition js_class = {
        0,
        ClassAttribute.None,
        "XdgDataBackEnd",
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
        var c = new Class (js_class);
        var o = new JSCore.Object (context, c, context);
        var g = context.get_global_object ();
        var s = new String.with_utf8_c_string ("XdgDataBackEnd");
        g.set_property (context, s, o, PropertyAttribute.None, null);
    }

}
