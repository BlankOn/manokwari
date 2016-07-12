[DBus (name = "org.freedesktop.DBus.Properties")]
interface DBusProperties : GLib.Object {
  [DBus (name = "Set")]
    public abstract void set(string iface, string name, Variant val)
      throws DBusError, IOError;
  [DBus (name = "Get")]
    public abstract Variant get(string iface, string name)
      throws DBusError, IOError;
  [DBus (name = "GetAll")]
    public abstract HashTable<string, Variant> get_all(string iface)
      throws DBusError, IOError;

  public signal void properties_changed(string iface,
      HashTable <string, Variant> changed,
      string[] invalidated);
}
