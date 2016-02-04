namespace SoloWay {
	public class Entry : Gtk.ListBoxRow, PlaylistRecord {
		public string title {get; private set;}
		public string uri {get; private set;}

		public Entry (string? title, string? uri) {
			this.title = title;
			this.uri = uri;
			this.height_request = 50;

			var label = new Gtk.Label (title);
			add (label);
		}
	}

	public class HorizontalPanel : Gtk.Revealer {
		private Gtk.Button _btn_play;
		private Gtk.Button _btn_stop;
		private Gtk.Button _btn_prev;
		private Gtk.Button _btn_next;
		private Gtk.Label _entry_info;
		private Gtk.Label _entry_title;

		public HorizontalPanel () {
			var grid = new Gtk.Grid ();
			grid.margin = 10;
			grid.column_spacing = 10;
			add (grid);

			_entry_title = new Gtk.Label (null);
			_entry_title.use_markup = true;
			_entry_title.halign = Gtk.Align.START;
			_entry_title.ellipsize = Pango.EllipsizeMode.END;
			_entry_title.max_width_chars = 30;
			grid.attach (_entry_title, 1, 0);

			_entry_info = new Gtk.Label (null);
			_entry_info.halign = Gtk.Align.START;
			_entry_info.max_width_chars = 50;
			_entry_info.ellipsize = Pango.EllipsizeMode.END;
			_entry_info.set_selectable (true);
			_entry_info.justify = Gtk.Justification.LEFT;
			_entry_info.hexpand = true;
			grid.attach (_entry_info, 1, 1);

			var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
			box.valign = Gtk.Align.CENTER;
			box.halign = Gtk.Align.CENTER;
			box.get_style_context ().add_class ("linked");
			grid.attach (box, 0, 0, 1, 2);

			_btn_next = new Gtk.Button.from_icon_name ("media-seek-forward-symbolic", Gtk.IconSize.BUTTON);
			_btn_next.action_name = "app.next-entry";
			box.pack_end (_btn_next, false);

			_btn_prev = new Gtk.Button.from_icon_name ("media-seek-backward-symbolic", Gtk.IconSize.BUTTON);
			_btn_prev.action_name = "app.prev-entry";
			box.pack_start (_btn_prev, false);

			_btn_play = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.BUTTON);
			_btn_play.width_request = 60;
			_btn_play.action_name = "app.change-state";
			box.pack_start (_btn_play);

			_btn_stop = new Gtk.Button.from_icon_name ("media-playback-stop-symbolic", Gtk.IconSize.BUTTON);
			_btn_stop.width_request = 60;
			_btn_stop.action_name = "app.change-state";
			_btn_stop.no_show_all = true;
			box.pack_start (_btn_stop);
		}
		public void change_state_to_play (bool is_playing) {
			if (is_playing) {
				_btn_play.hide ();
				_btn_stop.show ();
			} else {
				_btn_stop.hide ();
				_btn_play.show ();
			}
		}
		public void change_title (string title) {
			_entry_title.label = "<b>" + title + "</b>";
		}
		public void change_info (string info) {
			_entry_info.label = info;
		}
	}
}
