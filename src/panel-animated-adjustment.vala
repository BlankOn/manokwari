using Gtk;

public class PanelAnimatedAdjustment : Adjustment {
    private double direction = 1; 
    private double target = 0;
    private double target_delta = 0;
    private double interpolated = 0;
    private double duration = 200;
    private double time = 0;
    private double start_value = 0;

    public signal void finished ();

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
            finished ();
            return false;
        }

        if (time > duration) {
            time = 0;
            finished ();
            return false;
        }
        time += 16;
        set_value (interpolated);
        return true;
    }
}

