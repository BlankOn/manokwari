using Gtk;

public class Clock : Label {
	
	public Clock () {
		Timeout.add (1000, update);
		
	}
	
	private bool update () {
		char buffer[20];
		Time t = Time.local (time_t ());
		t.strftime (buffer, "%I:%M:%S");
		set_text ((string) buffer);
		return true;
	}
	
}
