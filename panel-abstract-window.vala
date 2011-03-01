using Gtk;

public class PanelAbstractWindow : Window {
    public PanelAbstractWindow () {
        add_events (Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.POINTER_MOTION_MASK);

        skip_taskbar_hint = true;
        set_decorated (false);
        set_resizable (false);
        set_focus_on_map (true);
        set_accept_focus (true);
        stick ();
     
    }

}
