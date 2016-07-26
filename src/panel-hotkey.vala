using Gtk;
using Gdk;
using Gee;

// Based on http://code.valaide.org/content/global-hotkeys by Oliver Sauder <os@esite.ch>

public static void static_handler (string a) {
    PanelHotkey.instance().triggered (a);
}

public class PanelHotkey {
    public signal void triggered (string combination);
    private unowned X.Display display;
    private Gdk.Window root_window;
    private X.ID x_id;

    private class KeyBinding {
        public string combination;
        public uint key_code;
        public uint modifiers;

        public KeyBinding (string combination, uint key_code, uint modifiers) {
            this.combination = combination;
            this.key_code = key_code;
            this.modifiers = modifiers;
        }
    }

    static PanelHotkey _instance;

    public static PanelHotkey instance () {
        return _instance;
    }

    private static uint[] lock_modifiers = {
        0,
        Gdk.ModifierType.MOD2_MASK, // NUM_LOCK
        Gdk.ModifierType.LOCK_MASK, // CAPS_LOCK
        Gdk.ModifierType.MOD5_MASK, // SCROLL_LOCK
        Gdk.ModifierType.MOD2_MASK|Gdk.ModifierType.LOCK_MASK,
        Gdk.ModifierType.MOD2_MASK|Gdk.ModifierType.MOD5_MASK,
        Gdk.ModifierType.LOCK_MASK|Gdk.ModifierType.MOD5_MASK,
        Gdk.ModifierType.MOD2_MASK|Gdk.ModifierType.LOCK_MASK|Gdk.ModifierType.MOD5_MASK
    };

    private static Gee.List<KeyBinding> bindings;

    public PanelHotkey () {
        _instance = this;
        bindings = new Gee.ArrayList<KeyBinding> ();
        root_window = get_default_root_window ();
        display = x11_get_default_xdisplay ();
        x_id = X11Window.get_xid (root_window); 
        root_window.add_filter (event_filter);
    }

    public Gdk.FilterReturn event_filter (Gdk.XEvent gxevent, Gdk.Event event) {

        FilterReturn filter = FilterReturn.CONTINUE;

        X.Event* xevent = (X.Event*) gxevent;

        stderr.printf("ev\n");
        if (xevent->type == X.EventType.KeyPress) {
        stderr.printf("keypress\n");
            foreach (var binding in bindings) {
stderr.printf("modifier ---------- %d %d %d\n", (int) binding.key_code, (int) binding.modifiers, (int) xevent->xkey.state);
                if (xevent->xkey.keycode == binding.key_code &&
                    (xevent->xkey.state &~ (lock_modifiers[7])) == binding.modifiers) {
                    static_handler (binding.combination); 
                }
            }
        }
        return filter;
    }

    public void bind (string combination) {
        uint key_sym;
        ModifierType modifiers;
        accelerator_parse (combination, out key_sym, out modifiers);

        var key_code = display.keysym_to_keycode (key_sym);
stderr.printf("modifier ---------- %d %d\n", (int) key_code, (int) modifiers);
        if (key_code != 0) {
            error_trap_push ();
            foreach(uint lock_modifier in lock_modifiers) {    
              display.grab_key (key_code, lock_modifier | modifiers, x_id, false, X.GrabMode.Async, X.GrabMode.Async);
            }
            flush();
            var binding = new KeyBinding (combination, key_code, modifiers);
            bindings.add (binding);
        }
    }
}
