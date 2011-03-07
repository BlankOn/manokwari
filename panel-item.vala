using Gtk;

public class PanelItem : ImageMenuItem {
    private DesktopAppInfo info;

    public PanelItem () {
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
