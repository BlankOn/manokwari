using Gtk;
using Gdk;
using Cairo;
using Indicator;

public class PanelHorizontal : PanelAbstractWindow {
    private Gdk.Rectangle rect;
    private MenuBar bar;
    private Gee.HashMap <Indicator.ObjectEntry*, MenuItem> item_map;

    public PanelHorizontal () {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        var box = new HBox (false, 0);
        add (box);

        var filler = new DrawingArea ();
        filler.set_size_request(27, 27); // TODO
        box.pack_start (filler, false, false, 0);

        item_map = new Gee.HashMap <Indicator.ObjectEntry*, MenuItem> ();
        bar = new MenuBar ();
        bar.can_focus = true;
        bar.border_width = 0;

        box.pack_start (bar, true, true, 0);
        load_module ("libappmenu.so", bar);
        load_module ("libdatetime.so", bar);

        bar.show ();

        box.show_all();

        var screen = get_screen();
        screen.get_monitor_geometry (screen.get_primary_monitor(), out rect);
        move (rect.x, rect.y);

    }

    private void load_module (string name, MenuBar menu_bar) {
        var full_path = GLib.Path.build_filename ("/usr/lib/indicators/5", name);        
        var obj = new Indicator.Object.from_file (full_path);

        
        obj.entry_removed.connect ((io, entry) => {
            stdout.printf("removed\n");
            MenuItem widget = (MenuItem) item_map.get (entry);
            widget.destroy ();
        });

        obj.entry_added.connect ((io, entry) => {
            stdout.printf("added\n");
            var menu_item = new MenuItem ();
            var box = new HBox (false, 3);
            var sensitive = false;
            var visible = false;

            if (entry.image != null) {
                box.pack_start (entry.image, false, false, 1);
                entry.image.show.connect (() => {
                    stdout.printf("image show\n");
                    menu_item.show ();
                });

                entry.image.hide.connect (() => {
                    menu_item.hide ();
                });

                sensitive = entry.image.get_sensitive ();
                visible = entry.image.get_visible ();
            }
            if (entry.label != null) {
                box.pack_start (entry.label, false, false, 1);
                entry.label.show.connect (() => {
                    stdout.printf("label show\n");
                    menu_item.show ();
                });

                entry.label.hide.connect (() => {
                    menu_item.hide ();
                });


                sensitive = entry.label.get_sensitive ();
                visible = entry.label.get_visible ();
            }

            menu_item.add (box);
            box.show ();

            if (entry.menu != null) {
                menu_item.set_submenu (entry.menu);
            }
            menu_bar.append (menu_item);
            if (visible)
                menu_item.show ();

            if (sensitive)
                menu_item.set_sensitive (sensitive);

            item_map.set ((Indicator.ObjectEntry*) entry, menu_item);
        });

        obj.menu_show.connect ((io, entry, timestamp) => {
            stdout.printf("show\n");
            if (entry != null)
                return;

            foreach (unowned Indicator.ObjectEntry e in io.get_entries ()) {
               e.menu.popdown (); 
            }
            menu_bar.cancel ();
        });

        foreach (unowned Indicator.ObjectEntry entry in obj.get_entries ()) {
            obj.entry_added (entry);
        }
    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = rect.width;
    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = 27; 
    }

}
