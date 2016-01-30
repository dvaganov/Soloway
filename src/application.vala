namespace SoloWay {
	public class Application : Gtk.Application {
		private Window _win;
		private string _playlist_path;

		public Application (string[] args) {
			Object(application_id: "home.dvaganov.soloway");
		}
		protected override void activate() {
			_createActions();
			var menu = new GLib.Menu();
			menu.append("Change State", "app.change-state");
			menu.append("Quit", "app.quit");
			app_menu = menu;
			_win = new Window(800, 600);
			_win.on_row_activate.connect(Player.getInstance().changeState);
			Player.getInstance().onStateChange.connect(_win.change_btn_state_to_play);
			Player.getInstance().onInfoChange.connect(_win.change_panel_info);
			add_window(_win);
			_playlist_path = "/home/dvaganov/Documents/Programming/Vala/SoloWay/saved.swp";
			_createPlaylist();
			_win.show_all();
		}
		private void _createActions() {
			var action = new SimpleAction("change-state", null);
			action.activate.connect(() =>
			{
				Player.getInstance().changeState();
			});
			add_action(action);
			action = new SimpleAction("next-entry", null);
			action.activate.connect(() =>
			{
				_win.activate_next_row();
			});
			add_action(action);
			action = new SimpleAction("prev-entry", null);
			action.activate.connect(() =>
			{
				_win.activate_prev_row();
			});
			add_action (action);
			action = new SimpleAction("quit", null);
			action.activate.connect(this.quit);
			add_action(action);
		}
		private void _createPlaylist() {
			if (_playlist_path != null) {
				_win.clean_playlist();
				var stream = FileStream.open(_playlist_path, "r");
				assert(stream != null);
				var line = stream.read_line();
				if (line == "[playlist]") {
					while ((line = stream.read_line()) != null) {
						string[] entry = line.split("<=>");
						_win.add_entry(entry[0], entry[1]);
					}
				}
			}
		}
		public static int main (string[] args) {
			Gst.init (ref args);
			var app = new Application(args);
			return app.run(args);
		}
	}
}
