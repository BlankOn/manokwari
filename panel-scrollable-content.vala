using Gtk;

public class PanelScrollableContent : ScrolledWindow {
    private Viewport viewport;
    private unowned Widget widget;

    public PanelScrollableContent (PanelAnimatedAdjustment? hadjustment, PanelAnimatedAdjustment? vadjustment) {
        set_hadjustment (hadjustment);
        set_vadjustment (vadjustment);
    }

    public void set_widget (Widget w) {
        widget = w;
        viewport = new Viewport (hadjustment, vadjustment);
        add (viewport);
        viewport.add (w);
        viewport.show ();
        set_scrollbar_policy (PolicyType.NEVER, PolicyType.NEVER);
        show ();
    }

    public void set_scrollbar_policy(PolicyType hpolicy, PolicyType vpolicy) {
        set_policy (hpolicy, vpolicy);
    }
}
