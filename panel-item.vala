using Gtk;

public class PanelItem : MenuItem {

    private string icon_name;
    private int type;

    public PanelItem () {
        set_label("ddd");
    }

    public void update_data (string icon_name, string label, int type)
    {
        this.icon_name = icon_name;
        this.type = type;

        set_label(label);
    }
}
