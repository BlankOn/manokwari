using Gtk;

public class PanelScrollableContent : ScrolledWindow {
    private Viewport viewport;
    private unowned Widget widget;

    public PanelScrollableContent () {
    }

    public void set_widget (Widget w) {
        widget = w;
        viewport = new Viewport (hadjustment, vadjustment);
        add (viewport);
        viewport.add (w);
        viewport.show ();
        set_scrollbar_policy (PolicyType.NEVER, PolicyType.NEVER);
        show_all ();
    }

    public void set_scrollbar_policy(PolicyType hpolicy, PolicyType vpolicy) {
        set_policy (hpolicy, vpolicy);
    }
}
