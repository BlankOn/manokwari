using JSCore;
using Gtk;

namespace Utils {
    public bool launch_search () {
        try {
            GLib.Process.spawn_command_line_async ("synapse");
            return true;
        } catch (Error e) {
            return false;
        }
    }

    public bool launch_profile () {
        try {
            GLib.Process.spawn_command_line_async ("gnome-about-me");
            return true;
        } catch (Error e) {
            return false;
        }
    }

    public bool lock_screen () {
        try {
            GLib.Process.spawn_command_line_async ("gnome-screensaver-command -l");
            return true;
        } catch (Error e) {
            return false;
        }
    }

    public bool print_screen () {
        try {
            GLib.Process.spawn_command_line_async ("gnome-screenshot -i");
            return true;
        } catch (Error e) {
            stderr.printf("Error running print_screen %s\n", e.message);
            return false;
        }
    }

    public void grab (Gtk.Window w) {
        var device = Gtk.get_current_event_device();

        if (device == null) {
            var display = w.get_display ();
            var manager = display.get_device_manager ();
            var devices = manager.list_devices (Gdk.DeviceType.MASTER).copy();
            device = devices.data;
        }
        var keyboard = device;
        var pointer = device;

        if (device.get_source() == Gdk.InputSource.KEYBOARD) {
            pointer = device.get_associated_device ();
        } else {
            keyboard = device.get_associated_device ();
        }

        var status = keyboard.grab(w.get_window(), Gdk.GrabOwnership.WINDOW, true, Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK, null, Gdk.CURRENT_TIME);
        status = pointer.grab(w.get_window(), Gdk.GrabOwnership.WINDOW, true, Gdk.EventMask.BUTTON_PRESS_MASK, null, Gdk.CURRENT_TIME);
    }

    public void ungrab (Gtk.Window w) {
        var device = Gtk.get_current_event_device();
        var secondary = device.get_associated_device();
        device.ungrab(Gdk.CURRENT_TIME);
        secondary.ungrab(Gdk.CURRENT_TIME);
    }


