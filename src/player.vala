namespace SoloWay {
	public class Player : GLib.Object {
		private static Player _player;
		private Gst.Pipeline _pipeline;
		private string? _uri;

		public signal void onInfoChange(Player player);
		public signal void onStateChange(Player player);

		public bool is_playing {get; private set; default = false;}
		public string current_playing {get; private set; default = null;}

		private Player() {
			_pipeline = Gst.ElementFactory.make("playbin", "player") as Gst.Pipeline;
			is_playing = false;
			_uri = null;
			var bus = this._pipeline.get_bus();
			bus.add_signal_watch();
			bus.message.connect(this.onMessage);
		}
		~Player () {
			_pipeline.set_state(Gst.State.NULL);
			Gst.deinit ();
		}
		public static Player getInstance() {
			if (_player == null) {
				_player = new Player();
			}
			return _player;
		}
		public void changeState(string? uri = null) {
			if (uri == null) {
				if (is_playing) {
					_pipeline.set_state(Gst.State.NULL);
					is_playing = false;
				} else {
					if (_uri != null) {
						_pipeline.set_state(Gst.State.PLAYING);
						is_playing = true;
					} else {
						return;
					}
				}
			} else if (is_playing && _uri == uri) {
				_pipeline.set_state(Gst.State.NULL);
				is_playing = false;
			} else {
				_uri = uri;
				_pipeline.set_state(Gst.State.NULL);
				_pipeline.set("uri", _uri);
				_pipeline.set_state(Gst.State.PLAYING);
				is_playing = true;
			}
			onStateChange(this);
		}
		private void onMessage(Gst.Message message) {
			if (message.type == Gst.MessageType.TAG) {
				string title, location;
				var tag = new Gst.TagList.empty();
				message.parse_tag(out tag);
				tag.get_string("title", out title);
				tag.get_string("location", out location);
				current_playing = title != null ? title : "Unkown";
				onInfoChange(this);
			}
		}
	}
}
