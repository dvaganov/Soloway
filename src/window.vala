namespace SoloWay {
	public class Window : Gtk.ApplicationWindow {
		private Gtk.ListBox _playlist;
		private HorizontalPanel _panel;
		private SidePanel _side_panel;
		private Gtk.HeaderBar _header_bar;

		public signal void on_row_activate (string uri);

		public Window (int width, int height) {
			show_menubar = false;
			default_width = width;
			default_height = height;
			window_position = Gtk.WindowPosition.CENTER;

			_header_bar = new Gtk.HeaderBar ();
			_header_bar.title = "SoloWay";
			_header_bar.show_close_button = true;
			set_titlebar (_header_bar);

			var main_grid = new Gtk.Grid ();
			add (main_grid);

			_panel = new HorizontalPanel ();
			main_grid.attach (_panel, 0, 1, 2, 1);

			_side_panel = new SidePanel ();
			main_grid.attach (_side_panel, 1, 0, 1, 1);

			var scrolled_win = new Gtk.ScrolledWindow (null, null);
			scrolled_win.shadow_type = Gtk.ShadowType.IN;
			scrolled_win.expand = true;
			main_grid.attach (scrolled_win, 0, 0);

			_playlist = new Gtk.ListBox ();
			_playlist.row_activated.connect ((row) => {
			    var entry = row as Entry;
			    on_row_activate (entry.uri);
			    _panel.change_title (entry.title);
			});
			scrolled_win.add (_playlist);

			_set_side_panel_btn ();
		}
		private void _set_side_panel_btn () {
			var btn_edit = new Gtk.ToggleButton.with_label ("Edit");
			var btn_add = new Gtk.ToggleButton.with_label ("Add");

			btn_edit.toggled.connect (() => {
				var entry = _playlist.get_selected_row () as Entry;
				_side_panel.show_panel (entry);
				if (btn_add.sensitive) btn_add.sensitive = false;
				else btn_add.sensitive = true;
			});
			_header_bar.pack_end (btn_edit);

			btn_add.toggled.connect (() => {
				_side_panel.show_panel ();
				if (btn_edit.sensitive) btn_edit.sensitive = false;
				else btn_edit.sensitive = true;
			});
			_header_bar.pack_end (btn_add);
		}
		public void add_entry (string title, string uri) {
			var entry = new Entry (title, uri);
			_playlist.add (entry);
		}
		public void clean_playlist () {
			_playlist.foreach((widget) => {
				widget.destroy();
			});
		}
		public void change_btn_state_to_play (Player player) {
			_panel.change_state_to_play (player.is_playing);
			if (player.is_playing) {
				_panel.reveal_child = true;
			} else {
				_panel.reveal_child = false;
			}
		}
		public void activate_next_row () {
			var row = _playlist.get_selected_row ();
			int index = row.get_index ();
			var next_row = _playlist.get_row_at_index (++index);
			if (next_row != null) {
				next_row.activate ();
			}
		}
		public void activate_prev_row () {
			var row = _playlist.get_selected_row ();
			int index = row.get_index ();
			var prev_row = _playlist.get_row_at_index (--index);
			if (prev_row != null) {
				prev_row.activate ();
			}
		}
		public inline void change_panel_info (Player player) {
			_panel.change_info (player.current_playing);
		}
	}
}
