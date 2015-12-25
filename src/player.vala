namespace SoloWay {
	public class Player : GLib.Object {
		private Gst.Pipeline _pipeline;
		private bool _is_playing;
		private string? _uri;

		public signal void on_info_change (string title);
		public signal void on_state_change (bool is_playing);

		public Player(string[] args) {
			Gst.init (ref args);
			_pipeline = Gst.ElementFactory.make ("playbin", "player") as Gst.Pipeline;

			_is_playing = false;
			_uri = null;

			var bus = this._pipeline.get_bus ();
			bus.add_signal_watch ();
			bus.message.connect (this.on_message);
		}
		~Player () {
			_pipeline.set_state (State.NULL);
			Gst.deinit ();
		}
		public void change_state (string? uri = null) {
			if (uri == null) {
				if (_uri == null) {
					return;
				} else if (_is_playing) {
					_pipeline.set_state (State.NULL);
					_is_playing = false;
				} else if (!_is_playing) {
					_pipeline.set_state (State.PLAYING);
					_is_playing = true;
				}
			} else if (_is_playing && _uri == uri) {
				_pipeline.set_state (State.NULL);
				_is_playing = false;
			} else {
				_uri = uri;
				_pipeline.set_state (State.NULL);
				_pipeline.set ("uri", _uri);
				_pipeline.set_state (State.PLAYING);
				_is_playing = true;
			}
			on_state_change (_is_playing);
		}
		private void on_message (Gst.Message message) {
			if (message.type == Gst.MessageType.TAG) {
				string title, location;
				var tag = new Gst.TagList.empty ();
				message.parse_tag (out tag);
				tag.get_string ("title", out title);
				tag.get_string ("location", out location);
				if (title == null) {
				    on_info_change ("Unkown");
				} else {
				    on_info_change (title);
				}
			}
		}
	}
}


