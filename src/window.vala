namespace SoloWay {
	public class MainWindow : Gtk.ApplicationWindow {
		private static MainWindow self;
		private Gtk.ListBox playlist;
		private HorizontalPanel panel;

		public signal void on_row_activate (string uri);

		private MainWindow(Gtk.Application app) {
			Object(application: app);
			show_menubar = false;
			default_width = 800;
			default_height = 600;
			window_position = Gtk.WindowPosition.CENTER;

			var main_grid = new Gtk.Grid();
			add(main_grid);

			var header_bar = new Gtk.HeaderBar ();
			header_bar.title = "SoloWay";
			header_bar.show_close_button = true;
			set_titlebar(header_bar);

			var btn = new Gtk.Button.with_mnemonic("_Save");
			btn.clicked.connect(() => {
				Dialogs.save_file(this);
			});
			header_bar.pack_start(btn);

			btn = new Gtk.Button.with_mnemonic("_Open");
			btn.clicked.connect(() => {
				Dialogs.open_file(this);
			});
			header_bar.pack_start(btn);

			var side_panel = SidePanel.get_instance();
			main_grid.attach(side_panel, 1, 0, 1, 1);
			header_bar.pack_end(side_panel.get_controller());

			panel = new HorizontalPanel();
			main_grid.attach(panel, 0, 1, 2, 1);

			var scrolled_win = new Gtk.ScrolledWindow (null, null);
			scrolled_win.shadow_type = Gtk.ShadowType.IN;
			scrolled_win.expand = true;
			main_grid.attach(scrolled_win, 0, 0);

			playlist = new Gtk.ListBox ();
			playlist.row_activated.connect ((row) => {
			    var entry = row as Entry;
			    on_row_activate (entry.uri);
			    panel.change_title (entry.title);
			});
			scrolled_win.add (playlist);
		}
		public void add_entry (string title, string uri) {
			var entry = new Entry (title, uri);
			playlist.add(entry);
		}
		public void clean_playlist () {
			playlist.foreach((widget) => {
				widget.destroy();
			});
		}
		public void change_btn_state_to_play(Player player) {
			panel.change_state_to_play (player.is_playing);
			if (player.is_playing) {
				panel.reveal_child = true;
			} else {
				panel.reveal_child = false;
			}
		}
		public void activate_next_row() {
			var row = playlist.get_selected_row ();
			int index = row.get_index ();
			var next_row = playlist.get_row_at_index (++index);
			if (next_row != null) {
				next_row.activate ();
			}
		}
		public void activate_prev_row() {
			var row = playlist.get_selected_row ();
			int index = row.get_index ();
			var prev_row = playlist.get_row_at_index (--index);
			if (prev_row != null) {
				prev_row.activate ();
			}
		}
		public inline void change_panel_info(Player player) {
			panel.change_info (player.current_playing);
		}
		public static void init(Gtk.Application app) {
			if (self == null) {
				self = new MainWindow(app);
			}
		}
		public static MainWindow get_instance() {
			return self;
		}
	}
}
