using Gtk;
[DBus (name = "org.gnome.SessionManager")]
interface SessionManager : Object {
    public abstract void shutdown () throws IOError;
    public abstract void logout (uint32 mode) throws IOError;
    public abstract bool can_shutdown () throws IOError;
}

public class PanelSessionManager {
    private SessionManager session = null;

    public PanelSessionManager () {
        try {
            session =  Bus.get_proxy_sync (BusType.SESSION,
                                           "org.gnome.SessionManager", "/org/gnome/SessionManager");
        } catch (Error e) {
            stdout.printf ("Unable to connect to session manager\n");
        }
    }

    public void logout () {
        if (session != null) {
            try {
                session.logout (0);
            } catch (Error e) {
                throw e;
            }
        }
    }

    public void shutdown () {
        if (session != null) {
            try {
                session.shutdown ();
            } catch (Error e) {
                throw e;
            }
        }
    }

    public bool can_shutdown () {
        try {
            session.can_shutdown ();
            return true;
        } catch (Error e) {
            stdout.printf ("Unable to shutdown\n");
            return false;
        }
    }
}
