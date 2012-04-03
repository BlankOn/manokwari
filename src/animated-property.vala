public class AnimatedProperty {
    Object o;
    string property_name;
    int duration;
    double initial;
    double final;
    int count = 0;
    public signal void finished ();
    public signal void frame ();

    public AnimatedProperty (Object o) {
        this.o = o;
        initial = final = 0;
        property_name = "";
        duration = 200;
    }

    public void set_property (string property_name) {
        this.property_name = property_name;
    }

    public void set_final_value (double value) {
        final = value;
    }

    public void set_duration (int ms) {
        duration = ms;
    }

    public void start () {
        count = 0;
        o.get (property_name, out initial);
        GLib.Timeout.add (16, do_iteration);
    }

    bool do_iteration () {
        var direction = (initial < final) ? 1 : -1;

        if (count < duration) {
            var interpolated = ease (count, initial, final -  initial, duration);         


            frame ();
            if ((interpolated > final && direction == 1) ||
                (interpolated < final && direction == -1)) {
                interpolated = final;
                o.set (property_name, interpolated);
                finished ();
                return false;
            }
            o.set (property_name, interpolated);

            count += 16;
        } else {
            finished ();
            return false;
        }
        return true;
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

    double ease (double t, double b, double c, double d) {
        if ((t/=d/2) < 1) return c/2*t*t*t + b;
        return c/2*((t-=2)*t*t + 2) + b;
    }

}