    public static JSCore.Value js_run_desktop (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        exception = null;
        if (arguments.length > 0) {
            bool from_desktop = false;
            // Optional argument takes a boolean value
            // to indicate whether this should be taken
            // from user's desktop directory
            if (arguments.length > 1) {
                var _from_desktop = arguments [1].to_boolean (ctx);
                from_desktop = _from_desktop;
            }

            var s = arguments [0].to_string_copy (ctx, null);
            char[] buffer = new char[s.get_length() + 1];
            s.get_utf8_c_string (buffer, buffer.length);
            string path = null;

            // Check whether the desktop has an absolute path or not
            if (buffer [0] != '/') {
                // If not, append the correct path
                if (from_desktop) {
                    path = Environment.get_user_special_dir (UserDirectory.DESKTOP) + "/" + (string) buffer;
                } else {
                    path = "/usr/share/applications/" + (string) buffer;
                }
            } else {
                // Otherwise take it as is
                path = (string) buffer;
            }
            var info = new DesktopAppInfo.from_filename (path);
            try {
                info.launch (null, Gdk.Display.get_default ().get_app_launch_context ());
            } catch (Error e) {
                var dialog = new MessageDialog (null, DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE, _("Error opening menu item %s: %s"), info.get_display_name (), e.message);
                dialog.response.connect (() => {
                            dialog.destroy ();
                        });
                dialog.show ();
            }
        }

        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_open_uri (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        exception = null;
        if (arguments.length == 1) {
            var s = arguments [0].to_string_copy (ctx, null);
            char buffer[1024];
            s.get_utf8_c_string (buffer, buffer.length);
            try {
                show_uri (Gdk.Screen.get_default (), (string) buffer, get_current_event_time());
            } catch (Error e) {
                var dialog = new MessageDialog (null, DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE, _("Error opening menu item '%s': %s"), (string) buffer, e.message);
                dialog.response.connect (() => {
                            dialog.destroy ();
                        });
                dialog.show ();
            }
        }

        return new JSCore.Value.undefined (ctx);
    }


    public static JSCore.Value js_run_command (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        exception = null;
        if (arguments.length == 1) {
            var s = arguments [0].to_string_copy (ctx, null);
            char buffer[1024];
            s.get_utf8_c_string (buffer, buffer.length);
            try {
                var app = AppInfo.create_from_commandline ((string) buffer, (string) buffer, AppInfoCreateFlags.NONE);
                app.launch (null, null);
            } catch (Error e) {
                var dialog = new MessageDialog (null, DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE, _("Error running command '%s': %s"), (string) buffer, e.message);
                dialog.response.connect (() => {
                            dialog.destroy ();
                        });
                dialog.show ();
            }
        }

        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_translate (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        exception = null;
        if (arguments.length == 1) {
            var s = arguments [0].to_string_copy (ctx, null);
            char[] buffer = new char[s.get_length() + 1];
            s.get_utf8_c_string (buffer, buffer.length);

            s = new String.with_utf8_c_string (_((string) buffer));
            var result = new JSCore.Value.string (ctx, s);
            s = null;
            buffer = null;
            return result;
        }

        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_get_icon_path (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        exception = null;
        if (arguments.length > 0) {
            var s = arguments [0].to_string_copy (ctx, null);
            char[] buffer = new char[s.get_length() + 1];
            s.get_utf8_c_string (buffer, buffer.length);

            int size = 24;
            if (arguments.length > 1) {
                var size_d = arguments [1].to_number (ctx, null);
                size = (int) size_d;            
            }

            s = new String.with_utf8_c_string (get_icon_path((string) buffer, size));
            var result = new JSCore.Value.string (ctx, s);
            s = null;
            buffer = null;
            return result;
        }

        return new JSCore.Value.undefined (ctx);
    }

    public static JSCore.Value js_get_time (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        exception = null;
		char bufferClock[100];
		Time t = Time.local (time_t ());
		t.strftime (bufferClock, _("%H:%M"));

        var s = new String.with_utf8_c_string (_((string) bufferClock));
        var result = new JSCore.Value.string (ctx, s);
        s = null;
        return result;
    }

    public static JSCore.Value js_get_date (Context ctx,
            JSCore.Object function,
            JSCore.Object thisObject,
            JSCore.Value[] arguments,
            out JSCore.Value exception) {

        exception = null;
		char bufferClock[100];
		Time t = Time.local (time_t ());
		t.strftime (bufferClock, _("%A, %B %e %Y"));

        var s = new String.with_utf8_c_string (_((string) bufferClock));
        var result = new JSCore.Value.string (ctx, s);
        s = null;
        return result;
    }

    static const JSCore.StaticFunction[] js_funcs = {
        { "run_desktop", js_run_desktop, PropertyAttribute.ReadOnly },
        { "open_uri", js_open_uri, PropertyAttribute.ReadOnly },
        { "run_command", js_run_command, PropertyAttribute.ReadOnly },
        { "translate", js_translate, PropertyAttribute.ReadOnly },
        { "getIconPath", js_get_icon_path, PropertyAttribute.ReadOnly },
        { "getTime", js_get_time, PropertyAttribute.ReadOnly },
        { "getDate", js_get_date, PropertyAttribute.ReadOnly },
        { null, null, 0 }
    };


    static const ClassDefinition js_class = {
        0,
        ClassAttribute.None,
        "Utils",
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
        null,
        null,
        null
    };

    public static void setup_js_class (GlobalContext context) {
        var c = new Class (js_class);
        var o = new JSCore.Object (context, c, context);
        var g = context.get_global_object ();
        var s = new String.with_utf8_c_string ("Utils");
        g.set_property (context, s, o, PropertyAttribute.None, null);
    }

    public static string get_icon_path (string name, int size=24) {
        var icon = IconTheme.get_default ();
        var i = icon.lookup_icon (name, size, IconLookupFlags.GENERIC_FALLBACK);
        if (i != null) {
            return i.get_filename();
        } else {
            return name;
        }
    }


}
