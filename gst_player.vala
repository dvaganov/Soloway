namespace Soloway {
public class Player : GLib.Object {
    private Gst.Pipeline _pipeline;
    public string uri {get; set; default = "http://online.radiorecord.ru:8101/rr_128";}
    public bool is_playing {get; set; default = false;}
    public string title {get; private set;}
    public string location {get; private set;}
    public signal void on_tag_change(string title);
    public Player(string[] args) {
        Gst.init(ref args);
        this._pipeline = Gst.ElementFactory.make ("playbin", "player") as Gst.Pipeline;
        this._pipeline.set("uri", this.uri);
        var bus = this._pipeline.get_bus();
        bus.add_signal_watch();
        bus.message.connect(this.on_message);
    }
    ~Player() {
        this.set_state("stop");
        Gst.deinit();
    }
    public void set_state(string state) {
        switch (state) {
            case "play":
                this._pipeline.set_state(Gst.State.NULL);
                this._pipeline.set("uri", this.uri);
                this._pipeline.set_state(Gst.State.PLAYING);
                this.is_playing = true;
                break;
            case "stop":
                this._pipeline.set_state(Gst.State.NULL);
                this.is_playing = false;
                break;
        }
    }
    private void on_message(Gst.Message message) {
        if (message.type == Gst.MessageType.TAG) {
            var tag = new Gst.TagList.empty();
            message.parse_tag(out tag);
            tag.get_string("title", out this._title);
            tag.get_string("location", out this._location);
            if (title == null) {
                on_tag_change("Unkown Artist and Song");
            } else {
                on_tag_change(title);
            }

        }
    }
}
}
