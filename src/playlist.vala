namespace SoloWay {
  public class Playlist {
    private static Playlist _self;
    private struct SongEnry {
      string title;
      string uri;
    }
    private GLib.KeyFile _file;
    private GLib.GenericArray<SongEnry?> _playlist;
    private string _group_name = "Playlist";

    public int length {
      get {return _playlist.length;}
      private set {}
    }

    public signal void onPlaylistChange(Playlist pl);

    private Playlist() {
      _file = new GLib.KeyFile();
      _file.set_list_separator('=');
      _playlist = new GLib.GenericArray<SongEnry?>();
    }
    public bool open(string filepath) {
      var result = false;
      try {
        _file.load_from_file(filepath, GLib.KeyFileFlags.NONE);
        var titles = _file.get_keys(_group_name);
        for (var i = 0; i < titles.length; i++) {
          _playlist.add({titles[i], _file.get_string(_group_name, titles[i])});
        }
        result = true;
      } catch(GLib.KeyFileError key_err) {
        print(@"Load file: $(key_err.message)\n");
      } catch(GLib.FileError err) {
        print(@"Load file: $(err.message)\n");
      }
      onPlaylistChange(this);
      return result;
    }
    public void save(string filepath) {
      SongEnry entry;
      for (var i = 0; i < _playlist.length; i++) {
        entry = _playlist.get(i);
        _file.set_string(_group_name, entry.title, entry.uri);
      }
      try {
        _file.save_to_file(filepath);
      } catch (GLib.FileError e) {
        print(@"Playlist.save(): $(e.message)");
      }
    }
    public void addEntry(string title, string uri) {
      _playlist.add({title, uri});
      onPlaylistChange(this);
    }
    public void getEntry(int index, out string title, out string uri) {
      var entry = _playlist.get(index);
      title = entry.title;
      uri = entry.uri;
    }
    public void removeEntry(int index) {
      onPlaylistChange(this);
    }
    public static Playlist getInstance() {
      if (_self == null) {
        _self = new Playlist();
      }
      return _self;
    }
  }
}
