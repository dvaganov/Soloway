namespace SoloWay {
  public class Playlist : GLib.Object {
    private static Playlist self;
    private struct SongEnry {
      string title;
      string uri;
    }
    private GLib.KeyFile file;
    private GLib.GenericArray<SongEnry?> playlist;
    private string group_name = "Playlist";

    public signal void changed(Playlist pl);
    public int length {
      get {return playlist.length;}
      private set {}
    }

    private Playlist() {
      this.file = new GLib.KeyFile();
      this.file.set_list_separator('=');
      this.playlist = new GLib.GenericArray<SongEnry?>();
    }
    public void open(string filepath) {
      try {
        this.file.load_from_file(filepath, GLib.KeyFileFlags.NONE);
        var titles = file.get_keys(group_name);
        for (var i = 0; i < titles.length; i++) {
          this.playlist.add({titles[i], this.file.get_string(this.group_name, titles[i])});
        }
        this.changed(this);
      } catch(GLib.KeyFileError key_err) {
        print(@"Load file: $(key_err.message)\n");
      } catch(GLib.FileError err) {
        print(@"Load file: $(err.message)\n");
      }
    }
    public void save(string filepath) {
      SongEnry entry;
      for (var i = 0; i < playlist.length; i++) {
        entry = this.playlist.get(i);
        this.file.set_string(this.group_name, entry.title, entry.uri);
      }
      try {
        this.file.save_to_file(filepath);
      } catch (GLib.FileError e) {
        print(@"Playlist.save(): $(e.message)");
      }
    }
    public void add_entry(string title, string uri) {
      this.playlist.add({title, uri});
      this.changed(this);
    }
    public void get_entry(int index, out string title, out string uri) {
      var entry = this.playlist.get(index);
      title = entry.title;
      uri = entry.uri;
    }
    public void remove_entry(int index) {
      this.playlist.remove_index(index);
      this.changed(this);
    }
    public static Playlist get_instance() {
      if (self == null) {
        self = new Playlist();
      }
      return self;
    }
  }
}
