using Gtk;

[DBus (name = "org.gnome.SessionManager.EndSessionDialog")]
public class PanelEndSessionDialog: Object {
    public signal void canceled();
    public signal void confirmed_logout();
    public signal void confirmed_reboot();
    public signal void confirmed_shutdown();
    public signal void closed();
    
    private Label label = null;
    private int countdown = 10;
    private uint update_title_source = -1;
    private string current_title;
    private uint default_action = 0;
    private Dialog dialog = null;
    private bool action_called = false;

    public PanelEndSessionDialog() {
        label = new Label(null);
        label.justify = Gtk.Justification.CENTER;
    }

    void start_update_title (string title)  {
        countdown = 10;
        current_title = title;
        update_title();
        update_title_source = GLib.Timeout.add_seconds(1, update_title); 
    }

    bool update_title() {
        label.set_markup("<span font-weight='heavy' font_size='xx-large'>%d</span>\n".printf(countdown) + current_title);
        if (countdown <= 0) {
            countdown = 0;
            launch_action(default_action);
            if (dialog != null) {
                dialog.destroy();
            }
            return false;
        }
        countdown = countdown - 1;
        return true;
    }

    void show_dialog (uint type, string title, string button_text) {
        default_action = type;
        var d = new Dialog.with_buttons(_("Confirmation"), null, Gtk.DialogFlags.MODAL, null);
        d.get_style_context().add_class("manokwari-fullscreen-dialog");
        dialog = d;
        d.fullscreen();
        if (update_title_source >= 0) {
            GLib.Source.remove(update_title_source);
            update_title_source = -1;
        }
        var cancel_title = _("\nYou can prevent it by pressing <b>Cancel</b> button");
        start_update_title(title + cancel_title);
        (d.get_content_area() as Gtk.Box).pack_start(label, true, true);
        label.show();
        d.add_button(button_text, 1);
        d.add_button(_("Cancel"), 2);
        d.set_default_response(2);
        d.response.connect((id) => {
            GLib.Source.remove(update_title_source);
            update_title_source = -1;
            if (id == -4 || id == 2) { // closed or canceled
                canceled();
                if (id == 2) {
                  d.destroy();
                }
            } else {
                launch_action(type);
                d.destroy();
            }
        });
        d.key_press_event.connect ((e) => {
            if (Gdk.keyval_name(e.keyval) == "Escape") {
                canceled();
                d.destroy();
            }
            return false;
        });
 
        d.run();
    }

    void launch_action(uint type) {
        if (action_called == true) {
            return;
        }
        action_called = true;
        switch (type) {
          case 3:
          case 2:
            confirmed_reboot();
            break;
          case 1:
            confirmed_shutdown();
            break;
          case 0:
          default:
            confirmed_logout();
            break;
        }
    }

    public async void open (uint type, uint timestamp, uint waiting_time, ObjectPath[] inhibitors) {
        var title = "";
        var button_text = "";
        switch(type) {
          case 1: // shutdown
              button_text = _("Shutdown Now");
              title = _("This computer will go to a shutdown.");
              break;
          case 2: // restart
              button_text = _("Restart Now");
              title = _("This computer will be restarted.");
              break;
          case 3: // restart and install
              button_text = _("Restart Now");
              title = _("This computer will be restarted.");
              break;
          case 0: // logout
          default: // fallthrough
              button_text = _("Logout Now");
              title = _("Your account will be logged-out.");
              break;
        }
        show_dialog(type, title, button_text);
    }

    public void close () {
    }
}

public class PanelShell : Object {
    public PanelShell() {
        Bus.own_name(
            BusType.SESSION,
            "org.gnome.Shell",
            0,
            () => {},
            on_name_acquired,
            () => {
              stdout.printf ("Unable to claim Shell from gnome-session");
            }
        );
    }

    void on_name_acquired(DBusConnection conn, string name) {
        try {
            conn.register_object("/org/gnome/SessionManager/EndSessionDialog", new PanelEndSessionDialog());
            stderr.printf("EndSessionDialog hooked\n");
        } catch (IOError e) {
            stderr.printf("Unable to hook EndSessionDialog\n");
        }
    }

}
