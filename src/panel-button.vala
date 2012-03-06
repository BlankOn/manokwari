using Gtk;
using Cairo;
using GMenu;

public class PanelButtonWindow : PanelAbstractWindow {

    private PanelMenuBox menu_box;
    private Image image;

    public signal void menu_shown ();

    public PanelButtonWindow() {
        set_type_hint (Gdk.WindowTypeHint.UTILITY);
        menu_box = new PanelMenuBox();
        set_visual (this.screen.get_rgba_visual ());

        set_size_request (28,28);

        Gdk.RGBA c = Gdk.RGBA();
        c.red = 0.0;
        c.blue = 0.0;
        c.green = 0.0;
        c.alpha = 0.0;
        override_background_color(StateFlags.NORMAL, c);
        set_app_paintable(true);
        
        image = new Image.from_icon_name("distributor-logo", IconSize.LARGE_TOOLBAR);
        add (image);

        show ();
        PanelScreen.move_window (this, Gdk.Gravity.NORTH_WEST);

        var hotkey = new PanelHotkey ();
        hotkey.bind ("<Alt>F1");
        hotkey.bind ("<Ctrl><Alt>l");
        hotkey.triggered.connect ((s) => {
            if (s == "<Alt>F1") {
                show_menu_box ();
                menu_box.grab_focus ();
            } else if (s == "<Ctrl><Alt>l") {
                Utils.lock_screen ();
            }
        });

        // Window 
        var w = new PanelWindowHost ();
        w.show();

        // Clock
        var clock = new ClockWindow ();
        clock.show ();

        // SIGNALS
        button_press_event.connect (() => {
            if (menu_box.visible) {
                menu_box.hide ();
            } else {
                // Otherwise we want to show it
                show_menu_box ();
            }

           return true;
        });

        screen_size_changed.connect (() =>  {
            PanelScreen.move_window (this, Gdk.Gravity.NORTH_WEST);
        });

        enter_notify_event.connect (() => {
            set_state(StateType.PRELIGHT);
            return false;
        });

        leave_notify_event.connect (() => {
            set_state(StateType.NORMAL);
            return false;
        });

        w.windows_visible.connect (() => {
            if (menu_box.visible) {
                menu_box.try_hide ();
            }
        });

        w.activated.connect (() => {
            get_window ().raise ();
        });
        
        map_event.connect (() => {
            set_keep_above(true);
            return true;
        });

        menu_box.shown.connect (() => {
            hide ();
        });

        menu_box.dismissed.connect (() => {
            show ();
        });
    }


    private bool show_menu_box () {
        if (menu_box.visible == false) {
            menu_box.show ();
            menu_shown ();
        }
        return false;
    }

}

