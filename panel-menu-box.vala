using Gtk;

public class PanelMenuBox : PanelAbstractWindow {
    private Gdk.Rectangle rect;
    private VBox box;

    public PanelMenuBox () {
        var screen = get_screen();
        screen.get_monitor_geometry (screen.get_primary_monitor(), out rect);
        move (rect.x, rect.y);
        box = new VBox (false, 0);
        add (box);
    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = 300; 
    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = rect.height; 
    }

    public override bool map_event (Gdk.Event event) {
        var device = get_current_event_device();

        if (device == null) {
            var display = get_display ();
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


        var status = keyboard.grab(get_window(), Gdk.GrabOwnership.WINDOW, true, Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK, null, Gdk.CURRENT_TIME);
        status = pointer.grab(get_window(), Gdk.GrabOwnership.WINDOW, true, Gdk.EventMask.BUTTON_PRESS_MASK, null, Gdk.CURRENT_TIME);
        return true;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        var device = get_current_event_device();
        var secondary = device.get_associated_device();
        device.ungrab(Gdk.CURRENT_TIME);
        secondary.ungrab(Gdk.CURRENT_TIME);
        hide();
        return false;
    }

}
