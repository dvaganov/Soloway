namespace SoloWay {
  public interface Player : GLib.Object {
    public abstract bool play();
    public abstract bool stop();
    public abstract bool set_src(string uri);
    public abstract signal void info_changed(string info);
    public abstract signal void state_changed(bool state);
  }

  public interface Playlist : GLib.Object {
    public abstract bool open(string filename);
    public abstract void save(string filename);
    public abstract void add(PlaylistRecord entry);
    public abstract bool remove(uint position);
  }

  public interface PlaylistRecord : GLib.Object {
    public abstract string title {get; set;}
    public abstract string uri {get; set;}
  }
}
