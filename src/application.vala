namespace SoloWay {
	public class Application : Gtk.Application {
		private MainWindow _win;

		public Application(string[] args) {
			Object(application_id: "home.dvaganov.soloway");
			Player.init(args);
		}
		protected override void activate() {
			Settings.init();
			// create_playlist
			var playlist = Playlist.get_instance();
			//playlist.changed.connect(create_playlist);
			playlist.open(Settings.get_param("playlist_path"));
			create_actions();
			var menu = new GLib.Menu();
			//menu.append("Change State", "app.change-state");
			menu.append("Quit", "app.quit");
			app_menu = menu;
			MainWindow.init(this);
			_win = MainWindow.get_instance();
			_win.on_row_activate.connect(Player.get_instance().change_state);
			Player.get_instance().state_changed.connect(_win.change_btn_state_to_play);
			Player.get_instance().info_changed.connect(_win.change_panel_info);
			add_window(_win);

			_win.show_all();
		}
		private void create_actions() {
			var action = new SimpleAction("change-state", null);
			action.activate.connect(() =>
			{
				Player.get_instance().change_state();
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
/*		public void create_playlist(Playlist playlist) {
			_win.clean_playlist();
			string title, uri;
			for (var i = 0; i < playlist.length; i++) {
				playlist.get_entry(i, out title, out uri);
				_win.add_entry(title, uri);
			}
			_win.show_all();
		}
*/
		public static int main (string[] args) {
			var app = new Application(args);
			return app.run(args);
		}
	}
}
