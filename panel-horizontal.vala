using Gtk;
using Gdk;
using Cairo;
using Indicator;

public class PanelHorizontal : PanelAbstractWindow {
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
        bar.show ();
        load_module ("libappmenu-gtk3.so", bar);
        //load_module ("libdatetime-gtk3.so", bar);


        box.show_all();

        show();
        var r = rect();
        move (r.x, r.y);

        set_struts(); 

    }

    void add_(Indicator.Object obj, Indicator.ObjectEntry entry, MenuBar menu_bar) {
            stdout.printf("adding from %s\n", name);
            if (entry == null) {
                stdout.printf("entry is null\n");
                return;
            }
            var menu_item = new MenuItem ();
            var box = new HBox (false, 3);
            var sensitive = false;
            var visible = false;

            if (entry.image != null) {
                stdout.printf("entry has image\n");
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
                stdout.printf("entry has label %s\n", entry.label.get_text());
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
            menu_item.activate.connect (() => {
               //Indicator.ObjectEntry.activate (io, entry, Gdk.CURRENT_TIME);
            });
            if (visible)
                menu_item.show ();

            if (sensitive)
                menu_item.set_sensitive (sensitive);

            item_map.set ((Indicator.ObjectEntry*) entry, menu_item);
    }

    private void load_module (string name, MenuBar menu_bar) {
        var full_path = GLib.Path.build_filename ("/usr/lib/indicators-gtk3-3/2", name);        
        var obj = new Indicator.Object.from_file (full_path);

        if (obj == null) {
            return;
        }

        obj.entry_removed.connect ((io, entry) => {
            stdout.printf("removed\n");
            MenuItem widget = (MenuItem) item_map.get (entry);
            widget.destroy ();
        });

        obj.entry_added.connect ((io, entry) => {
            add_(io, entry, menu_bar);
        });

        obj.menu_show.connect ((io, entry, timestamp) => {
            stdout.printf("show in %s\n", name);
            if (entry != null)
                return;

            foreach (unowned Indicator.ObjectEntry e in io.get_entries ()) {
               e.menu.popdown (); 
            }
            menu_bar.cancel ();
        });

        foreach (unowned Indicator.ObjectEntry entry in obj.get_entries ()) {
            stdout.printf("1adding from %s\n", name);
            add_ (obj, entry, menu_bar);
            stdout.printf("3adding from %s\n", name);
        }

    }

    public override void get_preferred_width (out int min, out int max) {
        var r = rect();
        min = max = r.width;
    }

    public override void get_preferred_height (out int min, out int max) {
        // TODO
        min = max = 27; 
    }

}
