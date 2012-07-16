using Gtk;
using JSCore;

[DBus (name = "org.freedesktop.Accounts")]
interface XdgAccounts: GLib.Object {
    public abstract void find_user_by_name (string user, out ObjectPath path) throws IOError;
}

[DBus (name = "org.freedesktop.Accounts.User")]
interface XdgAccountsUser: GLib.Object {
    public abstract string user_name { 
        owned get;
    }
    public abstract string real_name {
        owned get;
    }
    public abstract string icon_file {
        owned get;
    }
}

public class PanelUser {
    XdgAccountsUser user = null;
    ObjectPath user_path = null;

    public string icon_file {
        owned get {
            if (user == null || 
                user.icon_file == null ||
                user.icon_file == "") {
                return Utils.get_icon_path("avatar-default");
            }
            var f = File.new_for_path(user.icon_file);
            if (f.query_exists()) {
                return user.icon_file;
            } else {
                return Utils.get_icon_path("avatar-default");
            }
        }
    }

    public string real_name {
        owned get {
            if (user == null || user.real_name == null || user.real_name == "") {
                return GLib.Environment.get_user_name ();
            }
            return user.real_name;
        }
    }

    public string host_name {
        owned get {
            return GLib.Environment.get_host_name ();
        }
    }

    public PanelUser () {
        XdgAccounts session = null;
        try {
            session =  Bus.get_proxy_sync (BusType.SYSTEM,
                                           "org.freedesktop.Accounts", "/org/freedesktop/Accounts");
            if (session != null) {

                session.find_user_by_name (GLib.Environment.get_user_name (), out user_path);
                update();
            }
        } catch (Error e) {
            stderr.printf ("Unable to connect to account manager: " + e.message + "\n");
        }
    }

    void update() {
        if (user_path == null) {
            return;
        }
        try {
            user =  Bus.get_proxy_sync (BusType.SYSTEM,
                                           "org.freedesktop.Accounts", user_path);
        } catch (Error e) {
            stderr.printf ("Unable to connect to user account manager: %s\n", e.message);
        }
    }

    public static JSCore.Object js_constructor (Context ctx,
            JSCore.Object constructor,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        exception = null;
        var c = new Class (js_class);
        var o = new JSCore.Object (ctx, c, null);
        PanelUser* i = new PanelUser ();
        var s = new String.with_utf8_c_string ("getRealName");
        var f = new JSCore.Object.function_with_callback (ctx, s, js_get_real_name);
        o.set_property (ctx, s, f, 0, null);
 
        s = new String.with_utf8_c_string ("getHostName");
        f = new JSCore.Object.function_with_callback (ctx, s, js_get_host_name);
        o.set_property (ctx, s, f, 0, null);

        s = new String.with_utf8_c_string ("getIconFile");
        f = new JSCore.Object.function_with_callback (ctx, s, js_get_icon_file);
        o.set_property (ctx, s, f, 0, null);

        o.set_private (i);
        return o;
    }

    public static JSCore.Value js_get_real_name (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,

            out JSCore.Value exception) {

        exception = null;
        var i = thisObject.get_private() as PanelUser;
        if (i != null) {
            i.update ();
            var s = new String.with_utf8_c_string (i.real_name);
            return new JSCore.Value.string (ctx, s);
        }
        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_get_host_name (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,

            out JSCore.Value exception) {

        exception = null;
        var i = thisObject.get_private() as PanelUser;
        if (i != null) {
            var s = new String.with_utf8_c_string (GLib.Environment.get_host_name ());
            return new JSCore.Value.string (ctx, s);
        }
        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_get_icon_file (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,

            out JSCore.Value exception) {

        exception = null;
        var i = thisObject.get_private() as PanelUser;
        if (i != null) {
            i.update ();
            var s = new String.with_utf8_c_string (i.icon_file);
            return new JSCore.Value.string (ctx, s);
        }
        return new JSCore.Value.undefined (ctx);
    }

    static const ClassDefinition js_class = {
        0,
        ClassAttribute.None,
        "UserAccount",
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
        var s = new String.with_utf8_c_string ("UserAccount");
        g.set_property (context, s, o, PropertyAttribute.None, null);
    }

}
