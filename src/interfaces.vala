namespace SoloWay {
  public interface Player {
    public abstract bool play();
    public abstract bool stop();
    public abstract void set_src(string uri);
    public abstract signal void info_changed(string info);
  }

  public interface Playlist {
    public abstract bool open(string filename);
    public abstract void save(string filename);
    public abstract void add(PlaylistRecord entry);
    public abstract bool remove(PlaylistRecord entry);
  }

  public interface PlaylistRecord : GLib.Object {
    public abstract string title {get; set;}
    public abstract string uri {get; set;}
    public abstract uint position {get; private set;}
  }
}
