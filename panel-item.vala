using Gtk;

public class PanelItem : ImageMenuItem {
    private DesktopAppInfo info;

    public PanelItem () {
        add_events (Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK
            | Gdk.EventMask.KEY_PRESS_MASK
            | Gdk.EventMask.KEY_RELEASE_MASK
            | Gdk.EventMask.POINTER_MOTION_MASK);

        setup_connections ();
        info = null;
    }

    public PanelItem.with_label (string title) {
        set_label (title);
        setup_connections ();
        info = null;
    }

    public void load_app_info (string filename) {
        info = new DesktopAppInfo.from_filename (filename);
    }

    private void setup_connections () {

        enter_notify_event.connect ((event) => {
            if (parent != null) {
                var e = Gdk.EventButton ();
                e.type = Gdk.EventType.BUTTON_PRESS;
                e.x = 0;
                e.y = 0;
                e.window = event.window;
                e.button = 1;
                parent.button_press_event (e);
                e.type = Gdk.EventType.BUTTON_RELEASE;
                parent.button_release_event (e);
            }

            return true;
        });

        /*
       
        leave_notify_event.connect (() => {
            deselect ();
            return true;
        });

        enter_notify_event.connect (() => {
            //select ();
            return false;
        });

        activate.connect (() => {
            if (info != null) {
                info.launch (null, new AppLaunchContext ());
            }
        });*/
    }
}
