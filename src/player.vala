namespace SoloWay {
	public class PlayerGst : GLib.Object, Player {
		private static PlayerGst player;
		private Gst.Pipeline pipeline;
		private string uri;
		private bool is_playing;

		public string current_playing {protected set; get;}

		private PlayerGst() {
			this.pipeline = Gst.ElementFactory.make("playbin", "player") as Gst.Pipeline;
			this.is_playing = false;
			this.uri = null;
			var bus = this.pipeline.get_bus();
			bus.add_signal_watch();
			bus.message.connect(this.on_message);
		}
		~PlayerGst() {
			this.pipeline.set_state(Gst.State.NULL);
			Gst.deinit ();
		}
		private void on_message(Gst.Message message) {
			if (message.type == Gst.MessageType.TAG) {
				string title, location;
				var tag = new Gst.TagList.empty();
				message.parse_tag(out tag);
				tag.get_string("title", out title);
				tag.get_string("location", out location);
				this.current_playing = title != null ? title : "Unkown";
				this.info_changed(current_playing);
			}
		}
		public bool play() {
			var result = false;
			if (this.uri != null) {
				this.pipeline.set_state(Gst.State.NULL);
				this.pipeline.set("uri", this.uri);
				this.pipeline.set_state(Gst.State.PLAYING);
				this.is_playing = true;
				result = true;
				this.state_changed(is_playing);
			}
			return result;
		}
		public bool stop() {
			var result = false;
			if (this.is_playing) {
				this.pipeline.set_state(Gst.State.NULL);
				this.is_playing = false;
				this.uri = null;
				result = true;
				this.state_changed(is_playing);
			}
			return result;
		}
		public bool change_uri(string uri) {
			// Return true only if uri changed
			var result = false;
			if (this.uri != uri) {
				this.uri = uri;
				result = true;
			}
			return result;
		}
		public static void init(string[] args) {
			Gst.init(ref args);
		}
		public static Player get_instance() {
			if (player == null) {
				player = new PlayerGst();
			}
			return player;
		}
	}
}
