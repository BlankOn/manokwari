using Gtk;

public class PanelAnimatedAdjustment : Adjustment {
    private double direction = 1; 
    private double target = 0;
    private double target_delta = 0;
    private double interpolated = 0;
    private double duration = 500;
    private double time = 0;
    private double start_value = 0;

    public PanelAnimatedAdjustment (double value, double lower, double upper, double step_increment, double page_increment, double page_size) {
        set_value (value);
        set_lower (lower);
        set_upper (upper);
        set_step_increment (step_increment);
        set_page_increment (page_increment);
        set_page_size (page_size);
    }

    public void set_duration (int duration) {
        this.duration = (double) duration;
    }

    public void set_target (double target) {
        this.target = target;
    }

    public void start () {
        time = 0;
        start_value = get_value ();    
        if (target > start_value)
            direction = 1; 
        else
            direction = -1; 

        int delta = (int) (target - get_value());
        target_delta = (double) delta.abs (); 
        GLib.Timeout.add (16, tween);
    }

/*
Easing function by Robert Penner:

Copyright © 2001 Robert Penner
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

    public double ease (double t, double b, double c, double d) {
        if ((t/=d/2) < 1) return c/2*t*t*t + b;
        return c/2*((t-=2)*t*t + 2) + b;
    }

    private bool tween () {
        // LINEAR
        //interpolated = start_value + direction * (target_delta * time / duration);

        interpolated = ease(time, start_value, direction * target_delta, duration);

        if ((interpolated > target && direction == 1)
          ||(interpolated < target && direction == -1)
           ) {
           interpolated = target;
           set_value (interpolated);
           return false;
        }

        if (time > duration) {
            time = 0;
            return false;
        }
        time += 16;
        set_value (interpolated);
        return true;
    }
}

public class PanelMenuBox : PanelAbstractWindow {
    private int filler_height = 27;
    private int active_column = 0;
    private HBox columns;

    public signal void dismissed ();
    public signal void cancelled ();

    private PanelAnimatedAdjustment adjustment;

    public int get_active_column () {
        return active_column;
    }

    private int get_column_width () {
        foreach (unowned Widget w in columns.get_children ()) {
            return w.get_allocated_width ();
        }
        return 0;
    }

    public void slide_left () {
        adjustment.set_target (0);
        adjustment.start ();
        active_column = 0;
    }

    public void slide_right () {
        adjustment.set_target (get_column_width ());
        adjustment.start ();
        active_column = 1;
    }


    public PanelMenuBox () {
        set_type_hint (Gdk.WindowTypeHint.DOCK);
        move (rect ().x, rect ().y);

        adjustment = new PanelAnimatedAdjustment (0, 0, rect ().width, 5, 0, 0);

        // Create outer scrollable
        var panel_viewport = new Viewport (adjustment, null);
        var panel_area = new ScrolledWindow (adjustment, null);
        panel_area.set_policy (PolicyType.NEVER, PolicyType.NEVER);

        // Add to window
        add (panel_area);

        // Create the columns
        columns = new HBox (true, 0);
        panel_viewport.add (columns);

        panel_area.add (panel_viewport);

        var filler1 = new DrawingArea ();
        filler1.set_size_request (250, 20);

        // Quick Launch (1st) column
        var quick_launch_box = new VBox (false, 0);
        columns.pack_start (quick_launch_box);

        var quick_launch_bar = new VBox (false, 0);
        quick_launch_box.pack_start (filler1, false, false, 20);
        quick_launch_box.pack_start (quick_launch_bar, false, false, 0);
        var favorites = new PanelMenuContent (quick_launch_bar, "favorites.menu");
        favorites.populate ();
        favorites.insert_separator ();

        favorites.menu_clicked.connect (() => {
            dismiss ();
        });

        var all_apps_opener = new PanelItem.with_label ("All applications");
        all_apps_opener.set_image ("");
        all_apps_opener.activate.connect (() => {
            slide_right (); 
        });
        quick_launch_bar.pack_start (all_apps_opener, false, false, 0);

        // All application (2nd) column
        var all_apps_viewport = new Viewport (null, null);
        var all_apps_area = new ScrolledWindow (null, null);
        all_apps_area.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
        var all_apps_box = new VBox (false, 0);
        columns.pack_start (all_apps_box);

        all_apps_area.add (all_apps_viewport);

        var filler2 = new DrawingArea ();
        all_apps_box.pack_start (filler2, false, false, 20);
        all_apps_box.pack_start (all_apps_area, false, false, 0);

        var all_apps_bar = new VBox (false, 0);
        all_apps_viewport.add (all_apps_bar);

        var applications = new PanelMenuContent (all_apps_bar, "applications.menu");
        applications.menu_clicked.connect (() => {
            dismiss ();
        });

        applications.populate ();
        applications.insert_separator ();

        all_apps_area.set_min_content_height (rect ().height -  filler_height - 200); // TODO
        button_press_event.connect((event) => {
            // Only dismiss if within the area
            // TODO: multihead
            if (event.x > get_window().get_width ()) {
                dismiss ();
                cancelled ();
                return true;
            }
            return false;
        });
    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = get_column_width (); 
    }

    public override void get_preferred_height (out int min, out int max) {
        min = max = rect ().height - 10; 
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


    private void dismiss () {
        var device = get_current_event_device();
        var secondary = device.get_associated_device();
        device.ungrab(Gdk.CURRENT_TIME);
        secondary.ungrab(Gdk.CURRENT_TIME);
        stdout.printf("Menu box dismissed \n");
        dismissed ();
    }
}
