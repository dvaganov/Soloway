namespace SoloWay {
	public class Application : Gtk.Application {
		private MainWindow win;
		private Playlist playlist;
		private GLib.Settings settings;

		public Application(string[] args) {
			GLib.Object(application_id: "apps.Soloway");
			PlayerGst.init(args);
		}
		protected override void activate() {
			// Load settings
			settings = new GLib.Settings("apps.soloway");
			// create_playlist
			playlist = PlayGList.get_instance();
			playlist.open(settings.get_string("playlist-path"));
			// Create actions
			create_actions();
			var menu = new GLib.Menu();
			//menu.append("Change State", "app.change-state");
			menu.append("Quit", "app.quit");
			app_menu = menu;

			MainWindow.init(this);
			win = MainWindow.get_instance();
			win.on_row_activate.connect((uri) => {
				var player = PlayerGst.get_instance();
				if (player.change_uri(uri)) {
					player.play();
				} else {
					player.stop();
				}
			});
			PlayerGst.get_instance().state_changed.connect(win.change_btn_state_to_play);
			PlayerGst.get_instance().info_changed.connect(win.change_panel_info);
			add_window(win);

			win.show_all();
		}
		private void create_actions() {
			var action = new SimpleAction("next-entry", null);
			action.activate.connect(() => {
				win.activate_next_row();
			});
			add_action(action);

			action = new SimpleAction("prev-entry", null);
			action.activate.connect(() => {
				win.activate_prev_row();
			});
			add_action(action);

			action = new SimpleAction("open-playlist", null);
			action.activate.connect(() => {
				var path	= Dialogs.open_file(this.win);
				if (path != null) {
					this.settings.set_string("playlist-path", path);
					playlist.open(path);
					win.show_all();
				}
			});
			add_action(action);

			action = new SimpleAction("save-playlist", null);
			action.activate.connect(() => {
				var path	= Dialogs.save_file(this.win);
				if (path != null) {
					this.settings.set_string("playlist-path", path);
					playlist.save(path);
					win.show_all();
				}
			});
			add_action(action);

			action = new SimpleAction("search", null);
			action.activate.connect(() => {
				var song = PlayerGst.get_instance().current_playing;
				var btn = new Gtk.LinkButton(@"https://google.com/?q=$song");
				btn.activate_link();
			});
			add_action(action);

			action = new SimpleAction("quit", null);
			action.activate.connect(this.quit);
			add_action(action);
		}
		public static int main(string[] args) {
			var app = new Application(args);
			return app.run(args);
		}
	}
}
