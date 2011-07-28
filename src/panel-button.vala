using Gtk;
using Cairo;
using GMenu;

public class PanelButtonWindow : PanelAbstractWindow {

    private PanelMenuBox menu_box;
    private Image image;

    public signal void menu_shown ();

    public PanelButtonWindow() {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
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

        // Window 
        var w = new PanelWindowHost ();
        w.show();

        // Clock
        var clock = new ClockWindow ();
        clock.show ();

        // SIGNALS
        button_press_event.connect (() => {
            if (menu_box.visible) {
                // If menu_box is visible and showing first column, 
                // then we want it to be closed when we got here.

                // But refuse to close it when there's no windows around
                if (menu_box.get_active_column () == 0 
                    && w.no_windows_around ()) {
                    return false;
                }
                
                // If it's showing second column, just go back to 
                // first column
                if (menu_box.get_active_column () == 1) {
                    menu_box.slide_left ();
                    return true;
                }

                // Close it otherwise
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

        menu_box.dismissed.connect (() => {
            menu_box.hide ();
        });

        menu_box.map_event.connect (() => {
            w.dismiss ();
            return false;
        });

        w.windows_visible.connect (() => {
            if (menu_box.visible) 
                menu_box.hide ();
        });

    }


    private bool show_menu_box () {
        if (menu_box.visible == false) {
            menu_box.show_all ();
            get_window ().raise ();
            menu_box.get_window ().lower ();
            menu_shown ();
        }
        return false;
    }

}

