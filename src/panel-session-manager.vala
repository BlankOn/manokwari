using Gtk;
using JSCore;

[DBus (name = "org.gnome.SessionManager")]
interface SessionManager : GLib.Object {
    public abstract void register_client (string app_id, string startup_id, out ObjectPath path) throws IOError;
    public abstract async void shutdown () throws IOError;
    public abstract async void reboot () throws IOError;

    public abstract async void logout (uint32 mode) throws IOError;
    public abstract bool can_shutdown () throws IOError;
}

[DBus (name = "org.gnome.SessionManager.ClientPrivate")]
interface ClientPrivate: GLib.Object {
    public abstract void end_session_response(bool ok, string reason) throws IOError;
    public signal void query_end_session(uint flags);
    public signal void end_session(uint flags);
}


public class PanelSessionManager {
    static ObjectPath session_id = null;
    private SessionManager session = null;
    private ClientPrivate client = null;
    static PanelSessionManager instance = null;

    public static PanelSessionManager getInstance () {
        if (instance == null) {
            instance = new PanelSessionManager ();
        }

        return instance;
    }

    private PanelSessionManager () {
        try {
            session =  Bus.get_proxy_sync (BusType.SESSION,
                                           "org.gnome.SessionManager", "/org/gnome/SessionManager");
        } catch (Error e) {
            stderr.printf ("Unable to connect to session manager\n");
        }
        if (session_id == null) {
            register();
        }
    }

    public void register () {
         if (session != null) {
            try {
                var id = GLib.Environment.get_variable("DESKTOP_AUTOSTART_ID");
                if (id != null) {
                    session.register_client ("manokwari", id, out session_id);
                    client =  Bus.get_proxy_sync (BusType.SESSION,
                                                   "org.gnome.SessionManager", session_id);
                    client.end_session.connect((flags)=> {
                        send_end_response ();
                        Gtk.main_quit();
                    });
                    client.query_end_session.connect((flags)=> {
                        send_end_response ();
                    });

                }
            } catch (Error e) {
                stderr.printf ("Unable to register session: %s\n", e.message);
            }
        }
    }

    void send_end_response () {
        if (client != null) {
            try {
                client.end_session_response(true, "");
            } catch (IOError e) {
                stderr.printf ("Unable to send data to session manager: %s\n", e.message);
            }
        }
    }

    public async void logout () {
        if (session != null) {
            try {
                session.logout (0);
            } catch (Error e) {
                stderr.printf("Unable to logout: %s\n", e.message);
            }
        }
    }

    public async void reboot () {
        if (session != null) {
            try {
                session.reboot ();
            } catch (Error e) {
                stderr.printf("Unable to reboot: %s\n", e.message);
            }
        }
    }


    public async void shutdown () {
        if (session != null) {
            try {
                session.shutdown ();
            } catch (Error e) {
                stderr.printf("Unable to shutdown: %s\n", e.message);
            }
        }
    }

    public bool can_shutdown () {
        try {
            session.can_shutdown ();
            return true;
        } catch (Error e) {
            stdout.printf ("Unable to shutdown\n");
            return false;
        }
    }

    public static JSCore.Object js_constructor (Context ctx,
            JSCore.Object constructor,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        exception = null;
        var c = new Class (js_class);
        var o = new JSCore.Object (ctx, c, null);
        var s = new String.with_utf8_c_string ("canShutdown");
        var f = new JSCore.Object.function_with_callback (ctx, s, js_can_shutdown);
        o.set_property (ctx, s, f, 0, null);

        s = new String.with_utf8_c_string ("logout");
        f = new JSCore.Object.function_with_callback (ctx, s, js_logout);
        o.set_property (ctx, s, f, 0, null);

        s = new String.with_utf8_c_string ("reboot");
        f = new JSCore.Object.function_with_callback (ctx, s, js_reboot);
        o.set_property (ctx, s, f, 0, null);

        s = new String.with_utf8_c_string ("shutdown");
        f = new JSCore.Object.function_with_callback (ctx, s, js_shutdown);
        o.set_property (ctx, s, f, 0, null);

        PanelSessionManager* i = PanelSessionManager.getInstance ();
        o.set_private (i);
        return o;
    }

    public static JSCore.Value js_can_shutdown (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,

            out JSCore.Value exception) {

        exception = null;
        var i = thisObject.get_private() as PanelSessionManager; 
        if (i != null) {
            return new JSCore.Value.boolean (ctx, i.can_shutdown()); 
        }
        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_shutdown (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,

            out JSCore.Value exception) {

        exception = null;
        var i = thisObject.get_private() as PanelSessionManager; 
        if (i != null) {
            i.shutdown(); 
        }
        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_reboot (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,

            out JSCore.Value exception) {

        exception = null;
        var i = thisObject.get_private() as PanelSessionManager; 
        if (i != null) {
            i.reboot(); 
        }
        return new JSCore.Value.undefined (ctx);
    }


    public static JSCore.Value js_logout (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,

            out JSCore.Value exception) {

        exception = null;
        var i = thisObject.get_private() as PanelSessionManager; 
        if (i != null) {
            i.logout(); 
        }
        return new JSCore.Value.undefined (ctx);
    }


    static const ClassDefinition js_class = {
        0,
        ClassAttribute.None,
        "SessionManager",
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
        var s = new String.with_utf8_c_string ("SessionManager");
        g.set_property (context, s, o, PropertyAttribute.None, null);
    }


}
