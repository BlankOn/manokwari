using Gtk;

public class PanelScrollableContent : ScrolledWindow {
    private Viewport viewport;

    public class PanelScrollableContent (PanelAnimatedAdjustment? hadjustment, PanelAnimatedAdjustment? vadjustment, Widget w) {
        set_hadjustment (hadjustment);
        set_vadjustment (vadjustment);
        viewport = new Viewport (hadjustment, vadjustment);
        set_scrollbar_policy (PolicyType.NEVER, PolicyType.NEVER);
        add (viewport);
        viewport.add (w);
        viewport.show ();
        show ();
    }

    public void set_scrollbar_policy(PolicyType hpolicy, PolicyType vpolicy) {
        set_policy (hpolicy, vpolicy);
    }
}
