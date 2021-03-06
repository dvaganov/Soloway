namespace SoloWay {
	public class MainWindow : Gtk.ApplicationWindow {
		private static MainWindow self;
		private Gtk.ListBox playlist;
		private HorizontalPanel panel;

		public signal void on_row_activate (string uri);

		private MainWindow(Gtk.Application app) {
			GLib.Object(application: app);
			this.icon_name ="eagle";

			var settings = new GLib.Settings("apps.soloway");
			var window_size = settings.get_value("window-size");
			this.resize(window_size.get_child_value(0).get_int32(),
									window_size.get_child_value(1).get_int32());

			this.size_allocate.connect((allocate) => {
				if (!this.is_maximized) {
					var width = new GLib.Variant.int32(allocate.width);
					var height = new GLib.Variant.int32(allocate.height);
					GLib.Variant current_window_size[2] = {width, height};
					window_size = new GLib.Variant.array(null, current_window_size);
					settings.set_value("window-size", window_size);
				}
			});

			this.width_request = 600;
			this.height_request = 300;

			show_menubar = false;
			window_position = Gtk.WindowPosition.CENTER;

			var main_grid = new Gtk.Grid();
			add(main_grid);

			var header_bar = new Gtk.HeaderBar ();
			header_bar.title = "SoloWay";
			header_bar.show_close_button = true;
			set_titlebar(header_bar);

			var btn = new Gtk.Button.with_mnemonic("_Save");
			btn.action_name = "app.save-playlist";
			header_bar.pack_start(btn);

			btn = new Gtk.Button.with_mnemonic("_Open");
			btn.action_name = "app.open-playlist";
			header_bar.pack_start(btn);

			btn = new Gtk.Button.with_label("Notify");
			btn.clicked.connect(() => {
				var notification = new GLib.Notification("Hello world!");
				notification.set_body("Hello world again!");
				app.send_notification("test", notification);
			});
			header_bar.pack_end(btn);

			var side_panel = SidePanel.get_instance();
			main_grid.attach(side_panel, 1, 0, 1, 1);
			header_bar.pack_end(side_panel.get_controller());

			panel = new HorizontalPanel();
			main_grid.attach(panel, 0, 1, 2, 1);

			var scrolled_win = new Gtk.ScrolledWindow (null, null);
			scrolled_win.shadow_type = Gtk.ShadowType.IN;
			scrolled_win.expand = true;
			main_grid.attach(scrolled_win, 0, 0);

			playlist = new Gtk.ListBox();
			playlist.row_activated.connect((row) => {
			    var entry = row as Entry;
			    on_row_activate(entry.uri);
			    panel.change_title(entry.title);
			});
			playlist.bind_model(PlayGList.get_model(), (item) => {
				return item as Entry;
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
		public void change_btn_state_to_play(bool is_playing) {
			panel.change_state_to_play (is_playing);
			if (is_playing) {
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
		public void change_panel_info(string info) {
			var notification = new GLib.Notification(info);
			notification.add_button("Search Internet for song", "app.search");
			GLib.Application.get_default().send_notification("info-changed", notification);
			panel.change_info(info);
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
