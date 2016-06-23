using Gtk;
using Gdk;

public class PanelSocket : Gtk.Socket {

  X.Window id;

  public PanelSocket(X.Window id) {
    this.id = id;
    get_style_context().add_class("manokwari-panel");
  }

  public override void realize() {
    base.realize();
    add_id(id);
  }

}
