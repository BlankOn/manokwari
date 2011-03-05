using Gtk;

public class PanelItem : ImageMenuItem {

    public PanelItem () {
        setup_connections ();
    }

    public PanelItem.with_label (string title) {
        set_label (title);
        setup_connections ();
    }

    private void setup_connections () {
        leave_notify_event.connect (() => {
            deselect ();
            return true;
        });

        enter_notify_event.connect (() => {
            select ();
            return true;
        });
    }
}
